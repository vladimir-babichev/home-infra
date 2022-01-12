#!/bin/bash
# Script origin: https://github.com/rogerrum/k8s-gitops/blob/d25baffb0d580f5708f2b3379780ab5da2ff4d5d/setup/bootstrap-vault.sh

# Source common functions
# shellcheck source=/dev/null
source "$(dirname "$(realpath "$0")")/../common.sh"
source "$ROOT_DIR/scripts/bootstrap/.env"

help() {
    cat <<EOF
    To display this help again use this flags:    -h, --help

    Parameters:
    -a, --vault-addr     Vault address. Default: http://127.0.0.1:8200
    -n, --namespace      Target namespace
    -r, --replica-count  Target namespace. Default: 0
EOF
}

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -n|--namespace)
        namespace="$2"
        shift
        ;;
    -r|--replica-count)
        replica_count="$2"
        shift
        ;;
    -a|--vault-addr)
        vault_addr="$2"
        shift
        ;;
    -h|--help)
        help
        exit 0
        ;;
    *)
        fail "Parameter $1 not recognized!"
        ;;
  esac
  shift
done

if [[ -z "$namespace" ]]; then
    fail "Namespace cannot be null!"
fi

if [[ -z "$replica_count" ]]; then
  replica_count=0
fi
VAULT_REPLICAS=$(seq -s " " -t "\n" 0 $((replica_count)))
export VAULT_REPLICAS="$VAULT_REPLICAS"

if [[ -z "$vault_addr" ]]; then
  vault_addr="http://127.0.0.1:8200"
fi
export VAULT_ADDR="$vault_addr"

# trap "exit" INT TERM
# trap "kill 0" EXIT


argoHelmValueVault() {
  name="secrets/argocd/argo-helm-values"
  keyName="$(basename -s -helm-values.txt "$@").yaml"
  if output=$(envsubst <"$ROOT_DIR/$*"); then
    if vault kv get "$name"; then
      echo "Updating $name to vault - Adding key $keyName"
      printf '%s' "$output" | vault kv patch -method rw "$name" "$keyName"=-
    else
      echo "Creating $name to vault - Adding key $keyName"
      printf '%s' "$output" | vault kv put "$name" "$keyName"=-
    fi
  fi
}

helmVault() {
  name="secrets/$(dirname "$@")/$(basename -s .txt "$@")"
  echo "Writing $name to vault"
  if output=$(envsubst <"$ROOT_DIR/$*"); then
    printf '%s' "$output" | vault kv put "$name" values=-
  fi
}

secretVault() {
  name="secrets/$(dirname "$@")/$(basename -s .txt "$@")"
  echo "Writing $name to vault"
  if output=$(envsubst <"$ROOT_DIR/$*"); then
    printf '%s' "$output" | xargs vault kv put "$name"
  fi
}

installVault() {
  cd "${ROOT_DIR}/k8s/core/vault/" || fail
  helm dependency update
  helm upgrade -i vault . \
      --set vault.server.ingress=null
}

initVault() {
  info "initializing and unsealing vault (if necesary)"
  VAULT_READY=1
  while [ $VAULT_READY != 0 ]; do
    kubectl -n "$namespace" wait --for condition=Initialized pod/vault-0 >/dev/null 2>&1
    VAULT_READY="$?"
    if [ $VAULT_READY != 0 ]; then
      echo "waiting for vault pod to be somewhat ready..."
      sleep 10
    fi
  done
  sleep 2

  VAULT_READY=1
  while [ $VAULT_READY != 0 ]; do
    init_status=$(kubectl -n "$namespace" exec "vault-0" -- vault status -format=json 2>/dev/null | jq -r '.initialized')
    if [ "$init_status" == "false" ] || [ "$init_status" == "true" ]; then
      VAULT_READY=0
    else
      echo "vault pod is almost ready, waiting for it to report status"
      sleep 5
    fi
  done

  sealed_status=$(kubectl -n "$namespace" exec "vault-0" -- vault status -format=json 2>/dev/null | jq -r '.sealed')
  init_status=$(kubectl -n "$namespace" exec "vault-0" -- vault status -format=json 2>/dev/null | jq -r '.initialized')

  if [ "$init_status" == "false" ]; then
    echo "initializing vault"
    vault_init=$(kubectl -n "$namespace" exec "vault-0" -- vault operator init -format json -key-shares=1 -key-threshold=1) || exit 1
    echo "$vault_init"
    VAULT_UNSEAL_TOKEN=$(echo "$vault_init" | jq -r '.unseal_keys_b64[0]')
    export VAULT_UNSEAL_TOKEN="$VAULT_UNSEAL_TOKEN"
    VAULT_ROOT_TOKEN=$(echo "$vault_init" | jq -r '.root_token')
    export VAULT_ROOT_TOKEN="$VAULT_ROOT_TOKEN"
    echo "VAULT_UNSEAL_TOKEN is: $VAULT_UNSEAL_TOKEN"
    echo "VAULT_ROOT_TOKEN is: $VAULT_ROOT_TOKEN"

    # sed -i operates differently in OSX vs linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "darwin system"
      sed -i '' "s~VAULT_ROOT_TOKEN=\".*\"~VAULT_ROOT_TOKEN=\"$VAULT_ROOT_TOKEN\"~" "$ROOT_DIR"/scripts/bootstrap/.env
      sed -i '' "s~VAULT_UNSEAL_TOKEN=\".*\"~VAULT_UNSEAL_TOKEN=\"$VAULT_UNSEAL_TOKEN\"~" "$ROOT_DIR"/scripts/bootstrap/.env
    else
      echo "non-darwin (linux?) system"
      sed -i'' "s~VAULT_ROOT_TOKEN=\".*\"~VAULT_ROOT_TOKEN=\"$VAULT_ROOT_TOKEN\"~" "$ROOT_DIR"/scripts/bootstrap/.env
      sed -i'' "s~VAULT_UNSEAL_TOKEN=\".*\"~VAULT_UNSEAL_TOKEN=\"$VAULT_UNSEAL_TOKEN\"~" "$ROOT_DIR"/scripts/bootstrap/.env
    fi
    echo "SAVE THESE VALUES!"

    # VAULT_REPLICAS_LIST=("$VAULT_REPLICAS")
    # echo "sleeping 10 seconds to allow first vault to be ready"
    # sleep 10
    # for replica in "${VAULT_REPLICAS_LIST[@]:1}"; do
    #   echo "joining pod vault-${replica} to raft cluster"
    #   kubectl -n "$namespace" exec "vault-${replica}" -- vault operator raft join http://vault-0.vault-internal:8200 || exit 1
    # done

  fi

  if [ "$sealed_status" == "true" ]; then
    echo "unsealing vault"
    for replica in $VAULT_REPLICAS; do
      echo "unsealing vault-${replica}"
      kubectl -n "$namespace" exec "vault-${replica}" -- vault operator unseal "$VAULT_UNSEAL_TOKEN" || exit 1
    done
  fi
}

portForwardVault() {
  info "port-forwarding vault"
  kubectl -n "$namespace" port-forward svc/vault 8200:8200 >/dev/null 2>&1 &
  export VAULT_FWD_PID=$!

  sleep 5
}

loginVault() {
  info "logging into vault"
  if [ -z "$VAULT_ROOT_TOKEN" ]; then
    echo "VAULT_ROOT_TOKEN is not set! Check $ROOT_DIR/scripts/bootstrap/.env"
    exit 1
  fi

  vault login -no-print "$VAULT_ROOT_TOKEN" || exit 1

  if ! vault auth list >/dev/null 2>&1; then
    echo "not logged into vault!"
    echo "1. port-forward the vault service (e.g. 'kubectl -n \"$namespace\" port-forward svc/vault 8200:8200 &')"
    echo "2. set VAULT_ADDR (e.g. 'export VAULT_ADDR=http://localhost:8200')"
    echo "3. login: (e.g. 'vault login <some token>')"
    exit 1
  fi
}

configureVault() {
  cd "${ROOT_DIR}/terraform" || fail
  terraform init
  terraform apply -var-file=main.tfvars -auto-approve
}

loadSecretsToVault() {
  info "writing secrets to vault"
  vault kv put secrets/k8s/cluster domain="$K8S_CLUSTER_DOMAIN"

  vault kv put secrets/k8s/traefik-forward-auth/github clientId="$TRAEFIK_FORWARD_AUTH_CLIENTID"
  vault kv put secrets/k8s/traefik-forward-auth/github clientSecret="$TRAEFIK_FORWARD_AUTH_CLIENTSECRET"
  vault kv put secrets/k8s/traefik-forward-auth/github whitelistEmails="$TRAEFIK_FORWARD_AUTH_WHITELISTEMAILS"

#   secretVault "main/homelab/minio/minio-secret.txt"
#   argoHelmValueVault "main/monitoring/botkube/botkube-helm-values.txt"
}




if ! kubectl get ns "$namespace" >/dev/null 2>&1; then
    kubectl create namespace "$namespace"
fi
kubens "$namespace"


installVault
initVault
portForwardVault
loginVault
configureVault
loadSecretsToVault

kill $VAULT_FWD_PID

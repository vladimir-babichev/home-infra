#!/usr/bin/env bash

# Source common functions
# shellcheck source=/dev/null
source "$(dirname "$(realpath "$0")")/../common.sh"

# kubectl create namespace core
# kubens core

# # cd "${ROOT_DIR}/k8s/core/nfs-subdir-external-provisioner/"
# # helm dependency update
# # helm upgrade -i nfs-subdir-external-provisioner .

"${ROOT_DIR}"/scripts/bootstrap/vault.sh --namespace core
"${ROOT_DIR}"/scripts/bootstrap/argocd.sh --namespace gitops
"${ROOT_DIR}"/scripts/bootstrap/apps.sh --namespace gitops

#------------------------------------------------------------------------------
# secret store
#------------------------------------------------------------------------------

resource "vault_mount" "secrets" {
  path        = "secrets"
  type        = "kv"
  description = "Secret Store"
  options     = { version : 2 }
}

#------------------------------------------------------------------------------
# certificate authorities
#------------------------------------------------------------------------------

module "root-ca" {
  source = "./modules/pki/root"

  common_name  = var.vault_root_ca.common_name
  country      = var.vault_root_ca.country
  organization = var.vault_root_ca.organization
  ou           = var.vault_root_ca.ou
  path         = var.vault_root_ca.path
  vault_addr   = var.vault_addr
}

module "issuing-ca" {
  source = "./modules/pki/intermediate"

  common_name  = var.vault_issuing_ca.common_name
  country      = var.vault_issuing_ca.country
  organization = var.vault_issuing_ca.organization
  ou           = var.vault_issuing_ca.ou
  path         = var.vault_issuing_ca.path
  signing_path = module.root-ca.path
  vault_addr   = var.vault_addr
}

#------------------------------------------------------------------------------
# roles
#------------------------------------------------------------------------------

resource "vault_pki_secret_backend_role" "main" {
  backend          = module.issuing-ca.path
  name             = var.vault_issuing_ca.name
  allow_subdomains = true
  allowed_domains  = var.vault_issuing_ca.allowed_domains
  max_ttl          = "63072000" # 2 years
  country          = [var.vault_issuing_ca.country]
  organization     = [var.vault_issuing_ca.organization]
  ou               = [var.vault_issuing_ca.ou]
  key_usage        = ["DigitalSignature", "KeyAgreement", "KeyEncipherment"]
}



#------------------------------------------------------------------------------
# kubernetes auth backend method
#------------------------------------------------------------------------------


resource "vault_policy" "k8s-secrets-ro" {
  name = "k8s-secrets-ro"

  policy = <<EOT
path "secrets/metadata/k8s/" {
  capabilities = ["list"]
}

path "secrets/data/k8s/*" {
  capabilities = ["read"]
}
EOT
}

data "kubernetes_service_account" "main" {
  metadata {
    name      = var.vault_k8s_sa.name
    namespace = var.vault_k8s_sa.namespace
  }
}

data "kubernetes_secret" "main" {
  metadata {
    name      = data.kubernetes_service_account.main.default_secret_name
    namespace = var.vault_k8s_sa.namespace
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "main" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = data.kubernetes_secret.main.data["ca.crt"]
  token_reviewer_jwt = data.kubernetes_secret.main.data["token"]
  # issuer                 = "k3s"
  disable_iss_validation = true
}

resource "vault_kubernetes_auth_backend_role" "k8s-secrets-ro" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "k8s-secrets-ro"
  bound_service_account_names      = var.vault_bound_sa_names
  bound_service_account_namespaces = var.vault_bound_sa_namespaces
  token_ttl                        = 3600
  token_policies                   = ["k8s-secrets-ro"]
}

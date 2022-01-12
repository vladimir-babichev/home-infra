variable "kubernetes_host" { default = "https://kubernetes.default.svc" }

variable "vault_bootstrap_addr" {
  default = ""
}
variable "vault_addr" {
  default = "http://vault.core.svc:8200"
}
variable "vault_k8s_sa" {
  type = map(string)
}
variable "vault_bound_sa_names" {}
variable "vault_bound_sa_namespaces" {}

variable "vault_root_ca" {
  type = map(string)
}

variable "vault_issuing_ca" {
  type = object({
    name            = string
    common_name     = string
    country         = string
    organization    = string
    ou              = string
    path            = string
    allowed_domains = list(string)
  })
}

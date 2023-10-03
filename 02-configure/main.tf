terraform {
  required_version = ">= 1.3.0"
}

provider "vault" {
  address = "http://localhost:8200"
  token   = var.vault_root_token
}

variable "vault_root_token" {
  type = string
}

# Authentication
resource "vault_auth_backend" "kubernetes" {
  type        = "kubernetes"
  description = "For use with Kubernetes service accounts"
}

resource "vault_kubernetes_auth_backend_config" "cluster" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = "https://kubernetes.default:443"
}

# Mounts
resource "vault_mount" "database" {
  path = "database"
  type = "database"
}

resource "vault_mount" "services" {
  type        = "kv"
  path        = "service"
  options     = { version = "2" }
  description = "Secrets for logical services running in the cluster"
}
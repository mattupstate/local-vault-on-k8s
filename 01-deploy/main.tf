terraform {
  required_version = ">= 1.3.0"

  required_providers {
    helm = {
      version = ">= 2.7.0"
    }
    kubernetes = {
      version = ">= 2.14.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "kubernetes_config_map" "vault_post_start_script" {
  metadata {
    name      = "vault-post-start-script"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  binary_data = {
    "vault-post-start.sh" = "${filebase64("${path.module}/vault-post-start.sh")}"
  }
}

resource "helm_release" "vault" {
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.21.0"
  name       = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  atomic     = true

  values = [
    file("${path.module}/vault.values.yaml")
  ]
}

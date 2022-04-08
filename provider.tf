provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}

resource "local_file" "kubeconfig" {
  content  = var.kubeconfig
  filename = "${path.module}/kubeconfig"
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.8.0"
    }
  }
}
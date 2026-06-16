# 🏗️ Terraform settings for local environment
terraform {
  required_version = ">= 1.15"

  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# 🤝 Minikube provider config
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}
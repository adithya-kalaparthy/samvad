# 🏗️ Terraform settings — what version and which plugins to use.
terraform {
  # Make sure your Terraform version is at least 1.15
  required_version = ">= 1.15"

  required_providers {
    # 📦 The Kubernetes provider lets Terraform talk to your cluster
    # (just like kubectl, but declarative)
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# 🤝 Tell Terraform how to connect to your Kubernetes cluster.
provider "kubernetes" {
  # Use the same config file that kubectl uses (~/.kube/config)
  config_path = "~/.kube/config"

  # 🏠 Local deployments always use minikube.
  # If you have multiple contexts in your kubeconfig, this picks the right one.
  config_context = "minikube"
}

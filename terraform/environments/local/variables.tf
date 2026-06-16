# 👇 These are the knobs you can tweak without touching the main code.
# Each variable has a default value, but you can override it in terraform.tfvars.

# 🌍 Kubernetes namespace to deploy into
variable "namespace_name" {
  default = "samvad-dev"
}

# 🏷️ Environment label (development, staging, production)
variable "environment" {
  default = "development"
}

# 🔁 Number of replicas
variable "replicas" {
  default = 2
}

# 🚫 Image pull policy ("Never" for minikube, "Always" for EKS)
variable "image_pull_policy" {
  default = "Never"
}

# 🌐 Service type (NodePort for minikube, LoadBalancer for EKS)
variable "service_type" {
  default = "NodePort"
}

# 🤫 Your secret API key — keep this safe!
# Set it in terraform.tfvars (which is gitignored)
variable "valid_api_key" {
  type        = string
  description = "API key for authenticating requests (from .env)"
  sensitive   = true
}
# 👇 These are the knobs you can tweak without touching the main code.
# Each variable has a default value, but you can override it in terraform.tfvars.

# 🌍 Kubernetes namespace to deploy into
variable "namespace_name" {}

# 🏷️ Environment label (development, staging, production)
variable "environment" {}

# 🐳 Docker image name
variable "image_name" {
  default = "samvad-api"
}

# 🏷️ Docker image tag (version)
variable "image_tag" {
  default = "latest"
}

# 📛 Name that goes on the Pod label (used by selector & service)
variable "pod_name" {
  default = "samvad-api"
}

# 📛 Name of the container inside the pod
variable "container_name" {
  default = "samvad-api"
}

# 🔌 Port the Go app listens on inside the container (must match code)
variable "container_port" {
  default = "8080"
}

# 💻 Port on your local machine for kubectl port-forward
variable "host_port" {
  default = "8080"
}

# 🚪 Port the Service listens on inside the cluster
variable "service_port" {
  default = "80"
}

# 🌐 Port exposed on the node (must be 30000-32767 for NodePort)
variable "node_port" {
  default = "30080"
  validation {
    condition     = var.node_port >= 30000 && var.node_port <= 32767
    error_message = "node_port must be between 30000 and 32767."
  }
}

# 🔁 Number of replicas
variable "replicas" {}

# 🔑 Secret name
variable "secret_name" {
  default = "samvad-api-secret"
}

# 🚫 Image pull policy ("Never" for minikube, "Always" for EKS)
variable "image_pull_policy" {
  default = "Never"
}

# 🌐 Service type (NodePort for minikube, LoadBalancer for EKS)
variable "service_type" {}

# 🤫 Your secret API key — keep this safe!
# Set it in terraform.tfvars (which is gitignored)
variable "valid_api_key" {
  type        = string
  description = "API key for authenticating requests (from .env)"
  sensitive   = true
}

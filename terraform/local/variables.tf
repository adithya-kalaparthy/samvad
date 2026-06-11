# 👇 These are the knobs you can tweak without touching the main code.
# Each variable has a default value, but you can override it in terraform.tfvars.

# 🌍 Kubernetes namespace to deploy into
variable "namespace_name" {
  default = "samvad-dev"
}

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

# 🌐 Port exposed on the minikube node (must be 30000-32767)
variable "node_port" {
  default = "30080"
}

# 🤫 Your secret API key — keep this safe!
# Set it in terraform.tfvars (which is gitignored)
variable "valid_api_key" {
  type        = string
  description = "API key for authenticating requests (from .env)"
  sensitive   = true
}

# 🌍 The Kubernetes namespace name
output "namespace_name" {
  value = var.namespace_name
}

# 💻 The local port you use to reach the app via port-forward
output "host_port" {
  value = var.host_port
}

# 🚪 The Service port inside the cluster
output "service_port" {
  value = var.service_port
}

# 🌐 The nodePort on the minikube VM
output "node_port" {
  value = var.node_port
}

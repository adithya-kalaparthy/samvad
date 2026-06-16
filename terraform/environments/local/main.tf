# 🏠 Local environment consuming the samvad-app module
# Uses minikube provider, local state, NodePort service

module "samvad_app" {
  source = "../../modules/samvad-app"

  # Required variables
  namespace_name = var.namespace_name
  valid_api_key  = var.valid_api_key

  # Override defaults for local
  environment = var.environment
  image_pull_policy = var.image_pull_policy
  replicas = var.replicas
  service_type = var.service_type
}
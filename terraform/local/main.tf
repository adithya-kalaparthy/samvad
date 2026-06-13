# 📦 locals = local variables we can reuse everywhere in this file.
locals {
  # Same as deployment name in deployment.yaml file.
  app_name = "samvad-api-deployment"
  # 🏷️ Labels are like luggage tags — they help K8s find which Pods belong together.
  # The Deployment, the Pods, and the Service all share these exact labels.
  # If they don't match → no traffic flows (silent failure, very confusing).
  labels = {
    "app"         = "samvad-api"
    "environment" = "development"
  }
}

# 🌍 Namespace = a private room in a shared house.
# Everything samvad lives here, separate from other apps.
# Run `kubectl get namespaces` to see all rooms.
resource "kubernetes_namespace_v1" "samvad_dev" {
  metadata {
    name   = "samvad-dev"
    labels = local.labels
  }
}

# 🔑 Secret = stores sensitive stuff (API keys, passwords, etc.)
# The values get injected as environment variables into your container.
# Never hardcode secrets in your code — put them here.
# The actual value comes from terraform.tfvars (which is gitignored 🤫).
resource "kubernetes_secret_v1" "samvad_api_secret" {
  metadata {
    name      = "samvad-api-secret"
    namespace = var.namespace_name
  }

  # base64encode() is required by K8s for the "data" field.
  # Don't worry — K8s decodes it back before the pod sees it.
  data = {
    VALID_API_KEY = var.valid_api_key
  }
}

# 🤖 Deployment = "run this container and keep it alive."
# If the pod crashes, K8s restarts it. That's the whole magic of K8s.
# This is the Terraform equivalent of deployment.yaml.
resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = local.app_name
    labels    = local.labels
    namespace = var.namespace_name
  }

  spec {
    replicas = 2

    # 🎯 Selector tells the Deployment which Pods it owns.
    # Must match the labels on the pod template below.
    selector {
      match_labels = {
        app = var.pod_name
      }
    }

    template {
      metadata {
        # 📛 These labels go on each Pod.
        # The selector above AND the Service below both use these to find the Pods.
        labels = {
          app = var.pod_name
        }
      }

      spec {
        container {
          name  = var.container_name
          image = "${var.image_name}:${var.image_tag}"
          # 🚫 "Never" = don't try to pull from Docker Hub or AWS artifact registry.
          # We use the image already loaded into minikube's Docker.
          image_pull_policy = "Never"

          port {
            container_port = var.container_port
          }

          # 📊 Resources = how much CPU/memory this container needs.
          # requests = minimum guaranteed (K8s uses this to pick a node).
          # limits = maximum allowed (container gets throttled if it exceeds).
          resources {
            requests = {
              cpu    = "100m" # 100 milli-CPU = 0.1 core
              memory = "64Mi" # 64 Mebibytes
            }

            limits = {
              cpu    = "500m"  # 0.5 core max
              memory = "128Mi" # 128 Mebibytes max
            }
          }

          # 📨 Environment variables injected from the Secret above.
          # The pod never sees the secret file — K8s injects it at runtime.
          env {
            name = "VALID_API_KEY"
            value_from {
              secret_key_ref {
                name = "samvad-api-secret"
                key  = "VALID_API_KEY"
              }
            }
          }
        }
      }
    }
  }
}

# 🚪 Service = the front door to your Pods.
# Pods come and go (they crash, restart, move), but the Service always has the same address.
# Other things can reach the app at a stable DNS name instead of chasing Pod IPs.
# This is the Terraform equivalent of service.yaml.
resource "kubernetes_service_v1" "samvad_api_service" {
  metadata {
    name      = "${var.pod_name}-service"
    labels    = local.labels
    namespace = var.namespace_name
  }

  spec {
    # 🏷️ Any Pod with matching labels gets traffic.
    # Must match the pod template labels in the Deployment above.
    selector = {
      app = var.pod_name
    }

    port {
      # 🚪 port = the port this Service listens on inside the cluster.
      # Other Pods can reach it at "samvad-api-deployment-service:80".
      port = var.service_port
      # 🎯 target_port = the port the container is actually listening on.
      # Must match container_port in the Deployment.
      target_port = var.container_port
      # 🌐 node_port = the port exposed on every node's IP address.
      # Access from outside: http://<minikube-ip>:30080
      # Only works when type = "NodePort". Must be 30000-32767.
      node_port = var.node_port
    }
    type = "NodePort"
  }
}

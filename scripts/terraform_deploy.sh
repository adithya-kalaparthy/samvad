#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

echo ""
echo "🚀 SAMVAD Terraform deployment — let's go!"
echo ""

echo "🏗️  Step 1: Building the Docker image..."
echo "   (docker build -t samvad-api:latest .)"
docker build -t samvad-api:latest .

echo ""
echo "🏁 Step 2: Checking minikube is awake..."
minikube status > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "   ❌ Minikube is not running! Start it first:"
  echo "      minikube start --driver docker"
  exit 1
fi
echo "   ✅ Minikube is running."

echo ""
echo "📦 Step 3: Loading image into minikube's belly..."
echo "   (minikube image load samvad-api:latest)"
minikube image load samvad-api:latest

echo ""
echo "📋 Step 4: Initializing Terraform..."
echo "   (terraform -chdir=terraform/local init)"
terraform -chdir=terraform/local init

echo ""
echo "👀 Step 5: Showing the plan (review before applying)..."
echo "   (terraform -chdir=terraform/local plan)"
terraform -chdir=terraform/local plan

echo ""
echo "🛠️  Step 6: Applying the configuration..."
echo "   (terraform -chdir=terraform/local apply -auto-approve)"
terraform -chdir=terraform/local apply -auto-approve

# Extract the host port and service port from terraform variables
HOST_PORT=$(terraform -chdir=terraform/local output -raw host_port 2>/dev/null || echo "8080")
SERVICE_PORT=$(terraform -chdir=terraform/local output -raw service_port 2>/dev/null || echo "80")

echo ""
echo "🔌 Step 7: Opening port-forward tunnel in the background..."
echo "   (kubectl port-forward -n samvad-dev service/samvad-api-service ${HOST_PORT}:${SERVICE_PORT})"
kubectl port-forward -n samvad-dev service/samvad-api-service "${HOST_PORT}:${SERVICE_PORT}" > /dev/null 2>&1 &

echo ""
echo "🎉 All done! Test with: curl http://localhost:${HOST_PORT}/api/v1/health"
echo "    Stop the tunnel with: kill %1  OR  ./scripts/terraform_destroy.sh"

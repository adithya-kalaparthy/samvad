#!/bin/bash
set -e

# Make the script work no matter where you call it from.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$REPO_ROOT"

echo "🚀 Welcome to the SAMVAD local deployment circus!"
echo ""

echo "🏗️  Step 1: Firing up the minikube rocket..."
echo "   (minikube start --driver docker)"
minikube start --driver docker

echo ""
echo "📦 Step 2: Loading the image into minikube's belly..."
echo "   (minikube image load samvad-api:latest)"
minikube image load samvad-api:latest

echo ""
echo "🌍 Step 3: Creating the samvad-dev namespace..."
echo "   (kubectl apply -f k8s/local/namespace.yaml)"
kubectl apply -f k8s/local/namespace.yaml

echo ""
echo "🤫 Step 4: Pushing secrets (ssh, don't tell anyone)..."
echo "   (kubectl apply -f k8s/local/secret.yaml)"
kubectl apply -f k8s/local/secret.yaml

echo ""
echo "🤖 Step 5: Deploying the API (it's alive!)..."
echo "   (kubectl apply -f k8s/local/deployment.yaml)"
kubectl apply -f k8s/local/deployment.yaml

echo ""
echo "🌐 Step 6: Exposing the service to the world (or just your laptop)..."
echo "   (kubectl apply -f k8s/local/service.yaml)"
kubectl apply -f k8s/local/service.yaml

echo ""
echo "🔌 Step 7: Opening the tunnel in the background — localhost:8080 ready!"
echo "   (kubectl port-forward -n samvad-dev service/samvad-api-service 8080:80 &)"
kubectl port-forward -n samvad-dev service/samvad-api-service 8080:80 > /dev/null 2>&1 &

echo ""
echo "🎉 All done! Test with: curl http://localhost:8080/api/v1/health"
echo "    Stop the tunnel with: kill %1  OR  pkill kubectl"

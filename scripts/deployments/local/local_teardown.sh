#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$REPO_ROOT"

echo ""
echo "💥 SAMVAD teardown — cleaning up the mess!"
echo ""

echo "🧹 Step 1: Killing the port-forward tunnel..."
pkill -f "kubectl port-forward.*samvad-api-service" 2>/dev/null || echo "   No tunnel found, skipping."

echo ""
echo "🎯 Step 2: Switching to samvad-local context..."
kubectl config use-context samvad-local 2>/dev/null || echo "   Context not found, using current context."

echo ""
echo "🗑️  Step 3: Deleting everything in samvad-dev namespace..."
kubectl delete deployment,service,secret --all

echo ""
echo "🧊 Step 4: Deleting the namespace..."
echo "   (kubectl delete namespace samvad-dev)"
kubectl delete namespace samvad-dev

echo ""
echo "⏹️  Step 5: Stopping minikube..."
echo "   (minikube stop)"
minikube stop

echo ""
echo "🧹 Step 6: Cleaning up samvad-local context..."
kubectl config delete-context samvad-local 2>/dev/null || echo "   Already gone."
kubectl config use-context minikube 2>/dev/null || true

echo ""
echo "🔥 All gone! Bye bye SAMVAD."
echo "    To rebuild: ./scripts/deployments/local/local_deploy.sh"

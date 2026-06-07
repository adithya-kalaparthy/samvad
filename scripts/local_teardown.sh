#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

echo ""
echo "💥 SAMVAD teardown — cleaning up the mess!"
echo ""

echo "🧹 Step 1: Killing the port-forward tunnel..."
pkill -f "kubectl port-forward.*samvad-api-service" 2>/dev/null || echo "   No tunnel found, skipping."

echo ""
echo "🗑️  Step 2: Deleting everything in samvad-dev namespace..."
echo "   (kubectl delete deployment,service,secret --all -n samvad-dev)"
kubectl delete deployment,service,secret --all -n samvad-dev

echo ""
echo "🧊 Step 3: Deleting the namespace..."
echo "   (kubectl delete namespace samvad-dev)"
kubectl delete namespace samvad-dev

echo ""
echo "⏹️  Step 4: Stopping minikube..."
echo "   (minikube stop)"
minikube stop

echo ""
echo "🔥 All gone! Bye bye SAMVAD."
echo "   To rebuild: ./scripts/local_deploy.sh"

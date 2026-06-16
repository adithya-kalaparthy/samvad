#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$REPO_ROOT"

echo ""
echo "💥 SAMVAD Terraform teardown — cleaning up!"
echo ""

echo "🧹 Step 1: Killing the port-forward tunnel..."
pkill -f "kubectl port-forward.*samvad-api-service" 2>/dev/null || echo "   No tunnel found, skipping."

echo ""
echo "🗑️  Step 2: Destroying everything with Terraform..."
echo "   (terraform -chdir=terraform/environments/local destroy -auto-approve)"
terraform -chdir=terraform/environments/local destroy -auto-approve

echo ""
echo "🔥 All gone! Bye bye SAMVAD."
echo "    To rebuild: ./scripts/deployments/local/terraform_deploy.sh"

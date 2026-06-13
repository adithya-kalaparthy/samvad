#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

echo ""
echo "💥 SAMVAD Terraform teardown — cleaning up!"
echo ""

echo "🧹 Step 1: Killing the port-forward tunnel..."
pkill -f "kubectl port-forward.*samvad-api-service" 2>/dev/null || echo "   No tunnel found, skipping."

echo ""
echo "🗑️  Step 2: Destroying everything with Terraform..."
echo "   (terraform -chdir=terraform/local destroy -auto-approve)"
terraform -chdir=terraform/local destroy -auto-approve

echo ""
echo "🔥 All gone! Bye bye SAMVAD."
echo "    To rebuild: ./scripts/terraform_deploy.sh"

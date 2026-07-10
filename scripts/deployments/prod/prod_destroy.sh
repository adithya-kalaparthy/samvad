#!/usr/bin/env bash

set -euo pipefail                         # 💥 Stop on any error, undefined var, or pipe fail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
K8S_DIR="$SCRIPT_DIR/../../../k8s/prod"  
AWS_PROFILE="${AWS_PROFILE:-default}"

# --- step 1: aws login ---
echo "🔑 logging into aws sso..."
aws sso login --profile "$AWS_PROFILE"

# --- step 2: delete the cluster. ---
eksctl delete cluster -f "$K8S_DIR/cluster_config.yaml" --wait

echo "✅ Production deletion complete!"
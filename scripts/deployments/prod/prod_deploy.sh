#!/usr/bin/env bash

set -euo pipefail                         # 💥 Stop on any error, undefined var, or pipe fail

AWS_PROFILE="${AWS_PROFILE:-default}"
AWS_REGION="${AWS_REGION:-ap-south-1}"    # 🌍 Mumbai
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

K8S_DIR="$SCRIPT_DIR/../../../k8s/prod"
CLUSTER_NAME="samvad-cluster"
CONTEXT_NAME="samvad-prod"
NAMESPACE="samvad-prod"

# --- Step 0: Fail Fast Checks ---
if [ ! -f "$K8S_DIR/secret.yaml" ]; then
  echo "❌ ERROR: $K8S_DIR/secret.yaml is missing!"
  echo "Please create it with before deploying."
  exit 1
fi
echo "✅ Prerequisites met. Let's build."

# --- step 1: aws login ---
echo "🔑 logging into aws sso..."
aws sso login --profile "$AWS_PROFILE"

# --- step 2: create the eks cluster ---
echo "🚀 building cluster (this will take 15-20 minutes)..."
eksctl create cluster -f "$K8S_DIR/cluster_config.yaml"

# --- step 3: discover cluster info dynamically ---
echo "🔍 extracting cluster context..."
EKSCTL_CLUSTER=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
EKSCTL_USER=$(kubectl config view --minify -o jsonpath='{.users[0].name}')

# --- step 4: ensure namespace exists ---
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
  echo "🔨 namespace '$NAMESPACE' does not exist. creating it..."
  kubectl create namespace "$NAMESPACE"
else
  echo "✅ namespace '$NAMESPACE' already exists."
fi

# --- Step 5: Create & Switch to samvad-prod Context ---
kubectl config set-context "$CONTEXT_NAME" \
  --namespace="$NAMESPACE" \
  --cluster="$EKSCTL_CLUSTER" \
  --user="$EKSCTL_USER"

kubectl config use-context "$CONTEXT_NAME"

# --- Step 6: Deploy Secrets ---
echo "🔒 Applying Secrets..."
kubectl apply -f "$K8S_DIR/secret.yaml" --server-side --force-conflicts

# --- Step 7: Deploy the Application ---
echo "📦 Applying Application Deployment..."
kubectl apply -f "$K8S_DIR/deployment.yaml" --server-side --force-conflicts

# --- Step 8: Expose the Service ---
echo "🌐 Applying Service..."
kubectl apply -f "$K8S_DIR/service.yaml" --server-side --force-conflicts

# --- Step 9: Wait for Readiness ---
echo "⏳ Waiting for Fargate micro-VMs to boot and report Ready..."
kubectl wait --for=condition=Available --timeout=300s deployment/samvad-api-deployment -n "$NAMESPACE"

# --- Step 10: Victory Lap ---
echo "✅ Production deployment complete!"

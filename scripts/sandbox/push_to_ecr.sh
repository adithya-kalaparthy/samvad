set -euo pipefail

REGION="ap-south-1"
ACCOUNT="572391417926"
REPO_NAME="samvad-api"
IMAGE_TAG="latest"
ECR_URI="$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME"

echo "---- Authenticating with ECR ----"
aws ecr get-login-password --region "$REGION" | \
  docker login --username AWS --password-stdin "$ECR_URI"

echo "---- Building Docker image ----"
docker build -t "$REPO_NAME:$IMAGE_TAG" ../../.

echo "---- Tagging image with ECR URI ----"
docker tag "$REPO_NAME:$IMAGE_TAG" "$ECR_URI:$IMAGE_TAG"

echo "---- Pushing to ECR ----"
docker push "$ECR_URI:$IMAGE_TAG"
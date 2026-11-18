#!/usr/bin/env bash

# Creation / updating of the Secret
#./scripts/create-k8s-secret.sh
#
## Deployment Kubernetes
#kubectl apply -f k8s/

set -Eeuo pipefail

# ==========================================
# Configuration
# ==========================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${PROJECT_ROOT}/.env"

SECRET_NAME="workshop-organizer-db-secret"
NAMESPACE="${K8S_NAMESPACE:-default}"

# ==========================================
# Prerequisites
# ==========================================

if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl is not installed."
    exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
    echo "ERROR: .env file not found: $ENV_FILE"
    exit 1
fi

# ==========================================
# Load environment variables
# ==========================================

set -a
source "$ENV_FILE"
set +a

: "${DB_USER:?DB_USER is missing in .env}"
: "${DB_PASSWORD:?DB_PASSWORD is missing in .env}"

# ==========================================
# Create or update Kubernetes Secret
# ==========================================

kubectl create secret generic "$SECRET_NAME" \
    --namespace="$NAMESPACE" \
    --from-literal=username="$DB_USER" \
    --from-literal=password="$DB_PASSWORD" \
    --dry-run=client -o yaml |
    kubectl apply -f -

echo "Kubernetes Secret '$SECRET_NAME' successfully applied in namespace '$NAMESPACE'."
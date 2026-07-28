#!/usr/bin/env bash
set -euo pipefail

: "${GHCR_USERNAME:?Set GHCR_USERNAME to the GitHub account or organization user}"
: "${GHCR_TOKEN:?Set GHCR_TOKEN to a token with read:packages access}"

registry_email="${GHCR_EMAIL:-noreply@stonetusker.com}"
secret_name="${GHCR_SECRET_NAME:-ghcr-pull-secret}"

namespaces=(
  demo-service-development
  demo-service-staging
  demo-service-production
)

for namespace in "${namespaces[@]}"; do
  kubectl create namespace "${namespace}" \
    --dry-run=client \
    -o yaml | kubectl apply -f - >/dev/null

  kubectl create secret docker-registry "${secret_name}" \
    --namespace "${namespace}" \
    --docker-server=ghcr.io \
    --docker-username="${GHCR_USERNAME}" \
    --docker-password="${GHCR_TOKEN}" \
    --docker-email="${registry_email}" \
    --dry-run=client \
    -o yaml | kubectl apply -f - >/dev/null

  echo "Configured ${secret_name} in ${namespace}"
done

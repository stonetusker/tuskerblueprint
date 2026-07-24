#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${BACKSTAGE_NAMESPACE:-backstage}"

read -r -p "GitHub OAuth client ID: " CLIENT_ID
read -r -s -p "GitHub OAuth client secret: " CLIENT_SECRET
echo

if [[ -z "${CLIENT_ID}" || -z "${CLIENT_SECRET}" ]]; then
  echo "Client ID and client secret are required" >&2
  exit 1
fi

BACKEND_SECRET="$(openssl rand -hex 32)"

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic backstage-auth-secrets \
  --namespace "${NAMESPACE}" \
  --from-literal=AUTH_GITHUB_CLIENT_ID="${CLIENT_ID}" \
  --from-literal=AUTH_GITHUB_CLIENT_SECRET="${CLIENT_SECRET}" \
  --from-literal=BACKEND_SECRET="${BACKEND_SECRET}" \
  --dry-run=client -o yaml | kubectl apply -f -

unset CLIENT_SECRET BACKEND_SECRET

echo "Created or updated ${NAMESPACE}/backstage-auth-secrets"

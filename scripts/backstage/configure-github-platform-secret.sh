#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${BACKSTAGE_NAMESPACE:-backstage}"
SECRET_NAME="${BACKSTAGE_GITHUB_SECRET_NAME:-backstage-github-credentials}"

for command_name in kubectl; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Required command not found: ${command_name}" >&2
    exit 1
  fi
done

read -r -s -p "GitHub platform/scaffolder token: " GITHUB_PLATFORM_TOKEN
echo

if [[ -z "${GITHUB_PLATFORM_TOKEN}" ]]; then
  echo "A GitHub platform token is required" >&2
  exit 1
fi

kubectl create namespace "${NAMESPACE}" \
  --dry-run=client \
  -o yaml |
  kubectl apply -f -

kubectl create secret generic "${SECRET_NAME}" \
  --namespace "${NAMESPACE}" \
  --from-literal=GITHUB_TOKEN="${GITHUB_PLATFORM_TOKEN}" \
  --from-literal=GITHUB_SCAFFOLDER_TOKEN="${GITHUB_PLATFORM_TOKEN}" \
  --dry-run=client \
  -o yaml |
  kubectl apply -f -

unset GITHUB_PLATFORM_TOKEN

echo "Created or updated ${NAMESPACE}/${SECRET_NAME}"
echo "Restart or resync Backstage so the environment variable is refreshed."

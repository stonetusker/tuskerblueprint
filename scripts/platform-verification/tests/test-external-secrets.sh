#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

required_paths=(
  "$ROOT_DIR/platform-services/external-secrets/README.md"
  "$ROOT_DIR/platform-services/external-secrets/values/development.yaml"
  "$ROOT_DIR/platform-services/external-secrets/values/staging.yaml"
  "$ROOT_DIR/platform-services/external-secrets/values/production.yaml"
  "$ROOT_DIR/gitops/applications/platform/security/external-secrets/application-development.yaml"
  "$ROOT_DIR/gitops/applications/platform/security/external-secrets/application-staging.yaml"
  "$ROOT_DIR/gitops/applications/platform/security/external-secrets/application-production.yaml"
  "$ROOT_DIR/scripts/platform-verification/security/verify-external-secrets.sh"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required file: $path" >&2
    exit 1
  fi
done

echo "External Secrets capability scaffold is present."

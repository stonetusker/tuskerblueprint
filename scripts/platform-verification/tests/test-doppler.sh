#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

required_paths=(
  "$ROOT_DIR/platform-services/doppler/README.md"
  "$ROOT_DIR/platform-services/doppler/values/development.yaml"
  "$ROOT_DIR/platform-services/doppler/values/staging.yaml"
  "$ROOT_DIR/platform-services/doppler/values/production.yaml"
  "$ROOT_DIR/gitops/applications/platform/security/doppler/application-development.yaml"
  "$ROOT_DIR/gitops/applications/platform/security/doppler/application-staging.yaml"
  "$ROOT_DIR/gitops/applications/platform/security/doppler/application-production.yaml"
  "$ROOT_DIR/scripts/platform-verification/security/verify-doppler.sh"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required file: $path" >&2
    exit 1
  fi
done

echo "Doppler capability scaffold is present."

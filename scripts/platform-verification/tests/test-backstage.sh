#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

required_paths=(
  "$ROOT_DIR/platform-services/backstage/README.md"
  "$ROOT_DIR/platform-services/backstage/values/development.yaml"
  "$ROOT_DIR/platform-services/backstage/values/staging.yaml"
  "$ROOT_DIR/platform-services/backstage/values/production.yaml"
  "$ROOT_DIR/gitops/applications/platform/developer-platform/backstage/application-development.yaml"
  "$ROOT_DIR/gitops/applications/platform/developer-platform/backstage/application-staging.yaml"
  "$ROOT_DIR/gitops/applications/platform/developer-platform/backstage/application-production.yaml"
  "$ROOT_DIR/scripts/platform-verification/developer-platform/verify-backstage.sh"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required file: $path" >&2
    exit 1
  fi
done

echo "Backstage capability scaffold is present."

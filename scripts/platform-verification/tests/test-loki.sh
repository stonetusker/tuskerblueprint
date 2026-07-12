#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

required_paths=(
  "$ROOT_DIR/platform-services/loki/README.md"
  "$ROOT_DIR/platform-services/loki/values/development.yaml"
  "$ROOT_DIR/platform-services/loki/values/staging.yaml"
  "$ROOT_DIR/platform-services/loki/values/production.yaml"
  "$ROOT_DIR/gitops/applications/platform/observability/loki/application-development.yaml"
  "$ROOT_DIR/gitops/applications/platform/observability/loki/application-staging.yaml"
  "$ROOT_DIR/gitops/applications/platform/observability/loki/application-production.yaml"
  "$ROOT_DIR/scripts/platform-verification/observability/verify-loki.sh"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required file: $path" >&2
    exit 1
  fi
done

echo "Loki capability scaffold is present."

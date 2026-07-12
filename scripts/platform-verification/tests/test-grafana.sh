#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

required_paths=(
  "$ROOT_DIR/platform-services/grafana/README.md"
  "$ROOT_DIR/platform-services/grafana/values/development.yaml"
  "$ROOT_DIR/platform-services/grafana/values/staging.yaml"
  "$ROOT_DIR/platform-services/grafana/values/production.yaml"
  "$ROOT_DIR/gitops/applications/platform/observability/grafana/application-development.yaml"
  "$ROOT_DIR/gitops/applications/platform/observability/grafana/application-staging.yaml"
  "$ROOT_DIR/gitops/applications/platform/observability/grafana/application-production.yaml"
  "$ROOT_DIR/scripts/platform-verification/observability/verify-grafana.sh"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required file: $path" >&2
    exit 1
  fi
done

echo "Grafana capability scaffold is present."

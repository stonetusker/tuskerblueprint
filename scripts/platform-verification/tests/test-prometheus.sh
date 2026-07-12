#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

required_paths=(
  "$ROOT_DIR/platform-services/prometheus/README.md"
  "$ROOT_DIR/platform-services/prometheus/values/development.yaml"
  "$ROOT_DIR/platform-services/prometheus/values/staging.yaml"
  "$ROOT_DIR/platform-services/prometheus/values/production.yaml"
  "$ROOT_DIR/gitops/applications/platform/observability/prometheus/application-development.yaml"
  "$ROOT_DIR/gitops/applications/platform/observability/prometheus/application-staging.yaml"
  "$ROOT_DIR/gitops/applications/platform/observability/prometheus/application-production.yaml"
  "$ROOT_DIR/scripts/platform-verification/observability/verify-prometheus.sh"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required file: $path" >&2
    exit 1
  fi
done

echo "Prometheus capability scaffold is present."

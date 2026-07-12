#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

required_paths=(
  "$ROOT_DIR/platform-services/kyverno/README.md"
  "$ROOT_DIR/platform-services/kyverno/values/development.yaml"
  "$ROOT_DIR/platform-services/kyverno/values/staging.yaml"
  "$ROOT_DIR/platform-services/kyverno/values/production.yaml"
  "$ROOT_DIR/gitops/applications/platform/security/kyverno/application-development.yaml"
  "$ROOT_DIR/gitops/applications/platform/security/kyverno/application-staging.yaml"
  "$ROOT_DIR/gitops/applications/platform/security/kyverno/application-production.yaml"
  "$ROOT_DIR/scripts/platform-verification/security/verify-kyverno.sh"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required file: $path" >&2
    exit 1
  fi
done

echo "Kyverno capability scaffold is present."

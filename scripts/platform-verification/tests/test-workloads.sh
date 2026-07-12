#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

required_paths=(
  "$ROOT_DIR/gitops/applications/workloads/kustomization.yaml"
  "$ROOT_DIR/gitops/applications/workloads/reference-workload.yaml"
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "Missing required file: $path" >&2
    exit 1
  fi
done

echo "Workload scaffold is present."

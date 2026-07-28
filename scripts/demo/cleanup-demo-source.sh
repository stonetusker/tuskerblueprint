#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ ! -f "${repo_root}/catalog-info.yaml" ]]; then
  echo "Could not confirm the TuskerBlueprint repository root: ${repo_root}" >&2
  exit 1
fi

# Obsolete NGINX content from the earlier static demo workload.
rm -rf "${repo_root}/workloads/demo-service/base/content"

# Local validation artifacts that must not be committed or packaged.
find \
  "${repo_root}/workloads/demo-service" \
  "${repo_root}/software-templates/tusker-service" \
  "${repo_root}/scripts" \
  -type d \
  \( -name __pycache__ -o -name .pytest_cache -o -name .mypy_cache -o -name .ruff_cache \) \
  -prune \
  -exec rm -rf {} +

find \
  "${repo_root}/workloads/demo-service" \
  "${repo_root}/software-templates/tusker-service" \
  "${repo_root}/scripts" \
  -type f \
  \( -name '*.pyc' -o -name '.coverage' -o -name 'coverage.xml' -o -name '.DS_Store' \) \
  -delete

echo "Removed obsolete NGINX content and local validation artifacts."

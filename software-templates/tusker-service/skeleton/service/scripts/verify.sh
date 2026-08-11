#!/usr/bin/env bash
set -euo pipefail

python -m pip install -r requirements-dev.txt
python scripts/validate_repository.py
ruff format --check app tests
ruff check app tests
mypy app
pytest \
  --cov=app \
  --cov-branch \
  --cov-report=term-missing \
  --cov-report=xml \
  --cov-fail-under=85

if command -v kubectl >/dev/null 2>&1; then
  kubectl kustomize deploy/overlays/development >/dev/null
elif command -v kustomize >/dev/null 2>&1; then
  kustomize build deploy/overlays/development >/dev/null
else
  echo "kubectl or kustomize is required to render Kubernetes manifests" >&2
  exit 1
fi

echo "Local verification passed"

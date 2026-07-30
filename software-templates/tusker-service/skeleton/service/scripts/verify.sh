#!/usr/bin/env bash
set -euo pipefail

python -m pip install -r requirements-dev.txt
ruff format --check src tests
ruff check src tests
mypy src
pytest \
  --cov=src \
  --cov-branch \
  --cov-report=term-missing \
  --cov-fail-under=80

kubectl kustomize deploy/overlays/development >/dev/null

echo "Local verification passed"

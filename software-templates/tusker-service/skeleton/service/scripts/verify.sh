#!/usr/bin/env bash
set -euo pipefail

python -m pip install -r requirements-dev.txt
ruff format --check app tests
ruff check app tests
mypy app
pytest \
  --cov=app \
  --cov-branch \
  --cov-report=term-missing \
  --cov-fail-under=80

kubectl kustomize deploy/overlays/development >/dev/null

echo "Local verification passed"

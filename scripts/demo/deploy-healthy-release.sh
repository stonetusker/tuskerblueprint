#!/usr/bin/env bash
set -euo pipefail

python3 scripts/demo/set-demo-failure-mode.py \
  --environment development \
  --mode none

cat <<'MESSAGE'
Prepared healthy desired state. Review, commit, and merge through Git:
  git diff -- workloads/demo-service/overlays/development/kustomization.yaml
  git add workloads/demo-service/overlays/development/kustomization.yaml
  git commit -m "demo: restore healthy failure mode"
  git push -u origin HEAD
MESSAGE

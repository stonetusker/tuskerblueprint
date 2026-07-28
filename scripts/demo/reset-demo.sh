#!/usr/bin/env bash
set -euo pipefail

: "${GOOD_SHA:?Set GOOD_SHA to the full 40-character last-known-good image SHA}"

python3 scripts/demo/set-demo-release.py \
  --environment development \
  --release "${GOOD_SHA}"
python3 scripts/demo/set-demo-failure-mode.py \
  --environment development \
  --mode none

cat <<MESSAGE
Reset desired state prepared for ${GOOD_SHA}.
Review and commit the overlay before the demo:
  git diff -- workloads/demo-service/overlays/development/kustomization.yaml
  git add workloads/demo-service/overlays/development/kustomization.yaml
  git commit -m "demo: reset to known-good release"
  git push -u origin HEAD
MESSAGE

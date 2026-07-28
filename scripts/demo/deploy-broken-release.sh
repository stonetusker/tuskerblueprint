#!/usr/bin/env bash
set -euo pipefail

mode="${1:-readiness}"
case "${mode}" in
  readiness|errors|latency) ;;
  *) echo "Usage: $0 [readiness|errors|latency]" >&2; exit 2 ;;
esac

python3 scripts/demo/set-demo-failure-mode.py \
  --environment development \
  --mode "${mode}"

cat <<MESSAGE
Prepared controlled '${mode}' failure in Git desired state.

Review and commit it through a pull request:
  git diff -- workloads/demo-service/overlays/development/kustomization.yaml
  git add workloads/demo-service/overlays/development/kustomization.yaml
  git commit -m "demo: enable ${mode} failure mode"
  git push -u origin HEAD

After merge, watch:
  argocd app get demo-service-development --refresh
  kubectl -n demo-service-development get pods -w
MESSAGE

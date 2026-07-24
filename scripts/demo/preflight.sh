#!/usr/bin/env bash
set -euo pipefail

fail=0
for app in backstage demo-service-development; do
  sync="$(kubectl get application "${app}" -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  health="$(kubectl get application "${app}" -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
  printf '%-32s sync=%-10s health=%s\n' "${app}" "${sync:-missing}" "${health:-missing}"
  [[ "${sync}" == "Synced" && "${health}" == "Healthy" ]] || fail=1
done

if [[ ${fail} -ne 0 ]]; then
  echo "Demo preflight failed" >&2
  exit 1
fi

echo "Demo preflight passed"

#!/usr/bin/env bash
set -euo pipefail

namespace="${DEMO_NAMESPACE:-demo-service-development}"
deployment="${DEMO_DEPLOYMENT:-demo-service}"
timeout_seconds="${DEMO_DRIFT_TIMEOUT_SECONDS:-180}"

desired_replicas="$(kubectl -n "${namespace}" get deployment "${deployment}" -o jsonpath='{.spec.replicas}')"
if [[ ! "${desired_replicas}" =~ ^[0-9]+$ ]]; then
  echo "ERROR: could not read the Git-declared replica count" >&2
  exit 1
fi

drifted_replicas=$((desired_replicas + 1))
kubectl -n "${namespace}" scale deployment "${deployment}" \
  --replicas="${drifted_replicas}"

printf 'Introduced drift: %s/%s replicas %s -> %s\n' \
  "${namespace}" "${deployment}" "${desired_replicas}" "${drifted_replicas}"
echo "Waiting for Argo CD self-heal to restore the Git-declared count..."

deadline=$((SECONDS + timeout_seconds))
while (( SECONDS < deadline )); do
  live_replicas="$(kubectl -n "${namespace}" get deployment "${deployment}" -o jsonpath='{.spec.replicas}')"
  if [[ "${live_replicas}" == "${desired_replicas}" ]]; then
    echo "Argo CD self-heal restored the deployment."
    kubectl -n "${namespace}" rollout status "deployment/${deployment}" --timeout=120s
    exit 0
  fi
  sleep 3
done

echo "ERROR: Argo CD did not restore the deployment within ${timeout_seconds}s" >&2
kubectl -n argocd get application "${deployment}-development" \
  -o custom-columns='SYNC:.status.sync.status,HEALTH:.status.health.status' >&2 || true
exit 1

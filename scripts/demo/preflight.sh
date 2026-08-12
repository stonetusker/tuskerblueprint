#!/usr/bin/env bash
set -euo pipefail

fail=0
warn=0
alloy_argocd_healthy=1

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $1" >&2
    fail=1
  fi
}

require_command kubectl
require_command curl

if [[ ${fail} -ne 0 ]]; then
  exit 1
fi

printf 'Kubernetes context: %s\n' "$(kubectl config current-context)"

print_alloy_diagnostics() {
  local pod_name restart_count
  local -a alloy_pods=()

  echo "Alloy rollout diagnostics" >&2
  kubectl -n monitoring get daemonset alloy -o wide >&2 || true
  kubectl -n monitoring get pods \
    -l app.kubernetes.io/name=alloy \
    -o wide >&2 || true

  mapfile -t alloy_pods < <(
    kubectl -n monitoring get pods \
      -l app.kubernetes.io/name=alloy \
      -o name 2>/dev/null || true
  )

  if [[ ${#alloy_pods[@]} -eq 0 ]]; then
    echo "  No Alloy Pods were scheduled." >&2
  fi

  for pod_name in "${alloy_pods[@]}"; do
    printf '\nEvents for %s\n' "${pod_name}" >&2
    kubectl -n monitoring describe "${pod_name}" \
      | sed -n '/Events:/,$p' >&2 || true

    printf '\nCurrent Alloy log for %s\n' "${pod_name}" >&2
    kubectl -n monitoring logs "${pod_name}" -c alloy --tail=120 >&2 || true

    restart_count="$(
      kubectl -n monitoring get "${pod_name}" \
        -o jsonpath='{.status.containerStatuses[?(@.name=="alloy")].restartCount}' \
        2>/dev/null || true
    )"
    if [[ "${restart_count:-0}" =~ ^[1-9][0-9]*$ ]]; then
      printf '\nPrevious Alloy log for %s\n' "${pod_name}" >&2
      kubectl -n monitoring logs "${pod_name}" -c alloy \
        --previous --tail=120 >&2 || true
    fi
  done

  printf '\nAlloy service-account permission for pods/log: ' >&2
  kubectl auth can-i get pods/log \
    --as=system:serviceaccount:monitoring:alloy >&2 || true
}

check_application() {
  local app="$1"
  local sync health
  sync="$(kubectl get application "${app}" -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  health="$(kubectl get application "${app}" -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
  printf '%-32s sync=%-10s health=%s\n' "${app}" "${sync:-missing}" "${health:-missing}"

  if [[ "${app}" == "alloy" ]]; then
    [[ "${sync}" == "Synced" ]] || fail=1
    if [[ "${health}" != "Healthy" ]]; then
      alloy_argocd_healthy=0
    fi
    return
  fi

  [[ "${sync}" == "Synced" && "${health}" == "Healthy" ]] || fail=1
}

check_application backstage
check_application prometheus
check_application loki
check_application alloy
check_application grafana
check_application demo-service-development

alloy_rollout_timeout="${DEMO_ALLOY_ROLLOUT_TIMEOUT:-180s}"
if kubectl -n monitoring rollout status daemonset/alloy \
  --timeout="${alloy_rollout_timeout}"; then
  if [[ ${alloy_argocd_healthy} -ne 1 ]]; then
    echo "WARNING: Alloy Pods are ready but Argo CD health has not refreshed yet" >&2
    warn=1
  fi
else
  echo "ERROR: Alloy did not become ready within ${alloy_rollout_timeout}" >&2
  print_alloy_diagnostics
  fail=1
fi

if kubectl -n demo-service-development get secret ghcr-pull-secret >/dev/null 2>&1; then
  secret_type="$(kubectl -n demo-service-development get secret ghcr-pull-secret -o jsonpath='{.type}')"
  if [[ "${secret_type}" == "kubernetes.io/dockerconfigjson" ]]; then
    echo "GHCR pull Secret: configured through the platform credential flow"
  else
    echo "ERROR: demo-service-development/ghcr-pull-secret has unexpected type ${secret_type}" >&2
    fail=1
  fi
else
  echo "ERROR: demo-service-development/ghcr-pull-secret is missing" >&2
  echo "Sync external-secrets and github-access, then verify the workload ExternalSecret." >&2
  fail=1
fi

if ! kubectl -n demo-service-development rollout status deployment/demo-service --timeout=120s; then
  fail=1
fi

image="$(kubectl -n demo-service-development get deployment demo-service -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
printf 'Demo service image: %s\n' "${image:-missing}"

if [[ "${image}" == *":main" ]]; then
  if [[ "${ALLOW_MUTABLE_IMAGE:-0}" == "1" ]]; then
    echo "WARNING: development still uses the mutable main tag" >&2
    warn=1
  else
    echo "ERROR: development still uses :main; merge the immutable release PR first" >&2
    fail=1
  fi
fi

if kubectl -n backstage logs deployment/backstage --all-containers=true --tail=500 2>/dev/null \
  | grep -Eiq 'BackendStartupError|core\.auditor|core\.permissionsRegistry|startup failed|unhandled rejection|fatal'; then
  echo "ERROR: Backstage startup errors detected" >&2
  fail=1
fi

local_port="${DEMO_PREFLIGHT_PORT:-18081}"
kubectl -n demo-service-development port-forward service/demo-service "${local_port}:80" \
  >/tmp/tusker-demo-preflight-port-forward.log 2>&1 &
port_forward_pid=$!
cleanup() {
  kill "${port_forward_pid}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

ready=0
for _ in $(seq 1 20); do
  if curl -fsS "http://127.0.0.1:${local_port}/readyz" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 1
done

if [[ ${ready} -ne 1 ]]; then
  echo "ERROR: demo service readiness endpoint did not respond" >&2
  cat /tmp/tusker-demo-preflight-port-forward.log >&2 || true
  fail=1
else
  echo "Demo service readiness endpoint: OK"
fi

if [[ ${fail} -ne 0 ]]; then
  echo "Demo preflight failed" >&2
  exit 1
fi

if [[ ${warn} -ne 0 ]]; then
  echo "Demo preflight passed with warnings"
else
  echo "Demo preflight passed"
fi

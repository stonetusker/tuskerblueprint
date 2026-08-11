#!/usr/bin/env bash
set -euo pipefail

fail=0
warn=0

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $1" >&2
    fail=1
  fi
}

require_command kubectl
require_command curl
require_command grep

if [[ ${fail} -ne 0 ]]; then
  exit 1
fi

printf 'Kubernetes context: %s\n' "$(kubectl config current-context)"

check_application() {
  local app="$1"
  local sync health
  sync="$(kubectl get application "${app}" -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  health="$(kubectl get application "${app}" -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
  printf '%-32s sync=%-10s health=%s\n' "${app}" "${sync:-missing}" "${health:-missing}"
  [[ "${sync}" == "Synced" && "${health}" == "Healthy" ]] || fail=1
}

applications=(
  backstage
  backstage-platform-resources
  cert-manager
  demo-service-development
  external-secrets
  generated-workloads
  github-access
  grafana
  kyverno
  loki
  platform-root
  prometheus
  traefik-development
)
for application in "${applications[@]}"; do
  check_application "${application}"
done

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

ready_replicas="$(kubectl -n demo-service-development get deployment demo-service -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
desired_replicas="$(kubectl -n demo-service-development get deployment demo-service -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
printf 'Demo service replicas: ready=%s desired=%s\n' "${ready_replicas:-0}" "${desired_replicas:-missing}"
if [[ "${desired_replicas}" != "2" || "${ready_replicas:-0}" != "2" ]]; then
  echo "ERROR: the recorded demo requires two ready replicas" >&2
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

preflight_dir="$(mktemp -d "${TMPDIR:-/tmp}/tusker-demo-preflight.XXXXXX")"
port_forward_pids=()
cleanup() {
  local pid
  for pid in "${port_forward_pids[@]}"; do
    kill "${pid}" >/dev/null 2>&1 || true
  done
  rm -f \
    "${preflight_dir}/app.log" \
    "${preflight_dir}/grafana.log" \
    "${preflight_dir}/prometheus.log"
  rmdir "${preflight_dir}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

start_port_forward() {
  local namespace="$1"
  local service="$2"
  local mapping="$3"
  local log_file="$4"
  kubectl -n "${namespace}" port-forward "service/${service}" "${mapping}" \
    >"${log_file}" 2>&1 &
  port_forward_pids+=("$!")
}

wait_for_url() {
  local url="$1"
  local attempts="${2:-20}"
  local _
  for _ in $(seq 1 "${attempts}"); do
    if curl -fsS "${url}" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

app_port="${DEMO_PREFLIGHT_PORT:-18081}"
start_port_forward demo-service-development demo-service "${app_port}:80" "${preflight_dir}/app.log"
if wait_for_url "http://127.0.0.1:${app_port}/readyz"; then
  echo "Demo service readiness endpoint: OK"
else
  echo "ERROR: demo service readiness endpoint did not respond" >&2
  cat "${preflight_dir}/app.log" >&2 || true
  fail=1
fi

metrics="$(curl -fsS "http://127.0.0.1:${app_port}/metrics" 2>/dev/null || true)"
for metric in application_info http_requests_total http_request_duration_seconds; do
  if ! grep -q "^${metric}" <<<"${metrics}"; then
    echo "ERROR: application metrics are missing ${metric}" >&2
    fail=1
  fi
done

grafana_port="${GRAFANA_PREFLIGHT_PORT:-13000}"
start_port_forward grafana grafana "${grafana_port}:80" "${preflight_dir}/grafana.log"
if wait_for_url "http://127.0.0.1:${grafana_port}/api/health"; then
  echo "Grafana health endpoint: OK"
else
  echo "ERROR: Grafana health endpoint did not respond" >&2
  cat "${preflight_dir}/grafana.log" >&2 || true
  fail=1
fi

prometheus_port="${PROMETHEUS_PREFLIGHT_PORT:-19090}"
start_port_forward monitoring prometheus-server "${prometheus_port}:80" "${preflight_dir}/prometheus.log"
if wait_for_url "http://127.0.0.1:${prometheus_port}/-/ready"; then
  prometheus_response="$(curl -fsSG "http://127.0.0.1:${prometheus_port}/api/v1/query" \
    --data-urlencode 'query=application_info{service="demo-service",environment="development"}' || true)"
  if grep -q '"result":\[{' <<<"${prometheus_response}"; then
    echo "Prometheus has demo-service application_info data"
  else
    echo "ERROR: Prometheus has no demo-service application_info data" >&2
    fail=1
  fi
else
  echo "ERROR: Prometheus readiness endpoint did not respond" >&2
  cat "${preflight_dir}/prometheus.log" >&2 || true
  fail=1
fi

if kubectl -n monitoring get daemonset alloy >/dev/null 2>&1; then
  if kubectl -n monitoring rollout status daemonset/alloy --timeout=120s; then
    echo "Alloy log collection: ready"
  else
    echo "ERROR: Alloy log collection is not ready" >&2
    fail=1
  fi
else
  echo "WARNING: Alloy is not installed; use kubectl logs and state the limitation" >&2
  warn=1
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

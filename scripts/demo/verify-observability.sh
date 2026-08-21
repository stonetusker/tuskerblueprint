#!/usr/bin/env bash
set -euo pipefail

workload_namespace="${DEMO_NAMESPACE:-demo-service-development}"
workload_service="${DEMO_SERVICE:-demo-service}"
prometheus_port="${DEMO_PROMETHEUS_PORT:-19090}"
loki_port="${DEMO_LOKI_PORT:-13100}"
tempo_port="${DEMO_TEMPO_PORT:-13200}"
grafana_port="${DEMO_GRAFANA_PORT:-13000}"
application_port="${DEMO_VERIFY_APP_PORT:-18082}"

for command_name in kubectl curl jq; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "ERROR: required command not found: ${command_name}" >&2
    exit 1
  fi
done

failed=0
alloy_health_status=""
applications=(prometheus loki tempo alloy grafana demo-service-development)

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

printf 'Argo CD observability applications\n'
for application_name in "${applications[@]}"; do
  sync_status="$(kubectl -n argocd get application "${application_name}" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  health_status="$(kubectl -n argocd get application "${application_name}" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
  printf '  %-28s sync=%-10s health=%s\n' \
    "${application_name}" "${sync_status:-missing}" "${health_status:-missing}"

  if [[ "${application_name}" == "alloy" ]]; then
    alloy_health_status="${health_status}"
    if [[ "${sync_status}" != "Synced" ]]; then
      failed=1
    fi
  elif [[ "${sync_status}" != "Synced" || "${health_status}" != "Healthy" ]]; then
    failed=1
  fi
done

if [[ "${failed}" -ne 0 ]]; then
  echo "ERROR: reconcile the applications above before checking dashboard data" >&2
  exit 1
fi

printf '\nChecking the Alloy collector rollout\n'
alloy_rollout_timeout="${DEMO_ALLOY_ROLLOUT_TIMEOUT:-180s}"
if ! kubectl -n monitoring rollout status daemonset/alloy \
  --timeout="${alloy_rollout_timeout}"; then
  echo "ERROR: Alloy did not become ready within ${alloy_rollout_timeout}" >&2
  print_alloy_diagnostics
  exit 1
fi

if [[ "${alloy_health_status}" != "Healthy" ]]; then
  echo "WARNING: Alloy Pods are ready but Argo CD health has not refreshed yet" >&2
fi

work_dir="$(mktemp -d /tmp/tusker-observability.XXXXXX)"
port_forward_pids=()

cleanup() {
  local process_id
  for process_id in "${port_forward_pids[@]}"; do
    kill "${process_id}" >/dev/null 2>&1 || true
    wait "${process_id}" >/dev/null 2>&1 || true
  done
  rm -rf "${work_dir}"
}
trap cleanup EXIT

start_port_forward() {
  local namespace="$1"
  local service_name="$2"
  local mapping="$3"
  local label="$4"

  kubectl -n "${namespace}" port-forward "service/${service_name}" "${mapping}" \
    >"${work_dir}/${label}.log" 2>&1 &
  port_forward_pids+=("$!")
}

wait_for_http() {
  local url="$1"
  local label="$2"
  local log_file="$3"

  for _ in $(seq 1 30); do
    if curl -fsS "${url}" >/dev/null 2>&1; then
      printf '  %-28s ready\n' "${label}"
      return 0
    fi
    sleep 1
  done

  echo "ERROR: ${label} did not become reachable at ${url}" >&2
  sed -n '1,120p' "${log_file}" >&2 || true
  return 1
}

printf '\nStarting temporary read-only port-forwards\n'
start_port_forward monitoring prometheus-server "${prometheus_port}:80" prometheus
start_port_forward monitoring loki-gateway "${loki_port}:80" loki
start_port_forward monitoring tempo "${tempo_port}:3200" tempo
start_port_forward grafana grafana "${grafana_port}:80" grafana
start_port_forward "${workload_namespace}" "${workload_service}" "${application_port}:80" application

wait_for_http "http://127.0.0.1:${prometheus_port}/-/ready" Prometheus "${work_dir}/prometheus.log"
wait_for_http "http://127.0.0.1:${loki_port}/loki/api/v1/status/buildinfo" Loki "${work_dir}/loki.log"
wait_for_http "http://127.0.0.1:${tempo_port}/ready" Tempo "${work_dir}/tempo.log"
wait_for_http "http://127.0.0.1:${grafana_port}/api/health" Grafana "${work_dir}/grafana.log"
wait_for_http "http://127.0.0.1:${application_port}/readyz" "Demo service" "${work_dir}/application.log"

correlation_id="observability-verification"
curl -fsS "http://127.0.0.1:${application_port}/api/v1/notifications" \
  -H 'Content-Type: application/json' \
  -H "X-Correlation-ID: ${correlation_id}" \
  -H 'X-Demo-Request: observability-verification' \
  -d '{"channel":"webhook","recipient":"https://example.invalid/verify","message":"Observability verification request"}' \
  >/dev/null

prometheus_has_result() {
  local query="$1"
  local response

  response="$(curl -fsS --get "http://127.0.0.1:${prometheus_port}/api/v1/query" \
    --data-urlencode "query=${query}")" || return 1
  jq -e '.status == "success" and ((.data.result // []) | length > 0)' \
    >/dev/null <<<"${response}"
}

wait_for_prometheus_result() {
  local label="$1"
  local query="$2"

  for _ in $(seq 1 40); do
    if prometheus_has_result "${query}"; then
      printf '  %-28s data present\n' "${label}"
      return 0
    fi
    sleep 1
  done

  echo "ERROR: Prometheus query returned no series: ${label}" >&2
  echo "       ${query}" >&2
  return 1
}

printf '\nChecking the exact dashboard metric families\n'
wait_for_prometheus_result \
  "Application release" \
  "application_info{service=\"${workload_service}\",environment=\"development\"}"
wait_for_prometheus_result \
  "HTTP request metrics" \
  "http_requests_total{service=\"${workload_service}\",environment=\"development\"}"
wait_for_prometheus_result \
  "Product activity metric" \
  "notification_requests_total{service=\"${workload_service}\",environment=\"development\"}"
wait_for_prometheus_result \
  "Kubernetes deployment state" \
  "kube_deployment_status_replicas_available{namespace=\"${workload_namespace}\",deployment=\"${workload_service}\"}"

loki_has_result() {
  local query="$1"
  local response

  response="$(curl -fsS --get "http://127.0.0.1:${loki_port}/loki/api/v1/query_range" \
    --data-urlencode "query=${query}" \
    --data-urlencode 'since=30m' \
    --data-urlencode 'limit=20' \
    --data-urlencode 'direction=backward')" || return 1
  jq -e '.status == "success" and ((.data.result // []) | length > 0)' \
    >/dev/null <<<"${response}"
}

log_query="{namespace=\"${workload_namespace}\", app=\"${workload_service}\"} | json | message=\"request_completed\" | correlation_id=\"${correlation_id}\""
structured_metadata_query="{namespace=\"${workload_namespace}\", app=\"${workload_service}\"} | correlation_id = \"${correlation_id}\""

printf '\nChecking correlated application logs\n'
logs_found=0
for _ in $(seq 1 40); do
  if loki_has_result "${log_query}"; then
    logs_found=1
    break
  fi
  sleep 1
done

if [[ "${logs_found}" -ne 1 ]]; then
  echo "ERROR: Loki did not return the verification request" >&2
  echo "       ${log_query}" >&2
  print_alloy_diagnostics
  exit 1
fi
echo "  Correlation ID               searchable in Loki"

printf '\nChecking structured metadata and label cardinality\n'
structured_metadata_found=0
for _ in $(seq 1 40); do
  if loki_has_result "${structured_metadata_query}"; then
    structured_metadata_found=1
    break
  fi
  sleep 1
done

if [[ "${structured_metadata_found}" -ne 1 ]]; then
  echo "ERROR: Loki did not return the verification request through structured metadata" >&2
  echo "       ${structured_metadata_query}" >&2
  exit 1
fi

loki_labels="$(
  curl -fsS "http://127.0.0.1:${loki_port}/loki/api/v1/labels" \
    | jq -r '.data[]?'
)"
for high_cardinality_field in correlation_id trace_id; do
  if grep -Fxq "${high_cardinality_field}" <<<"${loki_labels}"; then
    echo "ERROR: ${high_cardinality_field} was indexed as a Loki label" >&2
    exit 1
  fi
done
echo "  Structured metadata          correlation_id query passed"
echo "  Loki label cardinality       request IDs absent from labels"

printf '\nObservability verification passed.\n'
echo "Open Grafana when ready: kubectl -n grafana port-forward service/grafana 3000:80"
echo "UI path: Dashboards > Stonetusker Demo > Stonetusker Demo Service | Golden Path"

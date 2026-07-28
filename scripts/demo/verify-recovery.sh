#!/usr/bin/env bash
set -euo pipefail

kubectl -n demo-service-development rollout status deployment/demo-service --timeout=300s

port="${DEMO_VERIFY_PORT:-18082}"
log_file="${TMPDIR:-/tmp}/tusker-demo-verify-port-forward.log"
kubectl -n demo-service-development port-forward service/demo-service "${port}:80" \
  >"${log_file}" 2>&1 &
pid=$!
trap 'kill "${pid}" >/dev/null 2>&1 || true' EXIT

ready=0
for _ in $(seq 1 20); do
  if ! kill -0 "${pid}" >/dev/null 2>&1; then
    echo "Port-forward stopped unexpectedly." >&2
    cat "${log_file}" >&2 || true
    exit 1
  fi

  if curl -fsS "http://127.0.0.1:${port}/readyz" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 1
done

if [[ "${ready}" -ne 1 ]]; then
  echo "Recovery readiness endpoint did not become healthy." >&2
  cat "${log_file}" >&2 || true
  exit 1
fi

curl -fsS "http://127.0.0.1:${port}/" | python3 -m json.tool
curl -fsS "http://127.0.0.1:${port}/readyz" | python3 -m json.tool

echo "Recovery verification passed"

#!/usr/bin/env bash
set -euo pipefail

namespace="${DEMO_NAMESPACE:-demo-service-development}"
service="${DEMO_SERVICE:-demo-service}"
local_port="${DEMO_UI_PORT:-8081}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "ERROR: kubectl is required" >&2
  exit 1
fi

if ! kubectl -n "${namespace}" get service "${service}" >/dev/null 2>&1; then
  echo "ERROR: service/${service} was not found in namespace ${namespace}" >&2
  exit 1
fi

cat <<MESSAGE
Stonetusker demo UI

Open: http://localhost:${local_port}/
API:  http://localhost:${local_port}/docs

Keep this terminal open. Press Ctrl+C to stop the port-forward.
MESSAGE

exec kubectl -n "${namespace}" port-forward "service/${service}" "${local_port}:80"

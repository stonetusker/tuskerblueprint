#!/usr/bin/env bash
set -euo pipefail

base_url="${DEMO_BASE_URL:-http://127.0.0.1:8081}"
requests="${DEMO_REQUESTS:-30}"
allow_failures="${DEMO_ALLOW_FAILURES:-0}"
succeeded=0
failed=0

for i in $(seq 1 "${requests}"); do
  correlation_id="demo-$(printf '%04d' "${i}")"
  if curl -fsS "${base_url}/api/v1/notifications" \
    -H 'Content-Type: application/json' \
    -H "X-Correlation-ID: ${correlation_id}" \
    -H 'X-Demo-Request: generated-traffic' \
    -d "{\"channel\":\"email\",\"recipient\":\"buyer-${i}@example.invalid\",\"message\":\"StoneTusker delivery demo request ${i}\"}" \
    >/dev/null; then
    succeeded=$((succeeded + 1))
  else
    failed=$((failed + 1))
  fi
  sleep 0.2
done

printf 'Traffic summary: requested=%s succeeded=%s failed=%s target=%s\n' \
  "${requests}" "${succeeded}" "${failed}" "${base_url}"

if [[ "${failed}" -gt 0 && "${allow_failures}" != "1" ]]; then
  echo "Traffic generation observed failures. Set DEMO_ALLOW_FAILURES=1 only for the controlled failure demonstration." >&2
  exit 1
fi

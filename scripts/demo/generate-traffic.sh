#!/usr/bin/env bash
set -euo pipefail

base_url="${DEMO_BASE_URL:-http://127.0.0.1:8081}"
requests_per_round="${DEMO_REQUESTS:-60}"
request_delay="${DEMO_REQUEST_DELAY_SECONDS:-0.25}"
round_delay="${DEMO_ROUND_DELAY_SECONDS:-5}"
continuous="${DEMO_CONTINUOUS:-0}"
allow_failures="${DEMO_ALLOW_FAILURES:-0}"

if ! command -v curl >/dev/null 2>&1; then
  echo "ERROR: curl is required" >&2
  exit 1
fi

if ! [[ "${requests_per_round}" =~ ^[1-9][0-9]*$ ]]; then
  echo "ERROR: DEMO_REQUESTS must be a positive integer" >&2
  exit 1
fi

channels=(email sms webhook)
round=0

send_round() {
  local succeeded=0
  local failed=0
  local i channel correlation_id recipient status_code

  round=$((round + 1))

  for i in $(seq 1 "${requests_per_round}"); do
    channel="${channels[$(((i - 1) % ${#channels[@]}))]}"
    correlation_id="demo-r$(printf '%03d' "${round}")-$(printf '%04d' "${i}")"

    case "${channel}" in
      email)
        recipient="buyer-${i}@example.invalid"
        ;;
      sms)
        recipient="+155500$(printf '%04d' "${i}")"
        ;;
      webhook)
        recipient="https://example.invalid/hooks/buyer-${i}"
        ;;
    esac

    status_code="$(curl -sS -o /dev/null -w '%{http_code}' \
      "${base_url}/api/v1/notifications" \
      -H 'Content-Type: application/json' \
      -H "X-Correlation-ID: ${correlation_id}" \
      -H 'X-Demo-Request: generated-traffic' \
      -d "{\"channel\":\"${channel}\",\"recipient\":\"${recipient}\",\"message\":\"Stonetusker golden-path demo request ${i}\"}" \
      || true)"

    if [[ "${status_code}" =~ ^2[0-9][0-9]$ ]]; then
      succeeded=$((succeeded + 1))
    else
      failed=$((failed + 1))
    fi

    # Mix writes with realistic customer reads so endpoint, method and latency
    # panels remain visually useful throughout a recorded demonstration.
    if ((i % 5 == 0)); then
      curl -sS -o /dev/null "${base_url}/api/v1/status" || true
    fi
    if ((i % 10 == 0)); then
      curl -sS -o /dev/null "${base_url}/api/v1/notifications?limit=10" || true
    fi

    sleep "${request_delay}"
  done

  printf 'Traffic round %s: requested=%s succeeded=%s failed=%s target=%s\n' \
    "${round}" "${requests_per_round}" "${succeeded}" "${failed}" "${base_url}"

  if [[ "${failed}" -gt 0 && "${allow_failures}" != "1" ]]; then
    echo "Traffic generation observed failures. Set DEMO_ALLOW_FAILURES=1 only for the controlled failure demonstration." >&2
    return 1
  fi
}

if [[ "${continuous}" == "1" ]]; then
  echo "Continuous demo traffic started. Press Ctrl+C to stop."
  while true; do
    send_round
    sleep "${round_delay}"
  done
else
  send_round
fi

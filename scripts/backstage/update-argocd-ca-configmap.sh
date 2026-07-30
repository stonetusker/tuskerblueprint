#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
BACKSTAGE_NAMESPACE="${BACKSTAGE_NAMESPACE:-backstage}"
ARGOCD_SERVICE_DNS="${ARGOCD_SERVICE_DNS:-argocd-server.argocd.svc.cluster.local}"
OUTPUT_FILE="${ROOT_DIR}/platform-services/backstage/manifests/argocd-ca-configmap.yaml"
TLS_SECRET="${ARGOCD_TLS_SECRET:-}"

for command_name in kubectl python3 openssl; do
  command -v "${command_name}" >/dev/null 2>&1 || {
    echo "ERROR: ${command_name} is required" >&2
    exit 1
  }
done

if [[ -z "${TLS_SECRET}" ]]; then
  for candidate in argocd-server-tls argocd-secret; do
    encoded="$(
      kubectl -n "${ARGOCD_NAMESPACE}" get secret "${candidate}" \
        -o jsonpath='{.data.tls\.crt}' 2>/dev/null || true
    )"
    if [[ -n "${encoded}" ]]; then
      TLS_SECRET="${candidate}"
      break
    fi
  done
fi

if [[ -z "${TLS_SECRET}" ]]; then
  echo "ERROR: neither argocd-server-tls nor argocd-secret contains tls.crt" >&2
  echo "Secrets in ${ARGOCD_NAMESPACE} that contain tls.crt:" >&2
  kubectl -n "${ARGOCD_NAMESPACE}" get secrets -o json \
    | python3 -c '
import json
import sys

data = json.load(sys.stdin)
for item in data.get("items", []):
    if "tls.crt" in (item.get("data") or {}):
        print(item["metadata"]["name"])
' >&2
  echo "Set ARGOCD_TLS_SECRET to the active Argo CD server TLS Secret and retry." >&2
  exit 1
fi

temporary_certificate="$(mktemp)"
temporary_manifest="$(mktemp)"
trap 'rm -f "${temporary_certificate}" "${temporary_manifest}"' EXIT

kubectl -n "${ARGOCD_NAMESPACE}" get secret "${TLS_SECRET}" \
  -o jsonpath='{.data.tls\.crt}' \
  | python3 -c '
import base64
import sys

value = sys.stdin.read().strip()
if not value:
    raise SystemExit("ERROR: tls.crt is empty or missing")
sys.stdout.buffer.write(base64.b64decode(value))
' > "${temporary_certificate}"

openssl x509 -in "${temporary_certificate}" -noout >/dev/null

if ! openssl x509 -in "${temporary_certificate}" -noout -text \
  | grep -Fq "DNS:${ARGOCD_SERVICE_DNS}"; then
  echo "ERROR: certificate from ${ARGOCD_NAMESPACE}/${TLS_SECRET} does not include ${ARGOCD_SERVICE_DNS}" >&2
  echo "Certificate SANs:" >&2
  openssl x509 -in "${temporary_certificate}" -noout -ext subjectAltName >&2 || true
  exit 1
fi

kubectl -n "${BACKSTAGE_NAMESPACE}" create configmap backstage-argocd-ca \
  --from-file=argocd-server.crt="${temporary_certificate}" \
  --dry-run=client \
  -o yaml > "${temporary_manifest}"

python3 - "${temporary_manifest}" "${OUTPUT_FILE}" <<'PY2'
from pathlib import Path
import sys

source = Path(sys.argv[1])
destination = Path(sys.argv[2])
lines = [
    line for line in source.read_text().splitlines()
    if line.strip() != 'creationTimestamp: null'
]
destination.write_text('\n'.join(lines) + '\n')
PY2

echo "Updated ${OUTPUT_FILE} from ${ARGOCD_NAMESPACE}/${TLS_SECRET}"
openssl x509 \
  -in "${temporary_certificate}" \
  -noout \
  -subject \
  -issuer \
  -dates \
  -fingerprint \
  -sha256 \
  -ext subjectAltName

echo
echo "Review and commit only the public certificate manifest:"
echo "  git diff -- platform-services/backstage/manifests/argocd-ca-configmap.yaml"

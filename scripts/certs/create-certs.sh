set -euo pipefail

ARGOCD_CERT_FILE="$(mktemp)"

if kubectl -n argocd get secret argocd-server-tls >/dev/null 2>&1; then
  ARGOCD_TLS_SECRET="argocd-server-tls"
else
  ARGOCD_TLS_SECRET="argocd-secret"
fi

echo "Using Argo CD TLS Secret: ${ARGOCD_TLS_SECRET}"

kubectl -n argocd get secret "${ARGOCD_TLS_SECRET}" \
  -o jsonpath='{.data.tls\.crt}' |
python3 -c '
import base64
import sys

encoded = sys.stdin.read().strip()
if not encoded:
    raise SystemExit("tls.crt is missing or empty")

sys.stdout.buffer.write(base64.b64decode(encoded))
' > "${ARGOCD_CERT_FILE}"

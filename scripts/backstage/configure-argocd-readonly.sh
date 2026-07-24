#!/usr/bin/env bash
set -euo pipefail

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
BACKSTAGE_NAMESPACE="${BACKSTAGE_NAMESPACE:-backstage}"
ARGOCD_SERVER="${ARGOCD_SERVER:-localhost:8080}"

command -v kubectl >/dev/null || { echo "kubectl is required" >&2; exit 1; }
command -v argocd >/dev/null || { echo "argocd CLI is required" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }

kubectl patch configmap argocd-cm -n "${ARGOCD_NAMESPACE}" --type merge \
  -p '{"data":{"accounts.backstage":"apiKey","accounts.backstage.enabled":"true"}}'

EXISTING_POLICY="$(kubectl get configmap argocd-rbac-cm -n "${ARGOCD_NAMESPACE}" -o jsonpath='{.data.policy\.csv}' 2>/dev/null || true)"
REQUIRED_POLICY=$(cat <<'POLICY'
p, role:backstage-readonly, applications, get, */*, allow
p, role:backstage-readonly, projects, get, *, allow
p, role:backstage-readonly, clusters, get, *, allow
g, backstage, role:backstage-readonly
POLICY
)

COMBINED_POLICY="${EXISTING_POLICY}"
while IFS= read -r line; do
  [[ -z "${line}" ]] && continue
  if ! grep -Fqx "${line}" <<<"${COMBINED_POLICY}"; then
    COMBINED_POLICY+=$'\n'"${line}"
  fi
done <<<"${REQUIRED_POLICY}"

PATCH="$(POLICY="${COMBINED_POLICY}" python3 - <<'PY2'
import json, os
print(json.dumps({"data": {"policy.csv": os.environ["POLICY"].strip() + "\n"}}))
PY2
)"
kubectl patch configmap argocd-rbac-cm -n "${ARGOCD_NAMESPACE}" --type merge -p "${PATCH}"

TOKEN="$(argocd account generate-token \
  --account backstage \
  --server "${ARGOCD_SERVER}" \
  --grpc-web \
  --insecure)"

kubectl create namespace "${BACKSTAGE_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic backstage-argocd-credentials \
  -n "${BACKSTAGE_NAMESPACE}" \
  --from-literal=ARGOCD_AUTH_TOKEN="${TOKEN}" \
  --dry-run=client -o yaml | kubectl apply -f -

unset TOKEN

echo "Configured the read-only Argo CD account and ${BACKSTAGE_NAMESPACE}/backstage-argocd-credentials"

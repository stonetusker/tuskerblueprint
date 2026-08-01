#!/usr/bin/env bash
set -euo pipefail

BACKSTAGE_NAMESPACE="${BACKSTAGE_NAMESPACE:-backstage}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
PLATFORM_SECRETS_NAMESPACE="${PLATFORM_SECRETS_NAMESPACE:-platform-secrets}"
BACKSTAGE_SECRET_NAME="${BACKSTAGE_GITHUB_SECRET_NAME:-backstage-github-credentials}"
ARGOCD_SECRET_NAME="${ARGOCD_GITHUB_SECRET_NAME:-argocd-github-org-repo-creds}"
GHCR_SECRET_NAME="${GHCR_PULL_SOURCE_SECRET_NAME:-ghcr-pull-credentials}"

for command_name in kubectl; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Required command not found: ${command_name}" >&2
    exit 1
  fi
done

require_key() {
  local namespace="$1"
  local secret="$2"
  local key="$3"
  local encoded
  encoded="$(kubectl -n "${namespace}" get secret "${secret}" -o "jsonpath={.data['${key}']}" 2>/dev/null || true)"
  if [[ -z "${encoded}" ]]; then
    echo "Missing key ${key} in Secret ${namespace}/${secret}" >&2
    exit 1
  fi
}

kubectl -n "${BACKSTAGE_NAMESPACE}" get secret "${BACKSTAGE_SECRET_NAME}" >/dev/null
require_key "${BACKSTAGE_NAMESPACE}" "${BACKSTAGE_SECRET_NAME}" "GITHUB_TOKEN"
echo "Backstage GitHub credential ready: ${BACKSTAGE_NAMESPACE}/${BACKSTAGE_SECRET_NAME}"

kubectl -n "${ARGOCD_NAMESPACE}" get secret "${ARGOCD_SECRET_NAME}" >/dev/null
for key in type url username password; do
  require_key "${ARGOCD_NAMESPACE}" "${ARGOCD_SECRET_NAME}" "${key}"
done
repo_secret_type="$(kubectl -n "${ARGOCD_NAMESPACE}" get secret "${ARGOCD_SECRET_NAME}" -o 'jsonpath={.metadata.labels.argocd\.argoproj\.io/secret-type}')"
if [[ "${repo_secret_type}" != "repo-creds" ]]; then
  echo "Argo CD Secret is not labelled as repo-creds: ${ARGOCD_NAMESPACE}/${ARGOCD_SECRET_NAME}" >&2
  exit 1
fi
echo "Argo CD repository credential ready: ${ARGOCD_NAMESPACE}/${ARGOCD_SECRET_NAME}"

kubectl -n "${PLATFORM_SECRETS_NAMESPACE}" get secret "${GHCR_SECRET_NAME}" >/dev/null
ghcr_type="$(kubectl -n "${PLATFORM_SECRETS_NAMESPACE}" get secret "${GHCR_SECRET_NAME}" -o jsonpath='{.type}')"
if [[ "${ghcr_type}" != "kubernetes.io/dockerconfigjson" ]]; then
  echo "Unexpected Secret type for ${PLATFORM_SECRETS_NAMESPACE}/${GHCR_SECRET_NAME}: ${ghcr_type}" >&2
  exit 1
fi
require_key "${PLATFORM_SECRETS_NAMESPACE}" "${GHCR_SECRET_NAME}" ".dockerconfigjson"
echo "Central GHCR pull credential ready: ${PLATFORM_SECRETS_NAMESPACE}/${GHCR_SECRET_NAME}"

kubectl get clustersecretstore kubernetes-platform-secrets >/dev/null
store_ready="$(kubectl get clustersecretstore kubernetes-platform-secrets -o 'jsonpath={.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)"
if [[ "${store_ready}" != "True" ]]; then
  echo "ClusterSecretStore kubernetes-platform-secrets is not Ready. Sync external-secrets and github-access, then retry." >&2
  exit 1
fi
echo "ClusterSecretStore ready: kubernetes-platform-secrets"

while read -r namespace name; do
  [[ -n "${namespace}" && "${name}" == "ghcr-pull-secret" ]] || continue
  kubectl -n "${namespace}" get secret ghcr-pull-secret >/dev/null
  target_type="$(kubectl -n "${namespace}" get secret ghcr-pull-secret -o jsonpath='{.type}')"
  if [[ "${target_type}" != "kubernetes.io/dockerconfigjson" ]]; then
    echo "Unexpected replicated Secret type in ${namespace}: ${target_type}" >&2
    exit 1
  fi
  echo "Replicated pull Secret ready: ${namespace}/ghcr-pull-secret"
done < <(
  kubectl get externalsecret.external-secrets.io --all-namespaces \
    -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name \
    --no-headers 2>/dev/null || true
)

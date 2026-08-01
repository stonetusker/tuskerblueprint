#!/usr/bin/env bash
set -euo pipefail

umask 077

BACKSTAGE_NAMESPACE="${BACKSTAGE_NAMESPACE:-backstage}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
PLATFORM_SECRETS_NAMESPACE="${PLATFORM_SECRETS_NAMESPACE:-platform-secrets}"
GITHUB_ORG="${GITHUB_ORG:-stonetusker}"
BACKSTAGE_SECRET_NAME="${BACKSTAGE_GITHUB_SECRET_NAME:-backstage-github-credentials}"
ARGOCD_SECRET_NAME="${ARGOCD_GITHUB_SECRET_NAME:-argocd-github-org-repo-creds}"
GHCR_SECRET_NAME="${GHCR_PULL_SOURCE_SECRET_NAME:-ghcr-pull-credentials}"

for command_name in kubectl python3; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Required command not found: ${command_name}" >&2
    exit 1
  fi
done

GITHUB_USERNAME="${GITHUB_USERNAME:-}"
GITHUB_EMAIL="${GITHUB_EMAIL:-}"
GITHUB_PLATFORM_TOKEN="${GITHUB_PLATFORM_TOKEN:-}"
ARGOCD_GITHUB_TOKEN="${ARGOCD_GITHUB_TOKEN:-}"
GHCR_PULL_TOKEN="${GHCR_PULL_TOKEN:-}"

if [[ -z "${GITHUB_USERNAME}" ]]; then
  [[ -t 0 ]] || { echo "Set GITHUB_USERNAME for non-interactive use." >&2; exit 1; }
  read -r -p "GitHub username: " GITHUB_USERNAME
fi

if [[ -z "${GITHUB_EMAIL}" ]]; then
  [[ -t 0 ]] || { echo "Set GITHUB_EMAIL for non-interactive use." >&2; exit 1; }
  read -r -p "GitHub account email: " GITHUB_EMAIL
fi

if [[ -z "${GITHUB_PLATFORM_TOKEN}" ]]; then
  [[ -t 0 ]] || { echo "Set GITHUB_PLATFORM_TOKEN for non-interactive use." >&2; exit 1; }
  read -r -s -p "Backstage/scaffolder GitHub token: " GITHUB_PLATFORM_TOKEN
  echo
fi

if [[ -z "${ARGOCD_GITHUB_TOKEN}" ]]; then
  if [[ -t 0 ]]; then
    read -r -s -p "Argo CD private-repository read token (Enter to reuse the platform token): " ARGOCD_GITHUB_TOKEN
    echo
  fi
  ARGOCD_GITHUB_TOKEN="${ARGOCD_GITHUB_TOKEN:-${GITHUB_PLATFORM_TOKEN}}"
fi

if [[ -z "${GHCR_PULL_TOKEN}" ]]; then
  [[ -t 0 ]] || { echo "Set GHCR_PULL_TOKEN for non-interactive use." >&2; exit 1; }
  read -r -s -p "GHCR PAT classic with read:packages: " GHCR_PULL_TOKEN
  echo
fi

if [[ -z "${GITHUB_USERNAME}" || -z "${GITHUB_EMAIL}" || -z "${GITHUB_PLATFORM_TOKEN}" || -z "${ARGOCD_GITHUB_TOKEN}" || -z "${GHCR_PULL_TOKEN}" ]]; then
  echo "GitHub username, email, platform token, Argo CD token and GHCR pull token are required." >&2
  exit 1
fi

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/tusker-github-secrets.XXXXXX")"
cleanup() {
  rm -rf "${work_dir}"
  unset GITHUB_PLATFORM_TOKEN ARGOCD_GITHUB_TOKEN GHCR_PULL_TOKEN
}
trap cleanup EXIT INT TERM

printf '%s' "${GITHUB_PLATFORM_TOKEN}" > "${work_dir}/GITHUB_TOKEN"
printf '%s' "${GITHUB_PLATFORM_TOKEN}" > "${work_dir}/GITHUB_SCAFFOLDER_TOKEN"
printf '%s' 'git' > "${work_dir}/argocd-type"
printf '%s' "https://github.com/${GITHUB_ORG}" > "${work_dir}/argocd-url"
printf '%s' "${GITHUB_USERNAME}" > "${work_dir}/argocd-username"
printf '%s' "${ARGOCD_GITHUB_TOKEN}" > "${work_dir}/argocd-password"

export GITHUB_USERNAME GITHUB_EMAIL GHCR_PULL_TOKEN
python3 - "${work_dir}/.dockerconfigjson" <<'PY'
import base64
import json
import os
import pathlib
import sys

output = pathlib.Path(sys.argv[1])
username = os.environ["GITHUB_USERNAME"]
email = os.environ["GITHUB_EMAIL"]
token = os.environ["GHCR_PULL_TOKEN"]
auth = base64.b64encode(f"{username}:{token}".encode("utf-8")).decode("ascii")
config = {
    "auths": {
        "ghcr.io": {
            "username": username,
            "password": token,
            "email": email,
            "auth": auth,
        }
    }
}
output.write_text(json.dumps(config, separators=(",", ":")), encoding="utf-8")
PY
unset GITHUB_USERNAME GITHUB_EMAIL GHCR_PULL_TOKEN

for namespace in "${BACKSTAGE_NAMESPACE}" "${ARGOCD_NAMESPACE}" "${PLATFORM_SECRETS_NAMESPACE}"; do
  kubectl create namespace "${namespace}" --dry-run=client -o yaml | kubectl apply -f -
done

kubectl create secret generic "${BACKSTAGE_SECRET_NAME}" \
  --namespace "${BACKSTAGE_NAMESPACE}" \
  --from-file=GITHUB_TOKEN="${work_dir}/GITHUB_TOKEN" \
  --from-file=GITHUB_SCAFFOLDER_TOKEN="${work_dir}/GITHUB_SCAFFOLDER_TOKEN" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic "${ARGOCD_SECRET_NAME}" \
  --namespace "${ARGOCD_NAMESPACE}" \
  --from-file=type="${work_dir}/argocd-type" \
  --from-file=url="${work_dir}/argocd-url" \
  --from-file=username="${work_dir}/argocd-username" \
  --from-file=password="${work_dir}/argocd-password" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl label secret "${ARGOCD_SECRET_NAME}" \
  --namespace "${ARGOCD_NAMESPACE}" \
  argocd.argoproj.io/secret-type=repo-creds \
  --overwrite

kubectl create secret generic "${GHCR_SECRET_NAME}" \
  --namespace "${PLATFORM_SECRETS_NAMESPACE}" \
  --type=kubernetes.io/dockerconfigjson \
  --from-file=.dockerconfigjson="${work_dir}/.dockerconfigjson" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Created or updated Kubernetes-only GitHub credentials:"
echo "  ${BACKSTAGE_NAMESPACE}/${BACKSTAGE_SECRET_NAME}"
echo "  ${ARGOCD_NAMESPACE}/${ARGOCD_SECRET_NAME}"
echo "  ${PLATFORM_SECRETS_NAMESPACE}/${GHCR_SECRET_NAME}"
echo
echo "Sync external-secrets, github-access, backstage-platform-resources and backstage."
echo "The same cluster configuration supports public and private repositories and GHCR packages."

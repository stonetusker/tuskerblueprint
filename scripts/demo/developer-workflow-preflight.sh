#!/usr/bin/env bash
set -euo pipefail

fail=0
warn=0

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: required command not found: $1" >&2
    fail=1
  fi
}

require_file() {
  if [[ ! -f "$1" ]]; then
    echo "ERROR: required source file is missing: $1" >&2
    fail=1
  else
    echo "OK: $1"
  fi
}

require_command kubectl
require_command python3

for path in \
  catalog/users/subeeshlearn.yaml \
  catalog/groups/developers.yaml \
  software-templates/tusker-service/template.yaml \
  docs/DEVELOPER-DEMO-WORKFLOW.md; do
  require_file "${path}"
done

if [[ ${fail} -ne 0 ]]; then
  exit 1
fi

python3 - <<'PY'
from pathlib import Path
import yaml

user = yaml.safe_load(Path('catalog/users/subeeshlearn.yaml').read_text(encoding='utf-8'))
if user.get('metadata', {}).get('name') != 'subeeshlearn':
    raise SystemExit('catalog/users/subeeshlearn.yaml must use metadata.name: subeeshlearn')
if 'developers' not in user.get('spec', {}).get('memberOf', []):
    raise SystemExit('subeeshlearn must belong to the developers group')
print('OK: Backstage developer identity source')
PY

printf 'Kubernetes context: %s\n' "$(kubectl config current-context)"

check_application() {
  local app="$1"
  local sync health
  sync="$(kubectl -n argocd get application "${app}" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  health="$(kubectl -n argocd get application "${app}" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
  printf '%-32s sync=%-10s health=%s\n' "${app}" "${sync:-missing}" "${health:-missing}"
  [[ "${sync}" == "Synced" && "${health}" == "Healthy" ]] || fail=1
}

check_application backstage
check_application backstage-platform-resources
check_application generated-workloads
check_application github-access

if ! kubectl -n backstage rollout status deployment/backstage --timeout=120s; then
  fail=1
fi

secret_keys="$(
  kubectl -n backstage get secret backstage-github-credentials \
    -o json 2>/dev/null |
  python3 -c 'import json,sys; data=json.load(sys.stdin).get("data",{}); print("\n".join(sorted(data)))' \
    2>/dev/null || true
)"

if grep -qx 'GITHUB_TOKEN' <<<"${secret_keys}"; then
  echo "OK: backstage-github-credentials contains GITHUB_TOKEN"
else
  echo "ERROR: backstage-github-credentials is missing GITHUB_TOKEN" >&2
  fail=1
fi

if grep -qx 'GITHUB_SCAFFOLDER_TOKEN' <<<"${secret_keys}"; then
  echo "OK: backstage-github-credentials contains GITHUB_SCAFFOLDER_TOKEN"
else
  echo "WARNING: GITHUB_SCAFFOLDER_TOKEN is absent; GITHUB_TOKEN remains the active integration credential" >&2
  warn=1
fi

for item in \
  argocd/argocd-github-org-repo-creds \
  platform-secrets/ghcr-pull-credentials; do
  namespace="${item%%/*}"
  secret="${item#*/}"
  if kubectl -n "${namespace}" get secret "${secret}" >/dev/null 2>&1; then
    echo "OK: ${namespace}/${secret}"
  else
    echo "ERROR: missing ${namespace}/${secret}" >&2
    fail=1
  fi
done

if kubectl get clustersecretstore kubernetes-platform-secrets >/dev/null 2>&1; then
  echo "OK: ClusterSecretStore kubernetes-platform-secrets"
else
  echo "ERROR: missing ClusterSecretStore kubernetes-platform-secrets" >&2
  fail=1
fi

cat <<'CHECKS'

Manual GitHub checks still required:
- subeeshlearn accepted the Stonetusker organization invitation.
- The platform token can create organization repositories and collaborators.
- GitHub Actions is enabled for newly created repositories.
- Workflows are allowed to create release pull requests.
- Kubernetes Secrets are configured for Backstage, Argo CD private Git access and GHCR pulls.
- The GHCR token identity can read private packages when private visibility is selected.
CHECKS

if [[ ${fail} -ne 0 ]]; then
  echo "Developer workflow preflight failed" >&2
  exit 1
fi

if [[ ${warn} -ne 0 ]]; then
  echo "Developer workflow preflight passed with warnings"
else
  echo "Developer workflow preflight passed"
fi

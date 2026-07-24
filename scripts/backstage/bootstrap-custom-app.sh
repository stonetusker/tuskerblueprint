#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_DIR="${1:-${ROOT_DIR}/.generated/backstage}"
RELEASE="$(tr -d '[:space:]' < "${ROOT_DIR}/backstage-app/backstage-release.txt")"
APP_NAME="${BACKSTAGE_APP_NAME:-tuskerblueprint-backstage}"

command -v node >/dev/null 2>&1 || {
  echo "Node.js is required" >&2
  exit 1
}

command -v npx >/dev/null 2>&1 || {
  echo "npx is required" >&2
  exit 1
}

command -v yarn >/dev/null 2>&1 || {
  echo "Yarn is required" >&2
  exit 1
}

rm -rf "${APP_DIR}"
mkdir -p "$(dirname "${APP_DIR}")"

echo "Creating official Backstage application skeleton"
echo "Application directory: ${APP_DIR}"
echo "Application name: ${APP_NAME}"
echo "Backstage release: ${RELEASE}"

# GitHub Actions sets CI=true. Yarn then enables immutable installs,
# but create-app must be allowed to generate and update yarn.lock.
printf '%s\n' "${APP_NAME}" |
  env -u CI \
    YARN_ENABLE_IMMUTABLE_INSTALLS=false \
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
    npx --yes @backstage/create-app@latest \
      --path "${APP_DIR}"

pushd "${APP_DIR}" >/dev/null

corepack enable || true

echo "Preparing generated dependency tree"

YARN_ENABLE_IMMUTABLE_INSTALLS=false \
  yarn install

echo "Aligning generated Backstage packages to release ${RELEASE}"

YARN_ENABLE_IMMUTABLE_INSTALLS=false \
  yarn backstage-cli versions:bump \
    --release "${RELEASE}"

echo "Installing TuskerBlueprint frontend plugins"

YARN_ENABLE_IMMUTABLE_INSTALLS=false \
  yarn --cwd packages/app add \
    @backstage/app-defaults \
    @backstage/plugin-kubernetes \
    @backstage-community/plugin-github-actions \
    @roadiehq/backstage-plugin-argo-cd

echo "Installing TuskerBlueprint backend plugins"

YARN_ENABLE_IMMUTABLE_INSTALLS=false \
  yarn --cwd packages/backend add \
    @backstage/plugin-kubernetes-backend \
    @backstage/plugin-permission-common \
    @backstage/plugin-permission-node \
    @roadiehq/backstage-plugin-argo-cd-backend

# Plugins added above may initially resolve to versions newer than the chosen
# Backstage release. Run the version alignment again after adding them.
echo "Re-aligning all Backstage packages to release ${RELEASE}"

YARN_ENABLE_IMMUTABLE_INSTALLS=false \
  yarn backstage-cli versions:bump \
    --release "${RELEASE}"

# Recent create-app releases generate new-frontend navigation modules.
# TuskerBlueprint currently uses the stable legacy frontend application API.
# Leaving these modules in the tree causes incompatible frontend API types
# after packages are aligned to Backstage 1.34.1.
rm -rf packages/app/src/modules/nav

echo "Applying TuskerBlueprint application overrides"

rsync -a \
  "${ROOT_DIR}/backstage-app/overrides/" \
  "${APP_DIR}/"

echo "Updating generated lockfile"

YARN_ENABLE_IMMUTABLE_INSTALLS=false \
  yarn install

echo "Confirming immutable dependency installation"

YARN_ENABLE_IMMUTABLE_INSTALLS=true \
  yarn install --immutable

popd >/dev/null

echo
echo "Custom Backstage source generated successfully:"
echo "${APP_DIR}"
echo
echo "Validation commands:"
echo "  cd ${APP_DIR}"
echo "  yarn tsc"
echo "  yarn test --ci"
echo "  yarn build:backend"

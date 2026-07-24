#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_DIR="${1:-${ROOT_DIR}/.generated/backstage}"
RELEASE_FILE="${ROOT_DIR}/backstage-app/backstage-release.txt"
OVERRIDES_DIR="${ROOT_DIR}/backstage-app/overrides"
APP_NAME="${BACKSTAGE_APP_NAME:-tuskerblueprint-backstage}"

if [[ ! -f "${RELEASE_FILE}" ]]; then
  echo "Backstage release file not found: ${RELEASE_FILE}" >&2
  exit 1
fi

RELEASE="$(tr -d '[:space:]' < "${RELEASE_FILE}")"

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

command -v rsync >/dev/null 2>&1 || {
  echo "rsync is required" >&2
  exit 1
}

NODE_MAJOR="$(node -p "process.versions.node.split('.')[0]")"
NODE_ARCH="$(node -p "process.arch")"

if [[ "${NODE_MAJOR}" != "20" ]]; then
  echo "Unsupported Node.js version: $(node --version)" >&2
  echo "TuskerBlueprint Backstage currently requires Node.js 20 LTS." >&2
  echo "Run: nvm use 20" >&2
  exit 1
fi

if [[ "$(uname -s)" == "Darwin" && "$(uname -m)" == "arm64" && "${NODE_ARCH}" != "arm64" ]]; then
  echo "Node.js is running as ${NODE_ARCH} on an Apple Silicon Mac." >&2
  echo "Install and use an ARM64 Node.js 20 build instead of a Rosetta/x64 build." >&2
  exit 1
fi

export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
export YARN_ENABLE_IMMUTABLE_INSTALLS=false

echo "Removing previous generated application"
rm -rf "${APP_DIR}"
mkdir -p "$(dirname "${APP_DIR}")"

echo
echo "Creating official Backstage application skeleton"
echo "Application directory: ${APP_DIR}"
echo "Application name: ${APP_NAME}"
echo "Backstage release: ${RELEASE}"
echo "Node.js version: $(node --version)"
echo "Node.js architecture: ${NODE_ARCH}"
echo

#
# create-app performs yarn install automatically.
#
# At this stage it resolves the newest Backstage dependency tree, including
# native packages such as better-sqlite3, isolated-vm and cpu-features.
#
# We only need the generated source tree and lockfile seed. Native lifecycle
# scripts are therefore disabled during this temporary latest-version install.
#
printf '%s\n' "${APP_NAME}" |
  env -u CI \
    YARN_ENABLE_IMMUTABLE_INSTALLS=false \
    YARN_ENABLE_SCRIPTS=false \
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
    npx --yes @backstage/create-app@latest \
      --path "${APP_DIR}"

pushd "${APP_DIR}" >/dev/null

corepack enable

echo
echo "Aligning generated Backstage packages to release ${RELEASE}"
echo

YARN_ENABLE_IMMUTABLE_INSTALLS=false \
YARN_ENABLE_SCRIPTS=false \
  yarn backstage-cli versions:bump \
    --release "${RELEASE}"

echo
echo "Installing TuskerBlueprint frontend plugins"
echo

YARN_ENABLE_IMMUTABLE_INSTALLS=false \
YARN_ENABLE_SCRIPTS=false \
  yarn --cwd packages/app add \
    @backstage/app-defaults \
    @backstage/plugin-kubernetes \
    @backstage-community/plugin-github-actions \
    @roadiehq/backstage-plugin-argo-cd

echo
echo "Installing TuskerBlueprint backend plugins"
echo

YARN_ENABLE_IMMUTABLE_INSTALLS=false \
YARN_ENABLE_SCRIPTS=false \
  yarn --cwd packages/backend add \
    @backstage/plugin-kubernetes-backend \
    @backstage/plugin-permission-common \
    @backstage/plugin-permission-node \
    @roadiehq/backstage-plugin-argo-cd-backend

echo
echo "Re-aligning all Backstage packages to release ${RELEASE}"
echo

YARN_ENABLE_IMMUTABLE_INSTALLS=false \
YARN_ENABLE_SCRIPTS=false \
  yarn backstage-cli versions:bump \
    --release "${RELEASE}"

#
# Recent create-app releases generate new frontend navigation modules.
# The TuskerBlueprint overrides use the stable frontend API compatible with
# the selected Backstage release.
#
rm -rf packages/app/src/modules/nav

echo
echo "Applying TuskerBlueprint application overrides"
echo

if [[ ! -d "${OVERRIDES_DIR}" ]]; then
  echo "Overrides directory not found: ${OVERRIDES_DIR}" >&2
  exit 1
fi

rsync -a \
  "${OVERRIDES_DIR}/" \
  "${APP_DIR}/"

echo
echo "Installing the aligned dependency tree with lifecycle scripts enabled"
echo

#
# Native package builds are enabled only now, after dependencies have been
# aligned to the selected Backstage release.
#
YARN_ENABLE_IMMUTABLE_INSTALLS=false \
YARN_ENABLE_SCRIPTS=true \
  yarn install

echo
echo "Confirming that the generated lockfile is stable"
echo

YARN_ENABLE_IMMUTABLE_INSTALLS=true \
YARN_ENABLE_SCRIPTS=true \
  yarn install --immutable

popd >/dev/null

echo
echo "Custom Backstage source generated successfully"
echo "Path: ${APP_DIR}"
echo
echo "Run validation with:"
echo "  cd ${APP_DIR}"
echo "  yarn tsc"
echo "  yarn test --ci"
echo "  yarn build:backend"

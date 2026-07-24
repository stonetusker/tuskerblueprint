#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_DIR="${1:-${ROOT_DIR}/.generated/backstage}"
RELEASE="$(tr -d '[:space:]' < "${ROOT_DIR}/backstage-app/backstage-release.txt")"

command -v node >/dev/null || { echo "Node.js is required" >&2; exit 1; }
command -v npx >/dev/null || { echo "npx is required" >&2; exit 1; }
command -v yarn >/dev/null || { echo "Yarn is required" >&2; exit 1; }

rm -rf "${APP_DIR}"
mkdir -p "$(dirname "${APP_DIR}")"

APP_NAME="${BACKSTAGE_APP_NAME:-tuskerblueprint-backstage}"

echo "Creating official Backstage application skeleton in ${APP_DIR}"
echo "Application name: ${APP_NAME}"

# Backstage create-app asks for the application name interactively.
# GitHub Actions has no interactive terminal, so provide the answer through stdin.
printf '%s\n' "${APP_NAME}" |
  npx --yes @backstage/create-app@latest \
    --path "${APP_DIR}"



pushd "${APP_DIR}" >/dev/null
corepack enable || true

echo "Aligning Backstage packages to release ${RELEASE}"
yarn install
yarn backstage-cli versions:bump --release "${RELEASE}"

echo "Installing TuskerBlueprint platform plugins"
yarn --cwd packages/app add \
  @backstage/plugin-kubernetes \
  @backstage/plugin-github-actions \
  @roadiehq/backstage-plugin-argo-cd

yarn --cwd packages/backend add \
  @backstage/plugin-kubernetes-backend \
  @backstage/plugin-permission-common \
  @backstage/plugin-permission-node \
  @backstage/plugin-auth-node \
  @roadiehq/backstage-plugin-argo-cd-backend

rsync -a "${ROOT_DIR}/backstage-app/overrides/" "${APP_DIR}/"

yarn install
popd >/dev/null

echo "Custom Backstage source generated at ${APP_DIR}"
echo "Run: cd ${APP_DIR} && yarn tsc && yarn test --ci && yarn build:backend"

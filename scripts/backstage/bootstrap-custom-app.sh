#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_DIR="${1:-${ROOT_DIR}/.generated/backstage}"
OVERRIDES_DIR="${ROOT_DIR}/backstage-app/overrides"
APP_NAME="${BACKSTAGE_APP_NAME:-tuskerblueprint-backstage}"

for command_name in node npx corepack rsync; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Required command not found: ${command_name}" >&2
    exit 1
  fi
done

if [[ ! -d "${OVERRIDES_DIR}" ]]; then
  echo "Backstage overrides directory not found: ${OVERRIDES_DIR}" >&2
  exit 1
fi

REQUIRED_NODE_VERSION="20.19.0"
CURRENT_NODE_VERSION="$(node -p "process.versions.node")"

node - "${REQUIRED_NODE_VERSION}" <<'NODE'
const required = process.argv[2]
  .split('.')
  .map(Number);

const current = process.versions.node
  .split('.')
  .map(Number);

const [requiredMajor, requiredMinor, requiredPatch] = required;
const [currentMajor, currentMinor, currentPatch] = current;

const supported =
  currentMajor === requiredMajor &&
  (
    currentMinor > requiredMinor ||
    (
      currentMinor === requiredMinor &&
      currentPatch >= requiredPatch
    )
  );

if (!supported) {
  console.error(
    `Node.js ${requiredMajor}.${requiredMinor}.${requiredPatch} ` +
      `or newer within Node.js ${requiredMajor} is required; ` +
      `found ${process.version}`,
  );

  process.exit(1);
}
NODE

echo "Node version requirement satisfied: ${CURRENT_NODE_VERSION}"


export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
export YARN_ENABLE_IMMUTABLE_INSTALLS=false
export YARN_ENABLE_SCRIPTS=false

rm -rf "${APP_DIR}"
mkdir -p "$(dirname "${APP_DIR}")"

echo "Creating Backstage application skeleton in ${APP_DIR}"

printf '%s\n' "${APP_NAME}" |
  env -u CI \
    COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
    YARN_ENABLE_IMMUTABLE_INSTALLS=false \
    YARN_ENABLE_SCRIPTS=false \
    npx --yes @backstage/create-app@latest \
      --path "${APP_DIR}"

pushd "${APP_DIR}" >/dev/null

corepack enable

echo "Node version: $(node --version)"
echo "Yarn version: $(corepack yarn --version)"

if [[ ! -f backstage.json ]]; then
  echo "Generated backstage.json was not found" >&2
  exit 1
fi

GENERATED_RELEASE="$(
  node <<'NODE'
const fs = require('fs');

const backstage = JSON.parse(
  fs.readFileSync('backstage.json', 'utf8'),
);

if (
  typeof backstage.version !== 'string' ||
  backstage.version.trim() === ''
) {
  process.exit(1);
}

process.stdout.write(backstage.version.trim());
NODE
)"

if [[ -z "${GENERATED_RELEASE}" ]]; then
  echo "Could not determine the generated Backstage release" >&2
  exit 1
fi

echo "Generated Backstage release: ${GENERATED_RELEASE}"

# TuskerBlueprint uses the stable frontend API and replaces the generated
# frontend source. Remove navigation modules that are not used by the
# source overrides.
rm -rf packages/app/src/modules/nav

echo "Applying TuskerBlueprint application overrides"

rsync -a \
  --exclude='package.json' \
  --exclude='yarn.lock' \
  --exclude='backstage.json' \
  --exclude='.yarnrc.yml' \
  --exclude='packages/backend/Dockerfile' \
  "${OVERRIDES_DIR}/" \
  "${APP_DIR}/"

echo "Installing TuskerBlueprint frontend plugins"

corepack yarn --cwd packages/app add \
  @backstage/app-defaults \
  @backstage/integration-react \
  @backstage/plugin-kubernetes \
  @backstage-community/plugin-github-actions \
  @roadiehq/backstage-plugin-argo-cd


echo "Installing TuskerBlueprint backend plugins"

corepack yarn --cwd packages/backend add \
  @backstage/plugin-kubernetes-backend \
  @backstage/plugin-permission-common \
  @backstage/plugin-permission-node \
  @roadiehq/backstage-plugin-argo-cd-backend

#
# Plugin installation must happen before the final Backstage alignment.
# Otherwise, unpinned plugin installation can restore newer Backstage
# dependencies after an earlier downgrade.
#
echo "Aligning official Backstage packages to ${GENERATED_RELEASE}"

corepack yarn backstage-cli versions:bump \
  --release "${GENERATED_RELEASE}"

echo "Pinning the Node.js 20-compatible native build toolchain"

node <<'NODE'
const fs = require('fs');

const packageFile = 'package.json';
const pkg = JSON.parse(
  fs.readFileSync(packageFile, 'utf8'),
);

const nodeGypVersion = '10.3.1';

pkg.dependencies = {
  ...(pkg.dependencies || {}),
  'node-gyp': nodeGypVersion,
};

if (pkg.devDependencies) {
  delete pkg.devDependencies['node-gyp'];
}

pkg.resolutions = {
  ...(pkg.resolutions || {}),
  'node-gyp': nodeGypVersion,
};

fs.writeFileSync(
  packageFile,
  `${JSON.stringify(pkg, null, 2)}\n`,
);

console.log(`Pinned node-gyp to ${nodeGypVersion}`);
NODE

echo "Deduplicating compatible dependency ranges"

corepack yarn dedupe \
  --strategy highest

echo "Updating the lockfile without native lifecycle builds"

YARN_ENABLE_IMMUTABLE_INSTALLS=false \
YARN_ENABLE_SCRIPTS=false \
  corepack yarn install \
    --mode=skip-build

echo "Confirming that the generated lockfile is immutable"

YARN_ENABLE_IMMUTABLE_INSTALLS=true \
YARN_ENABLE_SCRIPTS=false \
  corepack yarn install \
    --immutable \
    --mode=skip-build

for required_file in \
  package.json \
  yarn.lock \
  backstage.json \
  .yarnrc.yml \
  packages/app/package.json \
  packages/backend/package.json \
  packages/backend/Dockerfile; do

  if [[ ! -f "${required_file}" ]]; then
    echo "Generated file is missing: ${APP_DIR}/${required_file}" >&2
    exit 1
  fi
done

echo "Direct backend dependency versions"

node <<'NODE'
const fs = require('fs');

const backend = JSON.parse(
  fs.readFileSync('packages/backend/package.json', 'utf8'),
);

const dependencies = {
  ...(backend.dependencies || {}),
  ...(backend.devDependencies || {}),
};

const packages = [
  '@backstage/backend-defaults',
  '@backstage/backend-app-api',
  '@backstage/backend-plugin-api',
  '@backstage/plugin-catalog-backend',
  '@backstage/plugin-scaffolder-backend',
  '@backstage/plugin-permission-backend',
  '@backstage/plugin-kubernetes-backend',
  '@roadiehq/backstage-plugin-argo-cd-backend',
];

for (const packageName of packages) {
  console.log(
    `${packageName}: ${dependencies[packageName] ?? 'not direct'}`,
  );
}
NODE

echo "Resolved critical dependency paths"

corepack yarn why @backstage/backend-defaults
corepack yarn why @backstage/plugin-catalog-backend
corepack yarn why @backstage/plugin-scaffolder-backend
corepack yarn why @backstage/plugin-permission-backend

popd >/dev/null

echo
echo "Custom Backstage source generated successfully: ${APP_DIR}"
echo "Backstage release: ${GENERATED_RELEASE}"
echo
echo "Validation commands:"
echo "  cd ${APP_DIR}"
echo "  corepack yarn tsc"
echo "  corepack yarn workspace app test --ci --runInBand --passWithNoTests"
echo "  corepack yarn workspace backend build"

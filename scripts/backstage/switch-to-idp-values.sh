#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_FILE="${ROOT_DIR}/gitops/applications/platform/developer-platform/backstage/application-development.yaml"

python3 - "${APP_FILE}" <<'PY2'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
old = '$values/platform-services/backstage/values/development.yaml'
new = '$values/platform-services/backstage/values/development-idp.yaml'
if new in text:
    print('IDP values are already active')
elif old not in text:
    raise SystemExit(f'Expected valueFiles entry not found in {path}')
else:
    path.write_text(text.replace(old, new))
    print(f'Updated {path}')
PY2

echo "Review the diff, commit, and push. Argo CD will then deploy the custom image."

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_FILE="${ROOT_DIR}/gitops/applications/platform/developer-platform/backstage/application-development.yaml"

python3 - "${APP_FILE}" <<'PY2'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
old = '$values/platform-services/backstage/values/development-idp.yaml'
new = '$values/platform-services/backstage/values/development.yaml'
if new in text and old not in text:
    print('Stock values are already active')
elif old not in text:
    raise SystemExit(f'Expected IDP valueFiles entry not found in {path}')
else:
    path.write_text(text.replace(old, new))
    print(f'Updated {path}')
PY2

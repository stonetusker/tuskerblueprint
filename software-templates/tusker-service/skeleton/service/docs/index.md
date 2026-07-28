# ${{ values.name }}

${{ values.description }}

## Local development

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
uvicorn src.main:app --reload --port ${{ values.port }}
```

## Delivery

Pull requests run formatting, linting, type checks, tests, secret scanning,
Semgrep, Trivy filesystem and image scanning, and SPDX SBOM generation.

A successful main-branch build publishes an immutable image and opens a GitOps
pull request that updates the development overlay to the full Git SHA.

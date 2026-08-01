# Code review and validation

The split design uses a platform repository and independent application repositories.

## Resolved findings

- Removed embedded application ownership from the platform repository.
- Preserved the reusable Backstage golden path.
- Removed GitHub Advanced Security dependencies from GitHub Free workflows.
- Removed public-only GHCR release gates.
- Added authenticated image publication verification.
- Added organization-wide Argo CD HTTPS repository credentials for private repositories.
- Added a Kubernetes-source External Secrets fanout for `ghcr-pull-secret`, restricted to approved Backstage and Argo-managed workload namespaces.
- Added repository visibility selection to the Backstage template.
- Updated ServiceAccounts, Argo CD namespace labels, workflows, validators and operator/developer documentation.
- Validators reject committed Kubernetes `Secret` manifests, duplicate YAML keys, stale public-only scripts and generated artifacts.

## Security posture

Credential values exist only in runtime Kubernetes Secrets. A least-privilege ServiceAccount can read only `platform-secrets/ghcr-pull-credentials`; External Secrets Operator creates namespace-local Docker config Secrets. Separate Backstage and Argo CD credentials are recommended. The GHCR pull credential is required separately as a PAT classic with `read:packages`; the setup script does not silently reuse an unrelated token for package pulls.

## Validation

Run:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install "PyYAML==6.0.3"
python -m pip install -r software-templates/tusker-service/skeleton/service/requirements-dev.txt
make validate
find scripts -type f -name '*.sh' -exec bash -n {} +
```

GitHub Actions additionally runs Ruff, Mypy, tests, Trivy, Semgrep, Gitleaks, SBOM generation and Kustomize rendering.

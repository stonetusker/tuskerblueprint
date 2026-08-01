# Repository setup

Backstage created `${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}` with `${{ values.repoVisibility }}` visibility.

## GitHub Actions

1. In **Settings → Actions → General**, select **Read and write permissions**.
2. Enable GitHub Actions to create pull requests.
3. Keep both repository workflows enabled.

## Cluster prerequisite

The platform owner runs `scripts/backstage/configure-github-platform-secret.sh` once in the TuskerBlueprint repository. Backstage, Argo CD and GHCR credentials are created as Kubernetes Secrets. The GHCR credential is a separate PAT classic with `read:packages`; restrictive temporary files used during creation are deleted automatically. Each generated repository declares an `ExternalSecret` that materializes `ghcr-pull-secret` in its workload namespace.

## Initial release

The main workflow validates source, runs tests and security scans, publishes immutable and `main` tags, verifies the authenticated GHCR manifest and opens a release PR changing only:

```text
deploy/overlays/development/kustomization.yaml
```

Review the SHA, approve workflows when GitHub asks, merge the release PR, and then merge the platform onboarding PR. No package-visibility change is required.

## Local verification

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements-dev.txt
make validate
make lint
make test
make run
```

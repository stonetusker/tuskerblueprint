# ${{ values.name }}

[![Service CI and Release](https://github.com/${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}/actions/workflows/ci.yml/badge.svg)](https://github.com/${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}/actions/workflows/ci.yml)

${{ values.description }}

This repository was created through the TuskerBlueprint Backstage golden path.
It includes a small browser UI, FastAPI source, tests, CI/CD, container packaging,
security scans, TechDocs, an OpenAPI definition and Kubernetes GitOps manifests.

## Developer owner

- GitHub developer: `@${{ values.developerUsername }}`
- Backstage owner: `${{ values.owner }}`
- Backstage system: `${{ values.system }}`

## Local development

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
uvicorn src.main:app --reload --port ${{ values.port }}
```

Open:

```text
Application UI: http://localhost:${{ values.port }}/
OpenAPI UI:     http://localhost:${{ values.port }}/docs
```

In another terminal:

```bash
curl http://localhost:${{ values.port }}/healthz
curl http://localhost:${{ values.port }}/readyz
curl http://localhost:${{ values.port }}/api/v1/status
curl http://localhost:${{ values.port }}/api/v1/example
```

## Validate before pushing

```bash
scripts/verify.sh
```

## Delivery workflow

Pull requests run formatting, linting, type checks, tests, coverage, secret
scanning, SAST, dependency and image vulnerability scans, an image build and
SPDX SBOM generation.

A successful build on `main` publishes:

```text
ghcr.io/${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}:<full-git-sha>
```

The workflow then opens a release pull request that updates
`deploy/overlays/development/kustomization.yaml`. After approval and merge, Argo
CD deploys the immutable release.

## Kubernetes access

After Argo CD reports the Application `Synced` and `Healthy`:

```bash
kubectl -n ${{ values.name }}-development port-forward \
  service/${{ values.name }} 8082:80
```

Open `http://localhost:8082/`.

In-cluster callers use:

```text
http://${{ values.name }}.${{ values.name }}-development.svc.cluster.local
```

Argo CD reads only this generated service repository and the explicit overlay
path declared by its Application. It does not clone unrelated services.

## Documentation

TechDocs source is under `docs/` and is registered through `catalog-info.yaml`.

- [Architecture](docs/architecture.md)
- [Development](docs/development.md)
- [Delivery](docs/delivery.md)
- [Operations runbook](docs/runbook.md)
- [Observability](docs/observability.md)
- [Security](docs/security.md)

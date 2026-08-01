# ${{ values.name }}

${{ values.description }} It owns the FastAPI service, executive browser UI, tests, OpenAPI definition, TechDocs, CI/CD and Kubernetes overlays. The platform and Argo CD registration live in `stonetusker/tuskerblueprint`.

## Local developer workflow

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

Open `http://localhost:8000/`.

## Delivery workflow

Pull requests run formatting, linting, type checks, unit tests, current-source secret scanning, Semgrep and Trivy. A merge to `main` builds, scans and publishes immutable and `main` GHCR tags, verifies the authenticated remote manifest, and opens a release PR changing only `deploy/overlays/development/kustomization.yaml`.

This repository was requested with `${{ values.repoVisibility }}` visibility. The GHCR package can be public or private. Kubernetes uses the platform-managed `ghcr-pull-secret` in either case, and Argo CD uses organization-level repository credentials when this repository is private.

After the release PR is approved and merged, Argo CD deploys the development overlay into `${{ values.name }}-development`.

## Runtime access

```bash
kubectl -n ${{ values.name }}-development port-forward service/${{ values.name }} 8081:80
```

## Ownership

- Application team: `${{ values.owner }}`
- Platform and Argo CD registration: `stonetusker/tuskerblueprint`
- Container image: `ghcr.io/${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}`

See `SETUP.md`, `docs/FIRST-RELEASE.md`, `docs/runbook.md` and `docs/CODE-REVIEW.md`.

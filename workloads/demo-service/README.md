# StoneTusker buyer-demo service

This directory contains the Customer Notification API, tests, container build,
Kubernetes manifests, environment overlays, TechDocs, and demo controls.

## Validate locally

```bash
cd workloads/demo-service
python -m pip install -r requirements-dev.txt
ruff format --check app tests
ruff check app tests
mypy app
pytest --cov=app --cov-branch --cov-report=term-missing --cov-report=xml --cov-fail-under=85
```

## Build locally

```bash
docker build --build-arg VCS_REF=local -t demo-service:local .
docker run --rm -p 8000:8000 demo-service:local
```

## Deployment warning

The Kubernetes Deployment references the GHCR package and declares
`imagePullSecrets: ghcr-pull-secret`. Configure that secret before merging the
first immutable release pull request, or explicitly make the GHCR package public.

## Persistence boundary

The notification map is deliberately in memory. The development overlay runs one
steady-state replica so the create/read demonstration remains deterministic. A
real customer implementation must use an external datastore before scaling this
API horizontally or enabling the staging and production overlays.

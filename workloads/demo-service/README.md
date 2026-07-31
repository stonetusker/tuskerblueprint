# Stonetusker buyer-demo application

This directory contains the Customer Experience Hub, a colorful executive-friendly browser UI,
FastAPI notification backend, tests, container build, Kubernetes manifests, environment
overlays, TechDocs, OpenAPI and controlled failure modes.

The application records fictional notifications in memory. It does not send
email, SMS or webhooks. The dashboard presents live release metadata, runtime
health, session activity, channel mix and the platform delivery journey.

## Run locally

```bash
cd workloads/demo-service
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
uvicorn app.main:app --reload --port 8000
```

Open:

```text
Application UI: http://localhost:8000/
OpenAPI UI:     http://localhost:8000/docs
Metrics:        http://localhost:8000/metrics
```

## Access the Kubernetes deployment

From the repository root:

```bash
scripts/demo/open-demo-ui.sh
```

Open `http://localhost:8081/` and keep the port-forward terminal running.

Inside the cluster the Service is available at:

```text
http://demo-service.demo-service-development.svc.cluster.local
```

See `docs/SERVICE-DEPLOYMENT-AND-ACCESS.md` at the repository root for the
complete Argo CD and service-access model.

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
steady-state replica so create, list and read demonstrations remain deterministic.
A real customer implementation must use an external datastore before scaling the
API horizontally or enabling staging and production overlays.

# Customer Notification application

The Customer Notification application is the reference workload used in the
Stonetusker buyer-facing delivery-platform demonstration. It combines a small
browser UI with a FastAPI backend. It accepts fictional notification requests,
records them in memory and never sends real email, SMS or webhooks.

## What the application demonstrates

- A usable browser interface backed by the deployed API
- Pull-request validation and security controls
- Immutable container images identified by Git SHA
- GitOps deployment through Argo CD
- Kubernetes startup, readiness and liveness checks
- Prometheus metrics and structured JSON logs
- Correlation IDs shared by the UI, API response and logs
- Deterministic readiness, error and latency failure modes
- Git-driven rollback
- Backstage ownership, API documentation, TechDocs, CI/CD, Argo CD and Kubernetes views

## Ownership

- Owner: Stonetusker Platform Engineering
- System: TuskerBlueprint
- Lifecycle: Experimental reference workload

## Local run

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
```

## Cluster access

```bash
scripts/demo/open-demo-ui.sh
```

Then open `http://localhost:8081/`.

## Safe demo request

The UI submits the same request as this command:

```bash
curl -sS http://localhost:8000/api/v1/notifications \
  -H 'Content-Type: application/json' \
  -H 'X-Correlation-ID: techdocs-demo-001' \
  -H 'X-Demo-Request: buyer-demo' \
  -d '{
    "channel": "email",
    "recipient": "buyer@example.invalid",
    "message": "Stonetusker delivery-platform demonstration"
  }'
```

Only fictional `.invalid` addresses and non-sensitive data should be used.

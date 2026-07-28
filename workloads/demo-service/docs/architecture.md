# Architecture

## Runtime flow

```text
Client
  -> Kubernetes Service
  -> FastAPI Pod
      -> JSON response
      -> Prometheus metrics
      -> JSON stdout logs
```

The application is stateless except for an in-memory notification map used only
for the demonstration. Restarting a Pod clears that map. The development overlay
therefore runs one steady-state replica so the create/read example is deterministic.
A real implementation must use an external datastore before horizontal scaling.
This must not be described as production persistence.

## Release metadata

The runtime reads:

- `SERVICE_NAME`
- `APP_ENV`
- `APP_VERSION`
- `DEMO_FAILURE_MODE`
- `FAILURE_DELAY_MS`

`APP_VERSION` is populated from the release annotation on the Pod. The CI release
workflow updates the development Kustomize overlay with the full Git SHA.

## Security posture

The Kubernetes workload uses a non-root UID, drops Linux capabilities, uses a
read-only root filesystem, disables service-account token mounting, and defines
resource limits and network policies.

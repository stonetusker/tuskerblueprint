# Architecture

The service is a small FastAPI application packaged as a non-root container and deployed through Kustomize and Argo CD.

```text
Developer pull request
        ↓
GitHub Actions quality and security gates
        ↓
Immutable GHCR image
        ↓
Release pull request updates development overlay
        ↓
Argo CD reconciliation
        ↓
Kubernetes Deployment and Service
        ↓
Prometheus metrics and structured logs
```

The repository owns its application source, delivery workflow, Kubernetes base, environment overlays, API definition, and operational documentation.

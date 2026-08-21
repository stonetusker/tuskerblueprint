# Tempo

## Purpose

Tempo provides distributed tracing storage for the TuskerBlueprint platform.

It is intended to be deployed through Argo CD using a pinned Helm chart and environment-specific values stored in Git.

## Ownership

| Component | Owner |
| --------- | ----- |
| Deployment | Git → Argo CD |
| Configuration | Git |
| Helm chart | Upstream Grafana |

## Notes

- Tempo must be deployed before Alloy is configured to forward traces to it.
- It should be coupled with Grafana for trace viewing and correlation.
- Development uses a single-binary deployment mode with local ephemeral storage. **Traces are lost on pod restart.**
- Staging and production must revisit the storage backend (e.g., object storage, distributed topology) to ensure durability and scalability.
- OTLP receiver (gRPC and HTTP) is enabled for trace ingestion from Alloy and other instrumented services.

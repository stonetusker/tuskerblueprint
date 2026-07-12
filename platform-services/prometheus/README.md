# Prometheus

## Purpose

Prometheus provides metrics collection and alerting for the TuskerBlueprint platform.

It is intended to be deployed through Argo CD using a pinned Helm chart and environment-specific values stored in Git.

## Ownership

| Component | Owner |
| --------- | ----- |
| Deployment | Git → Argo CD |
| Configuration | Git |
| Helm chart | Upstream Prometheus |

## Notes

- Prometheus should be deployed as the foundational observability service.
- It should be integrated with Grafana and Loki as the monitoring stack matures.
- Storage and retention policies should be defined before production rollout.

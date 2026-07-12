# Loki

## Purpose

Loki provides log aggregation for the TuskerBlueprint platform.

It is intended to be deployed through Argo CD using a pinned Helm chart and environment-specific values stored in Git.

## Ownership

| Component | Owner |
| --------- | ----- |
| Deployment | Git → Argo CD |
| Configuration | Git |
| Helm chart | Upstream Grafana |

## Notes

- Loki should be deployed after Prometheus is available.
- It should be coupled with Grafana for log viewing and correlation.
- Storage and retention policies should be defined before production rollout.

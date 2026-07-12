# Grafana

## Purpose

Grafana provides dashboards and visualization for the TuskerBlueprint platform.

It is intended to be deployed through Argo CD using a pinned Helm chart and environment-specific values stored in Git.

## Ownership

| Component | Owner |
| --------- | ----- |
| Deployment | Git → Argo CD |
| Configuration | Git |
| Helm chart | Upstream Grafana |

## Notes

- Grafana should be deployed after Prometheus and Loki are available.
- It should provide dashboards for cluster and workload visibility.
- Authentication and ingress should be handled through the platform security and networking stacks.

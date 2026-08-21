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

Development uses one `SingleBinary` replica and therefore sets
`loki.commonConfig.replication_factor: 1`. Staging or production must revisit
both values together when moving to a replicated topology.

The pinned `loki` Helm chart is `6.29.0`, which publishes Loki `3.4.2`. All
environments enable `loki.limits_config.allow_structured_metadata: true`.
Structured metadata also depends on Loki's TSDB schema version 13 or newer; the
live development instance reports a TSDB schema and has this feature enabled.

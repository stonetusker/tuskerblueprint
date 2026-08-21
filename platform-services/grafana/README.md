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

## Development demo dashboard

The development Application combines the Grafana Helm release with a
Git-controlled dashboard ConfigMap from:

```text
platform-services/grafana/dashboards/development/
```

The provisioned dashboard uses UID `stonetusker-demo-service` and appears under
the **Stonetusker Demo** folder. Its Prometheus queries use
`$__rate_interval`, and zero-result expressions explicitly return zero so an
idle healthy service is not shown as `No data`.

Validate the complete Prometheus, Grafana, Alloy, Loki and Tempo readiness path with:

```bash
./scripts/demo/verify-observability.sh
```

The development dashboard ConfigMap also provisions **Platform Observability
Overview** and **Distributed Tracing Demo**. Prometheus request latency
histograms now carry exemplars with the current trace ID, the latency panels
show the exemplar data in Grafana, and the `tempo` datasource is wired to Loki
via `tracesToLogsV2` for direct trace-to-log navigation. Loki log rows expose
the actual 32-character `trace_id` as a derived Tempo link; `correlation_id`
remains request-level metadata and is not used as a Tempo trace identifier. A
populated tracing panel indicates the OTLP pipeline is working end to end.

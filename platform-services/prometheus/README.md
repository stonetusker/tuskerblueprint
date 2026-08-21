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

## Development scrape cadence

Development uses a 15-second global scrape interval. The Grafana Prometheus
data source declares the same interval, allowing `$__rate_interval` to select a
safe counter window at every dashboard zoom level. Do not replace it with a
fixed one-minute `rate()` window: the chart's former one-minute cadence often
provided fewer than two samples and produced gaps.

## Development SLO rules

The development values use the classic `prometheus-community/prometheus` chart
`27.3.0` and load rules through `serverFiles`, not `PrometheusRule` CRDs.
Recording rules precompute request rate, 5xx error rate, error ratio, p50/p95/
p99 latency, and the latency-error ratio for the demo service.

The SLO targets are illustrative placeholders for synthetic demo traffic, not
targets derived from production history:

- Availability: 99.5% successful requests, leaving a 0.5% error budget.
- Latency: 99.5% of requests complete within 500 ms, using the histogram's
	`le="0.5"` bucket. The recorded p95 series is also available for dashboards,
	but the burn-rate alert uses the explicit 99.5% objective.

The burn-rate threshold is derived as `error_ratio / 0.005`. The fast window
requires both 5 minutes and 1 hour above `14.4 * 0.005`, while the slow window
requires both 30 minutes and 6 hours above `6 * 0.005`. Requiring both windows
is the multi-window SRE pattern and avoids paging on a short isolated blip.

Alertmanager is enabled in development with a placeholder webhook URL at
`https://example.invalid/alertmanager-webhook`. Prompt 09 should replace that
URL with the real receiver before using these alerts operationally.

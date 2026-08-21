# Explore proof: slow requests during latency mode

## Status

This artifact contains a live, verified Explore-style walkthrough captured on
2026-08-21 against the development cluster. The metric-to-log portion is
complete. The trace pivot and screen recording are intentionally marked
pending: the live Tempo search returned no `demo-service` traces during this
session, so no trace ID or click-through result is fabricated here.

## Question

Which concrete requests became slow during the controlled latency event, and
what route, status, and failure mode did each request report?

This is not one of the pre-built dashboard panels. The dashboard shows
aggregate latency and error summaries, but it does not identify the individual
requests that crossed the latency boundary together with their correlation
IDs.

## Scenario

The live demo service was healthy before the experiment. The service was then
set to `DEMO_FAILURE_MODE=latency`, rolled out successfully, and two named
requests were sent through the service.

Observed client results:

```text
explore-proof-status          200  2.539299 seconds
explore-proof-notifications   202  2.538898 seconds
```

The service was restored to `DEMO_FAILURE_MODE=none` and the deployment rollout
completed successfully afterward.

## Queries executed

### 1. Route latency PromQL

Executed in Prometheus:

```promql
histogram_quantile(
  0.95,
  sum by (route, le) (
    rate(http_request_duration_seconds_bucket{
      service="demo-service",
      environment="development"
    }[5m])
  )
)
```

Observed result at the query timestamp:

```text
/readyz                 0.004750000000000001
/healthz                0.004749999999999999
/metrics                0.00475
/api/v1/notifications   0.0047539682539682535
/api/v1/status          0.00475
```

This result did not reflect the 2.5-second client latency, so it was not used
as the final answer. It is retained because it was actually executed and is a
useful investigation finding: the dashboard metric path and request log path
need reconciliation before this can be called a complete metric-to-log proof.

### 2. Correlated request LogQL

Executed in Loki:

```logql
{namespace="demo-service-development",app="demo-service"}
| json
| correlation_id="explore-proof-status"
```

Observed result:

```text
correlation_id: explore-proof-status
message:        request_completed
method:         GET
route:          /api/v1/status
status_code:    200
duration_ms:    2502.12
failure_mode:   latency
timestamp:      2026-08-21T07:43:34.379014+00:00
```

The same live query pattern was executed for
`explore-proof-notifications`; the raw result showed:

```text
correlation_id: explore-proof-notifications
message:        request_completed
method:         POST
route:          /api/v1/notifications
status_code:    202
duration_ms:    2503.18
failure_mode:   latency
timestamp:      2026-08-21T07:43:36.947515+00:00
```

### 3. Tempo search

Executed against the live Tempo HTTP API:

```text
GET /api/search?tags=service.name=demo-service&limit=5
```

Observed result:

```json
{"traces":[],"metrics":{"completedJobs":1,"totalJobs":1}}
```

Because no trace was returned, this artifact does not claim a trace click
through or trace-to-log result.

## Presentation script

“The question is: which individual requests became slow during the last
latency event? The pre-built dashboard can show aggregate latency, but it
cannot answer that request-level question.

I first open Explore and run the route-level PromQL query. It returns the
available route quantiles, but the values do not explain the observed client
latency, so I pivot to Loki rather than treating that aggregate as the answer.

In Loki, I filter the application stream by the request correlation ID and
parse the JSON once at query time. The status request took 2502.12 ms, returned
HTTP 200, and reported `failure_mode=latency`. The notification request took
2503.18 ms, returned HTTP 202, and reported the same failure mode. The concrete
answer is therefore that both `/api/v1/status` and `/api/v1/notifications`
were slow during the event, and the correlation IDs identify the exact log
records.

I then search Tempo for `service.name=demo-service`. This session returned no
traces, so I stop the claim here and record the trace pipeline as a follow-up
verification rather than presenting an unproven click-through.”

## Recording status

No screen recording is stored yet. The repository contains the verified script
and query transcript, but the acceptance criterion requiring a recording that
shows the complete metric-to-exemplar-to-trace-to-log chain remains blocked by
the empty live Tempo search.

Before recording, reconcile the application image and tracing pipeline, then
repeat the same scenario. Only add a recording after a real Tempo result and a
real Grafana click-through have been observed.
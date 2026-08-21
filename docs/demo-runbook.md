# Demo runbook

## Existing demonstration application

Application repository: `stonetusker/tusker-demo-notification-service`  
Argo CD Application: `demo-service-development`  
Namespace: `demo-service-development`

Run `scripts/demo/preflight.sh`, start `scripts/demo/open-demo-ui.sh`, and open `http://localhost:8081/`.

## Observability demonstration

After the platform and demo-service changes have reached `main`, wait for these
Argo CD Applications to show `Synced` and `Healthy`:

- `prometheus`
- `loki`
- `alloy`
- `grafana`
- `tempo`
- `demo-service-development`

Run the end-to-end data-path check before recording:

```bash
./scripts/demo/verify-observability.sh
```

The check creates one buyer-safe notification, then proves that the exact metric
families used by the dashboard are present in Prometheus and that the request's
correlation ID is searchable in Loki. It also verifies that Tempo's HTTP API is
ready.

For a visually active dashboard, use two terminals:

```bash
# Terminal 1
./scripts/demo/open-demo-ui.sh

# Terminal 2
DEMO_CONTINUOUS=1 ./scripts/demo/generate-traffic.sh

# Terminal 3, if Grafana is not exposed through an approved ingress
kubectl -n grafana port-forward service/grafana 3000:80
```

Open `http://127.0.0.1:3000`. In Grafana select **Dashboards**, then **Stonetusker Demo**, then
**Stonetusker Demo Service | Golden Path**. Keep the time picker at **Last 30
minutes** and refresh at **5s**.

For the platform view, open **Platform Observability Overview**. Use it to show
the `LIVE` telemetry tile, request rate, p95 latency, HTTP outcomes, and the
same request events arriving in Loki.

For the tracing view, open **Distributed Tracing Demo**. The **Recent traces**
panel should populate as soon as the app sends OTLP traces to Tempo. Use the
**Customer/request correlation ID** field at the top of the dashboard to paste
the ID from the customer issue, then open the matching trace and use **Logs for
this span** to demonstrate the Tempo-to-Loki correlation link. The default
value `.*` shows all recent demo-service traces.

For a simple customer-issue scene, create a request with a memorable ID:

```bash
curl -i -X POST http://127.0.0.1:8082/api/v1/notifications \
   -H 'Content-Type: application/json' \
   -H 'X-Correlation-ID: cust-1042-checkout' \
   -d '{"channel":"email","recipient":"customer@example.invalid","message":"Order confirmation"}'
```

Enter `cust-1042-checkout` in the dashboard field. The log panel narrows to
that request; open its `trace_id` link to jump to the matching Tempo trace.
The Recent traces panel remains a broad recent-trace view so a dashboard query
cannot hide valid traces. If it is empty even after the verification script
reports trace ingestion, check the Grafana Tempo datasource and the dashboard
time range.

To verify Tempo directly during the demo:

```bash
kubectl -n monitoring port-forward service/tempo 13200:3200
curl http://127.0.0.1:13200/ready
```

The expected response is `ready` with HTTP status `200`.

### Current trace-demo status

Tempo is deployed and healthy, and the demo service now emits OTLP spans with
the same `correlation_id` used in logs. Alloy accepts OTLP traces from the
application and forwards them to Tempo, which means a populated **Recent traces**
panel is now a valid expected result for a live demo.

For the current recording, present the **Platform Observability Overview** as the
working observability path: generate traffic, show the `LIVE` telemetry state,
request rate, latency and HTTP outcomes, then open a log row in Loki and show
its correlation ID. Next, switch to **Distributed Tracing Demo** and show the
matching trace in Tempo for the same request, then click through to the linked
Loki logs to demonstrate end-to-end traceability.

A concrete traceability demo flow is:

1. In **Platform Observability Overview**, show the latency panel and a recent
   request spike or exemplar.
2. Click the exemplar or the trace icon on the latency panel to open the matching
   request span in **Distributed Tracing Demo**.
3. In Tempo, open the selected trace and use **Logs for this span** to jump to
   the exact log lines for the same request.
4. Confirm the same `correlation_id` appears in both the trace metadata and the
   log output, proving the metric → trace → log chain for one request.

If the trace panel is empty, do not describe it as a Tempo failure. Check the
app instrumentation, Alloy OTLP receiver configuration, and Tempo readiness
before moving on with the recording.

The top-left **Telemetry state** tile is authoritative:

- `LIVE` means application metrics are being scraped.
- `MISSING` means the data path is broken and healthy-looking zero panels must
  not be trusted.
- A visible `0` for server errors or restarts is a healthy result.

During the controlled error-mode scene, run traffic with failures allowed:

```bash
DEMO_CONTINUOUS=1 DEMO_ALLOW_FAILURES=1 ./scripts/demo/generate-traffic.sh
```

Restore the healthy mode through Git before ending the recording.

## Customer issue investigation demo

Use this scenario to demonstrate how a platform engineer handles a customer
report that the notification API is slow or returning errors. The scenario is
controlled and development-only: it changes the demo deployment environment,
does not contact real recipients, and must be restored before the demo ends.

### Prepare the evidence

Use two terminals. In the first terminal, expose the demo service and Grafana:

```bash
kubectl -n demo-service-development port-forward service/demo-service 8082:80
kubectl -n grafana port-forward service/grafana 3000:80
```

Open Grafana at `http://127.0.0.1:3000`, select **Stonetusker Demo Service |
Golden Path**, and set the time range to **Last 30 minutes** with a 5-second
refresh. Keep **Platform Observability Overview** and **Distributed Tracing
Demo** available in separate browser tabs.

Before starting, verify the observability path:

```bash
./scripts/demo/verify-observability.sh
```

The overview dashboard should show `LIVE`, healthy replicas, and a visible
request rate. `MISSING` means the telemetry path is broken and the scenario
should not continue.

### Scenario A: customer reports latency

1. Put the demo service into controlled latency mode:

    ```bash
    kubectl -n demo-service-development set env deployment/demo-service \
       DEMO_FAILURE_MODE=latency FAILURE_DELAY_MS=2500
    kubectl -n demo-service-development rollout status deployment/demo-service
    ```

2. Send a request with a memorable customer correlation ID:

    ```bash
    curl -sS -X POST http://127.0.0.1:8082/api/v1/notifications \
       -H 'Content-Type: application/json' \
       -H 'X-Correlation-ID: cust-1042-latency' \
       -H 'X-Demo-Request: customer-latency-demo' \
       -d '{"channel":"email","recipient":"customer@example.invalid","message":"Order confirmation"}'
    ```

3. On **Stonetusker Demo Service | Golden Path**, show:

    - **p95 latency** rising above the 500 ms illustrative target.
    - **Customer latency percentiles** showing the slow tail.
    - **API success** remaining healthy because latency mode returns HTTP 200.
    - **Recent demo-service requests** showing `duration_ms` and
       `correlation_id=cust-1042-latency`.

4. Open **Distributed Tracing Demo**, enter `cust-1042-latency` in the
    correlation field, and open the matching `POST /api/v1/notifications`
    trace. Show the long span duration and use the trace-to-Loki link to prove
    that the slow request and its log entry are the same request.

5. Explain the operational conclusion: the customer symptom is latency, not
    an availability failure. The trace identifies the request, the log records
    the correlation ID and duration, and Prometheus shows the aggregate impact.

### Scenario B: customer reports errors

1. Change the controlled failure mode:

    ```bash
    kubectl -n demo-service-development set env deployment/demo-service \
       DEMO_FAILURE_MODE=errors
    kubectl -n demo-service-development rollout status deployment/demo-service
    ```

2. Send a request with a different correlation ID:

    ```bash
    curl -i -sS -X POST http://127.0.0.1:8082/api/v1/notifications \
       -H 'Content-Type: application/json' \
       -H 'X-Correlation-ID: cust-1042-error' \
       -H 'X-Demo-Request: customer-error-demo' \
       -d '{"channel":"email","recipient":"customer@example.invalid","message":"Order confirmation"}'
    ```

    The expected response is HTTP `500` with the same correlation ID.

3. On **Stonetusker Demo Service | Golden Path**, show:

    - **API success** falling below 100%.
    - **Server error percentage** rising above zero.
    - **Request outcomes** showing HTTP 5xx responses.
    - **Recent demo-service requests** showing the failed request and its
       `failure_mode`.

4. In **Distributed Tracing Demo**, enter `cust-1042-error`, open the matching
    trace, and follow the trace-to-Loki link. Confirm the trace, log, HTTP 500,
    and correlation ID all describe the same customer event.

5. Explain the operational conclusion: the platform engineer can distinguish
    an application error from a platform outage because Kubernetes capacity and
    telemetry remain available while the application error ratio increases.

### Restore the healthy service

Always restore the development workload after the demonstration:

```bash
kubectl -n demo-service-development set env deployment/demo-service \
   DEMO_FAILURE_MODE=none FAILURE_DELAY_MS=2500
kubectl -n demo-service-development rollout status deployment/demo-service
```

Then generate one normal request and confirm **API success** is back to 100%,
**Server error percentage** returns to zero, and **p95 latency** returns below
the illustrative threshold. Because the demo uses an in-memory store, a pod
restart also resets retained notification records; this is expected behavior.

### Direct verification commands

Use these commands when explaining that the dashboard is backed by real
telemetry rather than static panels:

```bash
# Prometheus: aggregate p95 latency
curl -sG http://127.0.0.1:19090/api/v1/query \
   --data-urlencode 'query=demo_service:http_latency:p95_seconds:5m' | jq .

# Prometheus: server error ratio
curl -sG http://127.0.0.1:19090/api/v1/query \
   --data-urlencode 'query=demo_service:http_errors:rate5m' | jq .

# Loki: find the customer request by correlation ID
curl -sG http://127.0.0.1:13100/loki/api/v1/query_range \
   --data-urlencode 'query={namespace="demo-service-development",app="demo-service"} | correlation_id = "cust-1042-latency"' \
   --data-urlencode 'since=30m' | jq .

# Tempo: find the corresponding notification trace
curl -sG http://127.0.0.1:13200/api/search \
   --data-urlencode 'q={ resource.service.name = "demo-service" && name = "POST /api/v1/notifications" }' \
   --data-urlencode 'limit=20' | jq .
```

## New-developer demonstration

Use `subeeshlearn` in a clean browser session. Create a service through Backstage, show the generated repository and workflows, merge the service release PR, merge the platform onboarding PR, and show Argo CD and Backstage operational views.

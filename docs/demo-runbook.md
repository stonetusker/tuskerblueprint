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
panel is populated only after the application sends OTLP traces to Tempo. When
traces are present, open a trace and use **Logs for this span** to demonstrate
the Tempo-to-Loki correlation link. An empty trace panel before trace
instrumentation is enabled is expected and does not indicate a Tempo failure.

To verify Tempo directly during the demo:

```bash
kubectl -n monitoring port-forward service/tempo 13200:3200
curl http://127.0.0.1:13200/ready
```

The expected response is `ready` with HTTP status `200`.

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

## New-developer demonstration

Use `subeeshlearn` in a clean browser session. Create a service through Backstage, show the generated repository and workflows, merge the service release PR, merge the platform onboarding PR, and show Argo CD and Backstage operational views.

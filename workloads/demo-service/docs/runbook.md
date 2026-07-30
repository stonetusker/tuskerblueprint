# Operations runbook

## Open the application

```bash
scripts/demo/open-demo-ui.sh
```

Open `http://localhost:8081/`.

## Health and readiness

```bash
curl http://localhost:8081/healthz
curl http://localhost:8081/readyz
curl http://localhost:8081/api/v1/status
```

## Submit a notification

Use the browser form or:

```bash
curl -i http://localhost:8081/api/v1/notifications \
  -H 'Content-Type: application/json' \
  -H 'X-Correlation-ID: operator-demo-001' \
  -d '{
    "channel": "email",
    "recipient": "operator@example.invalid",
    "message": "Operator runbook test"
  }'
```

## Runtime

```bash
kubectl -n demo-service-development get deployment,pod,service \
  -l app.kubernetes.io/name=demo-service
```

## Logs

```bash
kubectl -n demo-service-development logs deployment/demo-service --since=10m
```

Search for the correlation ID returned by the UI or API response.

## Deployment image

```bash
kubectl -n demo-service-development get deployment demo-service \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

## In-cluster access

Same namespace:

```text
http://demo-service
```

Approved workload namespace:

```text
http://demo-service.demo-service-development.svc.cluster.local
```

The caller namespace must have label
`platform.stonetusker.com/workload=true`.

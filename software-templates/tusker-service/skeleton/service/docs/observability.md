# Observability

The service exposes Prometheus metrics at `/metrics` and writes structured request logs with a correlation ID.

Important metrics include:

- `application_info`
- `http_requests_total`
- `http_request_duration_seconds`

Send a correlation ID with a request:

```bash
curl \
  -H 'X-Correlation-ID: developer-demo-001' \
  http://localhost:${{ values.port }}/api/v1/example
```

Use the same identifier to find the request in Kubernetes logs or Loki.

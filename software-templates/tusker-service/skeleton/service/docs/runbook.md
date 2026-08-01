# Operations runbook

```bash
kubectl -n ${{ values.name }}-development rollout status deployment/${{ values.name }}
kubectl -n ${{ values.name }}-development port-forward service/${{ values.name }} 8081:80
```

Verify `/healthz`, `/readyz`, `/api/v1/status`, `/metrics` and the UI at `/`. Use the correlation ID returned by the API to find the same request in logs.

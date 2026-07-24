# Operations runbook

## Health

- Liveness: `/healthz`
- Readiness: `/readyz`

## Kubernetes

```bash
kubectl -n ${{ values.name }}-development get deploy,pod,service
kubectl -n ${{ values.name }}-development logs deployment/${{ values.name }} --tail=200
```

## Rollback

Revert the Git commit that changed the desired state. Avoid making a permanent manual change in Kubernetes.

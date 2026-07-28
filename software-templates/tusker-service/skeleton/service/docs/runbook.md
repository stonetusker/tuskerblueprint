# Operations runbook

## Health

```bash
curl http://localhost:${{ values.port }}/healthz
curl http://localhost:${{ values.port }}/readyz
```

## Runtime

```bash
kubectl -n ${{ values.name }}-development get deployment,pod,service \
  -l app.kubernetes.io/name=${{ values.name }}
```

## Rollback

Update `deploy/overlays/development/kustomization.yaml` to the last known good
full Git SHA, review the change, and merge it. Argo CD will reconcile the rollback.

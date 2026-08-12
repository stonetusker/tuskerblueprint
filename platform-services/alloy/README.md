# Grafana Alloy log collection

Alloy collects Kubernetes container logs from `/var/log/pods`, removes the CRI
container-log envelope, and forwards the original application line to Loki. The
development observability stack enables it through the root Argo CD
Kustomization so the provisioned Grafana log panels work after bootstrap.

Then verify:

```bash
argocd app get alloy --refresh
kubectl -n monitoring rollout status daemonset/alloy --timeout=300s
kubectl -n monitoring logs daemonset/alloy --tail=200
```

The application label is derived from `app.kubernetes.io/name`. Workloads that
follow the TuskerBlueprint service template are therefore queryable with:

```logql
{namespace="demo-service-development", app="demo-service", container="app"}
```

# Grafana Alloy log collection

This optional phase collects Kubernetes container logs from `/var/log/pods` and
forwards them to the existing Loki gateway.

It is intentionally not activated in the root observability Kustomization. Before
activation, confirm that `grafana/alloy:v1.7.5` is available for the cluster
architecture and validate the Alloy configuration in the target cluster.

Activate by adding `alloy` to:

```text
gitops/applications/platform/observability/kustomization.yaml
```

Then verify:

```bash
argocd app get alloy --refresh
kubectl -n monitoring rollout status daemonset/alloy --timeout=300s
kubectl -n monitoring logs daemonset/alloy --tail=200
```

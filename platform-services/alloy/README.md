# Grafana Alloy log collection

Alloy tails Kubernetes container logs through the Kubernetes API and forwards
the original application line to Loki. It also receives OTLP gRPC traces on
4317/TCP through the `alloy` ClusterIP Service. It does not require a
privileged or root container, or a host filesystem mount. Each DaemonSet
instance is scoped to the Pods on its own node so the same log is not collected
more than once.

The development observability stack enables Alloy through the root Argo CD
Kustomization so the provisioned Grafana log panels work after bootstrap.

Then verify:

```bash
argocd app get alloy --refresh
kubectl -n monitoring rollout status daemonset/alloy --timeout=300s
kubectl auth can-i get pods/log \
  --as system:serviceaccount:monitoring:alloy
kubectl -n monitoring logs daemonset/alloy --tail=200
```

The application label is derived from `app.kubernetes.io/name`. Workloads that
follow the TuskerBlueprint service template are therefore queryable with:

```logql
{namespace="demo-service-development", app="demo-service", container="app"}
```

Alloy parses the service JSON line at ingest and stores `correlation_id`,
`trace_id`, and `level` as Loki structured metadata. They are intentionally not
labels, because request-scoped IDs would create high-cardinality index entries.
The metadata can be filtered directly in LogQL, for example:

```logql
{namespace="demo-service-development", app="demo-service"} | correlation_id = "<id>"
```

After changing `config-map.yaml`, also update the
`tuskerblueprint.io/config-revision` annotation in `daemon-set.yaml`. That makes
the GitOps reconciliation roll the collectors onto the new configuration.

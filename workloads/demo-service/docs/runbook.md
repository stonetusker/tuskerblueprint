# Operations runbook

## Check desired state

```bash
argocd app get demo-service-development --refresh
```

## Check rollout

```bash
kubectl -n demo-service-development rollout status deployment/demo-service --timeout=300s
kubectl -n demo-service-development get deployment,pod,service -l app.kubernetes.io/name=demo-service
```

## Verify the release

```bash
kubectl -n demo-service-development get deployment demo-service \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

## Open the service locally

```bash
kubectl -n demo-service-development port-forward service/demo-service 8081:80
curl -sS http://127.0.0.1:8081/
```

## Inspect logs

```bash
kubectl -n demo-service-development logs deployment/demo-service --tail=200
```

Search for the `correlation_id` returned in the `X-Correlation-ID` response header.

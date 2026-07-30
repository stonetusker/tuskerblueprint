# Operations runbook

## Open the deployed application

```bash
kubectl -n ${{ values.name }}-development port-forward \
  service/${{ values.name }} 8082:80
```

Open `http://localhost:8082/`.

## Health

```bash
curl http://localhost:8082/healthz
curl http://localhost:8082/readyz
curl http://localhost:8082/api/v1/status
```

## Runtime

```bash
kubectl -n ${{ values.name }}-development get deployment,pod,service \
  -l app.kubernetes.io/name=${{ values.name }}
```

## Deployment image

```bash
kubectl -n ${{ values.name }}-development get deployment ${{ values.name }} \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

## Logs

```bash
kubectl -n ${{ values.name }}-development logs deployment/${{ values.name }} \
  --since=10m
```

## In-cluster address

```text
http://${{ values.name }}.${{ values.name }}-development.svc.cluster.local
```

The caller namespace must be an approved workload namespace labeled
`platform.stonetusker.com/workload=true`. The generated NetworkPolicy permits DNS
and traffic to other approved workloads while retaining default-deny egress for
unapproved destinations.

## Rollback

Update `deploy/overlays/development/kustomization.yaml` to the last known-good
full Git SHA, review the release evidence and merge the rollback pull request.
Argo CD reconciles the previous immutable image.

## Escalation

Contact the owning Backstage Group shown on the catalog entity. Escalate
platform, Argo CD, cluster or policy failures to `group:default/platform-team`.

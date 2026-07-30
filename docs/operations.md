# Operations

## Local access sessions

Keep each command in a separate terminal:

```bash
kubectl -n backstage port-forward svc/backstage 7007:7007
kubectl -n argocd port-forward svc/argocd-server 8080:443
kubectl -n demo-service-development port-forward svc/demo-service 8081:80
```

Browser endpoints:

```text
Backstage:    http://localhost:7007
Argo CD:      https://localhost:8080
Demo service: http://localhost:8081
```

## Platform health

```bash
kubectl -n argocd get applications.argoproj.io \
  -o custom-columns='NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status'

kubectl -n backstage get pods
kubectl -n demo-service-development get pods
scripts/demo/status.sh
scripts/demo/preflight.sh
```

## Backstage logs

```bash
kubectl -n backstage logs deployment/backstage --tail=300
```

Catalog troubleshooting:

```bash
kubectl -n backstage logs deployment/backstage --tail=300 \
  | grep -Ei 'catalog|github|location|error'
```

Argo CD plugin troubleshooting:

```bash
kubectl -n backstage logs deployment/backstage --since=3m \
  | grep -Ei 'argocd|certificate|self-signed|altname|unauthorized|forbidden|error|failed' \
  || true
```

Successful plugin requests return `200` or browser-cache response `304`.

## Argo CD certificate rotation

The certificate committed in `platform-services/backstage/manifests/argocd-ca-configmap.yaml` is public but cluster-specific.

Rotate it with:

```bash
scripts/backstage/update-argocd-ca-configmap.sh
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py

git add platform-services/backstage/manifests/argocd-ca-configmap.yaml
git commit -m 'chore(backstage): rotate Argo CD CA certificate'
git push origin main

argocd app sync backstage-platform-resources
argocd app sync backstage
kubectl -n backstage rollout status deployment/backstage --timeout=300s
```

See [Backstage and Argo CD integration](BACKSTAGE-ARGOCD-INTEGRATION.md).

## Deployment troubleshooting

Use the Argo CD Application **Conditions** panel to distinguish a rendering or comparison failure from Kubernetes runtime health failure.

### Argo CD UI steps

```text
Argo CD
→ Applications
→ Select the Application
→ Details
→ Conditions
```

Inspect the desired Backstage manifest before syncing:

```bash
argocd app manifests backstage \
  | grep -A12 -B5 \
      -E 'NODE_EXTRA_CA_CERTS|backstage-argocd-ca|/etc/backstage/argocd-ca'
```

## Backup and recovery

- Backstage catalog metadata is reproducible from Git.
- PostgreSQL requires a tested backup and restore plan in non-demo environments.
- External secret sources require their own backup and recovery controls.
- Argo CD configuration should be reproducible from bootstrap manifests without exporting live Secret objects into Git.
- Public CA certificates may be committed, but private keys must never be committed.
- Recovery tests should include rebuilding the Argo CD CA ConfigMap and rolling Backstage.

# Operations

## Health checks

```bash
kubectl get applications -n argocd
kubectl get pods -n backstage
kubectl logs -n backstage deployment/backstage --tail=200
```

## Catalog troubleshooting

```bash
kubectl logs -n backstage deployment/backstage --tail=300 | grep -Ei 'catalog|github|location|error'
```

## Deployment troubleshooting

Use the Argo CD Application **Conditions** panel to distinguish a rendering or comparison failure from a Kubernetes runtime health failure.

## Backup and recovery

- Backstage catalog metadata is reproducible from Git.
- PostgreSQL requires a tested backup and restore plan in non-demo environments.
- External secret sources require their own backup and recovery controls.
- Argo CD configuration should be reproducible from bootstrap manifests without exporting live Secret objects into Git.

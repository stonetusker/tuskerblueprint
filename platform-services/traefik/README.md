# Traefik

## Purpose

Traefik provides the ingress controller for the TuskerBlueprint platform.

After bootstrap, Traefik is managed exclusively through GitOps using Argo CD.

## Ownership

| Component | Owner |
|-----------|-------|
| Deployment | Git → Argo CD |
| Configuration | Git |
| Helm Chart | Upstream Traefik |

## Configuration

Environment-specific Helm values are stored in:

```text
values/
├── development.yaml
├── staging.yaml
└── production.yaml
```

## Validation

From the **🟦 Mac Controller**:

```bash
kubectl get applications -n argocd

kubectl get pods -n traefik

kubectl get svc -n traefik

kubectl get ingressclass
```

Expected:

- Application is `Synced`
- Application is `Healthy`
- Pods are `Running`
- `IngressClass` named `traefik` exists

## Rollback

Revert the Git commit and push to the default branch.

Argo CD will reconcile automatically.

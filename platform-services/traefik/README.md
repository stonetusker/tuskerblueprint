# Traefik

## Purpose

Traefik provides the ingress controller and edge routing layer for the TuskerBlueprint platform.

It is deployed through Argo CD using the official Traefik Helm chart and environment-specific values stored in Git.

## Ownership

| Component | Owner |
| --------- | ----- |
| Deployment | Git → Argo CD |
| Configuration | Git |
| Helm chart | Upstream Traefik |

## Architecture

Traefik is implemented as a platform capability under the networking domain.

The deployment model is:

1. Argo CD Application for each environment
2. Official Traefik Helm chart from the upstream chart repository
3. Environment values from the repository values directory
4. GitOps reconciliation and self-healing

## Configuration

Environment-specific Helm values are stored in:

```text
values/
├── development.yaml
├── staging.yaml
└── production.yaml
```

## Validation

From the platform controller or a workstation with access to the cluster:

```bash
kubectl get applications -n argocd
kubectl get pods -n traefik
kubectl get svc -n traefik
kubectl get ingressclass
kubectl get endpoints -n traefik traefik
```

Expected results:

- Argo CD Application is `Synced` and `Healthy`
- Traefik pods are `Running` and `Ready`
- Service `traefik` is present and has endpoints
- IngressClass `traefik` exists

## Rollback

Rollback is performed through Git:

```bash
git revert <commit>
git push origin main
```

Argo CD reconciles the revision automatically and removes the previous state.

## Operational Notes

- The chart version is pinned to 37.1.0.
- TLS is expected to be handled by the platform security layer.
- Ingress routes should be created through GitOps-managed manifests in downstream applications.

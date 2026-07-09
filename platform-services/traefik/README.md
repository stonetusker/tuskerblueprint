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

Use the following verification steps from the platform controller or any workstation with cluster access:

```bash
# 1. Confirm the Argo CD Application is healthy
kubectl get applications -n argocd
kubectl get application traefik-development -n argocd

# 2. Confirm the Traefik workload is running
kubectl get pods -n traefik
kubectl get deployment -n traefik
kubectl wait --for=condition=available deployment/traefik -n traefik --timeout=300s

# 3. Confirm the service and ingress resources are present
kubectl get svc -n traefik
kubectl get endpoints -n traefik traefik
kubectl get ingressclass

# 4. Review the Traefik logs if startup issues are suspected
kubectl logs deployment/traefik -n traefik --tail=100
```

Expected results:

- Argo CD Application is `Synced` and `Healthy`
- Traefik pods are `Running` and `Ready`
- Service `traefik` is present and has endpoints
- IngressClass `traefik` exists
- The deployment becomes `Available` within the timeout window

If the namespace is still missing, the application has not reconciled successfully. In that case, run:

```bash
kubectl describe application traefik-development -n argocd
kubectl get events -n argocd --sort-by=.metadata.creationTimestamp | tail -20
kubectl logs deployment/argocd-repo-server -n argocd --tail=100
kubectl logs deployment/argocd-application-controller -n argocd --tail=100
```

If `kubectl` fails with a certificate error, verify that the local kubeconfig points to the intended cluster and trusts the cluster CA.

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

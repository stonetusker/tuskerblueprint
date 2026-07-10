# cert-manager

## Purpose

cert-manager provides certificate lifecycle automation for the TuskerBlueprint platform.

It is deployed through Argo CD using the official Jetstack Helm chart and environment-specific values stored in Git.

## Ownership

| Component | Owner |
| --------- | ----- |
| Deployment | Git → Argo CD |
| Configuration | Git |
| Helm chart | Upstream Jetstack |

## Architecture

cert-manager is implemented as a platform capability under the security domain.

The deployment model is:

1. Argo CD Application for each environment
2. Official cert-manager Helm chart from the upstream chart repository
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
# 1. Confirm the Argo CD Applications are healthy
kubectl get applications -n argocd
kubectl get application cert-manager-development -n argocd

# 2. Confirm the cert-manager workload is running
kubectl get pods -n cert-manager
kubectl get deployment -n cert-manager
kubectl wait --for=condition=available deployment/cert-manager -n cert-manager --timeout=300s

# 3. Confirm the certificate CRDs are present
kubectl get crd | grep cert-manager

# 4. Review the cert-manager logs if startup issues are suspected
kubectl logs deployment/cert-manager -n cert-manager --tail=100
```

Expected results:

- Argo CD Application is `Synced` and `Healthy`
- cert-manager pods are `Running` and `Ready`
- Certificate CRDs are present
- The deployment becomes `Available` within the timeout window

If the namespace is still missing, the application has not reconciled successfully. In that case, run:

```bash
kubectl describe application cert-manager-development -n argocd
kubectl get events -n argocd --sort-by=.metadata.creationTimestamp | tail -20
kubectl logs deployment/argocd-repo-server -n argocd --tail=100
kubectl logs deployment/argocd-application-controller -n argocd --tail=100
```

## Rollback

Rollback is performed through Git:

```bash
git revert <commit>
git push origin main
```

Argo CD reconciles the revision automatically and removes the previous state.

## Operational Notes

- The chart version is pinned to v1.21.0.
- cert-manager CRDs are installed as part of the Helm release.
- Issuers and ClusterIssuers should be managed through GitOps-managed manifests in downstream applications.

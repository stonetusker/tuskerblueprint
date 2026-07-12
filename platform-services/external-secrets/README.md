# External Secrets Operator

## Purpose

External Secrets Operator provides a secure way to synchronize secrets from external secret backends into Kubernetes.

It is deployed through Argo CD using the official External Secrets Operator Helm chart and environment-specific values stored in Git.

## Ownership

| Component | Owner |
| --------- | ----- |
| Deployment | Git → Argo CD |
| Configuration | Git |
| Helm chart | Upstream External Secrets Operator |

## Notes

- The chart version should be pinned in the Argo CD application definition.
- The operator is intended to work with secret backends such as Doppler and other external providers.
- Runtime credentials should be supplied through a secure secret-management path.

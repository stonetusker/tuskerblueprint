# Doppler

## Current status

Doppler integration is optional and is not enabled in the active development
environment. The current Backstage deployment consumes pre-created Kubernetes
Secrets directly.

The manifests in this directory are retained as a scaffold for a future
Doppler-backed secret-management implementation.

## Purpose

Doppler provides a centralized secret-management integration layer for platform workloads and applications.

It is intended to be deployed through Argo CD using a pinned Helm chart and environment-specific values stored in Git.

## Ownership

| Component | Owner |
| --------- | ----- |
| Deployment | Git → Argo CD |
| Configuration | Git |
| Helm chart | Upstream Doppler |

## Notes

- The capability should be wired behind the External Secrets Operator foundation.
- Secrets should be sourced from Doppler through a controlled integration path.
- Runtime credentials must remain externalized and managed securely.

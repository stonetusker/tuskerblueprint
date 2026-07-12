# Backstage

## Purpose

Backstage provides a developer portal and service catalog for the TuskerBlueprint platform.

It is intended to be deployed through Argo CD using a pinned Helm chart and environment-specific values stored in Git.

## Ownership

| Component | Owner |
| --------- | ----- |
| Deployment | Git → Argo CD |
| Configuration | Git |
| Helm chart | Upstream Backstage |

## Notes

- Backstage should be deployed after the core networking, security, and observability layers are available.
- It should provide a developer-facing entry point for platform capabilities and service discovery.
- Authentication and ingress should be wired through the platform services already in place.

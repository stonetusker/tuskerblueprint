# Kyverno

## Purpose

Kyverno provides policy-as-code enforcement for the TuskerBlueprint platform.

It is intended to be deployed through Argo CD using a pinned Helm chart and environment-specific values stored in Git.

## Ownership

| Component | Owner |
| --------- | ----- |
| Deployment | Git → Argo CD |
| Configuration | Git |
| Helm chart | Upstream Kyverno |

## Notes

- The capability should be deployed after the secret-management foundation is in place.
- Policies should be declared in Git and enforced consistently across environments.
- Cluster-scoped policies and namespace-scoped policies should be managed as first-class platform assets.

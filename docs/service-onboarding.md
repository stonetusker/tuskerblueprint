# Service onboarding

## Required metadata

Every service must define:

- `metadata.name`
- `metadata.title`
- `spec.owner`
- `spec.system`
- `spec.lifecycle`
- `backstage.io/techdocs-ref`
- `github.com/project-slug`
- `argocd/app-name`
- `backstage.io/kubernetes-id`

## Required delivery assets

- Source code and automated tests
- Container build definition
- CI workflow
- Kubernetes base and environment overlays
- Argo CD Application
- OpenAPI definition when an API is exposed
- TechDocs and an operational runbook
- Resource requests and limits
- Liveness and readiness probes
- Non-root execution and restricted security context
- NetworkPolicy and PodDisruptionBudget where appropriate

## Ownership

A service without a valid owner is not production-ready. Catalog ownership should map to a Backstage Group that represents a real operating team.

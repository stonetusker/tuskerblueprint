# Service onboarding

## Supported path

The supported developer onboarding path is **Backstage → Create → Tusker Service**. It creates the source repository and opens a reviewed GitOps onboarding pull request. Manual repository and Argo CD Application creation should be treated as an exception.

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
- `argocd/instance-name`
- `backstage.io/kubernetes-id`
- `backstage.io/kubernetes-namespace`

## Required delivery assets

- Source code and automated tests
- Local developer verification command
- Container build definition
- Application CI and release workflow
- Metadata, TechDocs, and GitOps validation workflow
- Kubernetes base and environment overlays
- Argo CD Application onboarding manifest
- OpenAPI definition when an API is exposed
- TechDocs architecture, development, delivery, operations, observability, and security pages
- Resource requests and limits
- Liveness, readiness, and startup probes
- Non-root execution and restricted security context
- NetworkPolicy and PodDisruptionBudget
- Secret scanning, SAST, vulnerability scanning, SBOM evidence, and immutable image tagging

## Ownership

A service without a valid owner is not production-ready. Catalog ownership must map to a Backstage Group that represents a real operating team. The developer demo uses `group:default/developers`, while the platform itself is owned by `group:default/platform-team`.

## Repository visibility

The buyer demo creates public service repositories so the existing Argo CD instance can read a newly generated repository without provisioning a repository credential during the presentation. Private repository support requires an approved organization-level Argo CD repository credential or GitHub App integration.

# Scaffolded service acceptance

## Backstage task

- GitHub user identity resolves to a Backstage `User` entity.
- The Tusker Service template is visible under **Create**.
- Repository visibility can be selected as private or public.
- The selected developer receives push access.
- The repository is registered in the catalog.
- A platform onboarding PR is created under `gitops/generated-workloads/<service>`.

## Generated repository

- FastAPI source and executive UI are present.
- Tests, Ruff, Mypy, Gitleaks, Semgrep and Trivy configuration are present.
- TechDocs, OpenAPI and `catalog-info.yaml` are present.
- Development, staging and production Kustomize overlays render.
- The ServiceAccount references `ghcr-pull-secret`.
- CI publishes an immutable GHCR image and produces an SPDX SBOM.
- The release PR changes only the development overlay.

## Deployment

- Argo CD can read the repository when it is private.
- The target namespace contains the generated `ExternalSecret`.
- `ghcr-pull-secret` exists before the workload becomes Ready.
- Argo CD becomes Synced/Healthy.
- Backstage shows TechDocs, OpenAPI, Kubernetes and Argo CD status.

# Repository split and developer flow

## Ownership

- TuskerBlueprint owns Backstage, reusable templates, GitHub credentials, shared controllers and Argo CD Application registration.
- Each generated repository owns source, tests, documentation, CI/CD and environment overlays.

## Developer journey

1. The developer signs in through GitHub OAuth.
2. The developer selects **Create → Tusker Service**.
3. The developer selects public or private repository visibility.
4. Backstage creates the repository, grants push access and registers `catalog-info.yaml`.
5. The initial workflow tests, scans and publishes an immutable GHCR image.
6. CI opens a one-file development release PR.
7. The platform onboarding PR registers the service repository with Argo CD.
8. Argo CD creates the namespace and applies the generated `ExternalSecret`, which creates `ghcr-pull-secret`.
9. Kubernetes pulls the image whether the GHCR package is public or private.

## Credential boundary

GitHub credentials are runtime Kubernetes Secrets. Backstage uses its own token, Argo CD uses an organization-level `repo-creds` Secret, and workloads use a namespace-local Docker registry Secret replicated from `platform-secrets`. No generated repository contains credential material.

# TuskerBlueprint Internal Developer Platform

TuskerBlueprint is Stonetusker Systems' reference Internal Developer Platform built with Backstage, Argo CD, Kubernetes, GitHub Actions and platform observability/security services.

## Repository model

- `stonetusker/tuskerblueprint` owns Backstage, templates, shared services, GitHub credential distribution and Argo CD registration.
- Each generated service owns its source, tests, TechDocs, OpenAPI, CI/CD and Kustomize overlays.
- CI publishes immutable GHCR images and promotes a full SHA through a one-file release pull request.

## Public and private support

The Tusker Service template lets the developer choose **Private** or **Public** repository visibility. The same platform configuration supports both:

- Backstage credentials live in `backstage/backstage-github-credentials`.
- Argo CD private-repository credentials live in `argocd/argocd-github-org-repo-creds`.
- The source GHCR pull credential lives in `platform-secrets/ghcr-pull-credentials`.
- External Secrets Operator creates `ghcr-pull-secret` in approved namespaces.

No GitHub token or Docker config is committed to Git.

## Initial platform setup

```bash
scripts/backstage/configure-github-oauth-secret.sh
scripts/backstage/configure-github-platform-secret.sh
scripts/backstage/configure-argocd-readonly.sh
make validate
```

Then sync, in order:

```text
external-secrets
github-access
backstage-platform-resources
backstage
platform-root
```

See `docs/SETUP-FROM-SCRATCH.md`, `docs/GITHUB-CREDENTIALS-AND-PRIVATE-ACCESS.md`, `docs/DEVELOPER-DEMO-WORKFLOW.md` and `docs/REPOSITORY-SPLIT-AND-DEVELOPER-FLOW.md`.

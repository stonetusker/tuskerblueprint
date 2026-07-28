# Delivery and deployment

## Source validation

The demo-service workflow validates formatting, linting, type safety, unit tests,
coverage, secrets, SAST findings, dependencies, container vulnerabilities, and an
SPDX SBOM.

## Image publication

A successful push to `main` publishes:

```text
ghcr.io/stonetusker/tuskerblueprint-demo-service:<full-git-sha>
ghcr.io/stonetusker/tuskerblueprint-demo-service:main
```

The `main` tag exists only to bootstrap the first rollout. The workflow opens a
GitOps pull request that replaces it with the full immutable SHA.

## Deployment

After review and merge of the release pull request, Argo CD reconciles:

```text
workloads/demo-service/overlays/development
```

The rolling strategy keeps `maxUnavailable: 0`, so the current ready replica is
retained while a new release is evaluated by readiness checks.

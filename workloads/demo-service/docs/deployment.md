# Delivery and deployment

## Source validation

The demo-service workflow validates formatting, linting, type safety, unit tests,
coverage, secrets, SAST findings, dependencies, container vulnerabilities and an
SPDX SBOM. The browser UI is stored under `app/static/`, included in the same
container image and covered by endpoint tests.

## Image publication

A successful push to `main` publishes:

```text
ghcr.io/stonetusker/tuskerblueprint-demo-service:<full-git-sha>
ghcr.io/stonetusker/tuskerblueprint-demo-service:main
```

The `main` tag exists only to bootstrap the first rollout. The workflow opens a
GitOps pull request that replaces it with the full immutable SHA.

## Argo CD destination

Argo CD Application `demo-service-development` reads:

```text
Repository: git@github.com:stonetusker/tuskerblueprint.git
Path:       workloads/demo-service/overlays/development
Revision:   main
```

It deploys:

```text
Namespace:  demo-service-development
Deployment: demo-service
Service:    demo-service
```

The rolling strategy keeps `maxUnavailable: 0`, so the current ready replica is
retained while a new release is evaluated by readiness checks.

## Access

The Service is `ClusterIP`. Use:

```bash
scripts/demo/open-demo-ui.sh
```

Then open `http://localhost:8081/`. In-cluster callers use:

```text
http://demo-service.demo-service-development.svc.cluster.local
```

# Corrected delivery-platform demo source review

## Review scope

This review covers the buyer-facing demo API, CI/CD workflow, security gates,
Kustomize overlays, GitOps release updater, TechDocs source, Backstage service
template, observability configuration, and local validation scripts.

## Issues corrected in this revision

1. The demo validator no longer scans `.generated`, `node_modules`, virtual
   environments, build output, or test caches as maintained project YAML.
2. The validator now rejects duplicate YAML keys in maintained source.
3. The validator no longer requires `pytest-cov` merely to run source tests.
   When the plugin is present it enforces 85% coverage; otherwise it runs tests
   and prints a warning. GitHub Actions always installs `pytest-cov` and enforces
   the coverage gate.
4. Duplicate coverage arguments were removed from both `pyproject.toml` files.
   Coverage is now invoked explicitly in CI and Make targets.
5. `--no-cov`, which is itself provided by `pytest-cov`, was removed from the
   offline rendered-template test path.
6. Test runs now use temporary coverage/cache locations and no longer create
   `.coverage`, `coverage.xml`, `.pytest_cache`, or `__pycache__` in source.
7. MkDocs navigation paths were corrected to be relative to `docs_dir`.
8. Public and private service-template variants are both rendered, parsed, and
   tested. Public output must not require an image pull secret; private output
   must contain one.
9. Generated-service CI now has path filters, preventing an infinite release-PR
   loop when its own deployment overlay is merged.
10. Generated-service CI now runs explicit coverage, SARIF generation, Trivy
    source/image scans, SBOM generation, immutable publication, and digest
    capture.
11. The service template now defaults to a public repository for the reliable
    buyer demo. Private remains available but requires GHCR and Argo CD
    credentials.
12. The development workload now uses one steady-state replica because the demo
    notification map is intentionally in memory. Rolling updates still use one
    surge Pod and `maxUnavailable: 0`.
13. Traffic generation now reports successes and failures instead of silently
    claiming every request succeeded.
14. Recovery verification now fails clearly when port-forwarding or readiness
    does not recover.
15. Repository hygiene rules now ignore local generated trees while still
    rejecting generated artifacts inside maintained source.
16. A root `.gitignore` was added for Backstage generation, Node dependencies,
    Python environments, coverage, caches, and operating-system artifacts.
17. The frozen `python:3.12.8-slim` base was replaced with the maintained
    `python:3.12-slim-bookworm` line so CI does not start from an old patch image.
    Pin the validated digest before a production rollout.
18. Obsolete static NGINX content is removed by the included cleanup script.

## Validation completed

The corrected source passed:

- 213 maintained YAML files with duplicate-key protection
- 38 maintained Kustomize reference checks
- 282 structural checks
- Public service-template render, YAML parse, and tests
- Private service-template render, YAML parse, and tests
- Demo API tests with branch coverage
- 93.55% measured demo application coverage
- Full 85% coverage gate
- Immutable release-updater test
- Bash syntax checks for all shell scripts
- Existing IDP validator
- Runtime API smoke test
- Notification create/read flow
- Prometheus metrics output
- Controlled readiness-failure mode
- Exact reproduction test with malformed YAML inside
  `.generated/backstage/node_modules`
- Exact reproduction test without local coverage support

## Runtime validation still required in the target environment

This review environment did not provide a Docker daemon, GitHub Actions runner,
Kustomize CLI, or access to the user's Kubernetes cluster. The following remain
acceptance tests in the target environment:

- Docker image build and non-root container smoke test
- GitHub Actions execution
- Gitleaks and Semgrep action behavior
- Trivy filesystem and image policies
- GHCR publication and digest capture
- Automatic immutable release pull request
- Argo CD reconciliation
- Kubernetes rollout and image-pull authentication
- Prometheus scrape discovery
- Grafana dashboard queries
- Optional Alloy-to-Loki collection
- Backstage TechDocs generation tooling inside the deployed image

These limitations are stated explicitly; no live-cluster success is claimed by
this source review.

# Corrected Demo Source Validation Report

## Purpose

This report records the root causes corrected after the initial enhanced archive failed on the user's workstation, the validations performed on the corrected source, and the acceptance tests that still require the user's Docker/GitHub/Kubernetes environment.

## Reported failures reproduced

### Generated third-party YAML was parsed as maintained source

The original validator traversed `.generated/backstage/node_modules` and attempted to parse package-owned files such as:

```text
.generated/backstage/node_modules/crypto-browserify/.travis.yml
```

Those files are generated/vendor content and are not controlled by the repository. The corrected validator excludes `.generated`, `node_modules`, virtual environments, package caches, build output, and local test artifacts.

The failure was reproduced by placing a deliberately malformed `.travis.yml` under the exact generated path. The corrected validator ignored it and passed.

### Coverage options failed when pytest-cov was unavailable

Coverage options were previously duplicated between `pyproject.toml` and command-line arguments. The rendered-template validator also used `--no-cov`, which is itself supplied by the `pytest-cov` plugin and therefore fails when that plugin is absent.

The corrected implementation:

- removes coverage arguments from both `pyproject.toml` files;
- invokes coverage explicitly in CI and Make targets;
- detects whether `pytest-cov` is available locally;
- enforces 85% application coverage when available;
- runs tests without coverage and prints an explicit warning when it is unavailable;
- keeps CI coverage enforcement mandatory because CI installs `requirements-dev.txt`;
- writes caches and coverage data only to temporary directories.

The validator was tested with plugin auto-loading disabled and passed without `pytest-cov`.

## Additional issues corrected

1. MkDocs navigation entries are now relative to `docs_dir`.
2. Public and private Backstage service-template outputs are rendered and tested separately.
3. The generated-service workflow no longer retriggers itself when its release overlay PR is merged.
4. Immutable image digest capture is validated before opening the GitOps release PR.
5. The generated service defaults to public visibility for a reliable buyer demo; private mode includes the image-pull secret requirement.
6. Obsolete NGINX demo content is removed by `scripts/demo/cleanup-demo-source.sh`.
7. Repository hygiene excludes local generated/vendor trees while rejecting artifacts in maintained source.
8. The traffic generator and recovery verifier now fail clearly instead of reporting false success.
9. The development API uses one steady-state replica because its notification data is intentionally in memory.
10. A root `.gitignore` covers Backstage generation, Node dependencies, Python environments, coverage, caches, and operating-system files.

## Completed validation

The corrected source passed:

- 213 maintained YAML files with duplicate-key protection;
- 1 raw Jinja template correctly deferred to rendered validation;
- 38 maintained Kustomize reference checks;
- 282 structural checks;
- public generated-service render, YAML parsing, and tests;
- private generated-service render, YAML parsing, and tests;
- six demo API tests;
- 93.55% measured branch-aware application coverage;
- the 85% application coverage gate;
- the existing `scripts/validate_idp.py` checks;
- Bash syntax validation for every shell script;
- malformed generated/vendor YAML reproduction;
- validation with pytest plugin auto-loading disabled;
- repository hygiene after validation;
- changes-only patch application to a fresh copy of the supplied source;
- validation of the patched fresh copy.

## Environment limitations

The review environment did not provide all target-runtime tools. The following were not claimed as executed here:

- Docker image build and container health check;
- GitHub Actions execution;
- live Gitleaks, Semgrep, and Trivy action execution;
- GHCR push and digest verification against the registry;
- executable Kustomize rendering with `kubectl kustomize` or the Kustomize CLI;
- Argo CD reconciliation;
- Kubernetes rollout and private-image pull;
- Prometheus scraping;
- Grafana dashboard queries;
- Alloy-to-Loki log delivery;
- TechDocs generation inside the deployed Backstage container.

These are target-environment acceptance tests described in `NEXT_STEPS_AFTER_IMPORT.md`.

## Artifact recommendation

Use `StoneTusker_Delivery_Platform_Demo_Corrected_Changes.zip` on top of the current Git repository. It preserves files that may exist in the user's live repository but were absent from the uploaded snapshot.

Do not use the earlier `StoneTusker_Delivery_Platform_Demo_Changes_Only.zip` or `StoneTusker_Delivery_Platform_Demo_Enhanced_Sources.zip` artifacts.

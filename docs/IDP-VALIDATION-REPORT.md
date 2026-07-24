# IDP validation report

## Completed static validation

- 202 YAML files parsed with duplicate-key detection.
- 18 root catalog targets were confirmed present.
- 18 catalog entities and their owner, system, domain, API, and dependency relations resolved.
- 40 Kustomize files were checked for missing local resource references.
- 46 shell scripts passed `bash -n` syntax validation.
- Required Backstage, catalog, template, workload, and migration files were confirmed present.
- No recognized token, password, or private-key patterns were detected.
- No Kubernetes `Secret` manifest is committed.
- No `.git`, `.venv`, `node_modules`, `__MACOSX`, `__pycache__`, `.DS_Store`, or `*.pyc` content is included.
- Repository-relative Markdown links were checked.

## Validation that requires a connected build environment

The following checks could not run in the offline packaging environment and are intentionally implemented in GitHub Actions or the migration runbook:

- Downloading Backstage npm packages and compiling the custom application.
- Resolving the current Roadie Argo CD plugin compatibility matrix.
- Building and scanning the custom Backstage container image.
- Rendering the Backstage Helm chart against its remote repository.
- Executing `kubectl kustomize` with a local kubectl binary.
- Applying resources to the live cluster.
- Verifying GitHub OAuth, Argo CD token, Kubernetes plugin, and Software Template execution.

Do not switch the active Argo CD Application to `development-idp.yaml` until the **Backstage IDP Image** workflow succeeds and the required runtime Secrets are present.

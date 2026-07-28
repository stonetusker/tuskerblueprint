# StoneTusker Semgrep Container Workflow Fix

## Root cause

The workflow installed `semgrep==1.100.0` into the GitHub runner's Python 3.12 environment. At runtime, Semgrep imported OpenTelemetry instrumentation that imported `pkg_resources`. The runner environment did not provide `pkg_resources`, causing:

```text
ModuleNotFoundError: No module named 'pkg_resources'
```

This is a runner Python packaging failure, not a Semgrep finding.

## Correction

Semgrep now runs from the pinned official container:

```text
semgrep/semgrep:1.100.0
```

Both the current demo-service workflow and the reusable Backstage service template were updated. The workflows no longer install Semgrep with pip.

The container mounts the GitHub workspace read/write, scans only the maintained application source, writes SARIF into the workspace, and preserves blocking behavior through `--error`.

## Files changed

- `.github/workflows/demo-service-ci.yml`
- `software-templates/tusker-service/skeleton/service/.github/workflows/ci.yml`
- `scripts/demo/validate-demo-source.py`

## Validator safeguards

The source validator now requires:

- `semgrep/semgrep:1.100.0`
- explicit `--entrypoint semgrep`
- absence of `python -m pip install semgrep`

These checks apply to both the current demo service and future generated services.

## Validation completed

- 213 maintained YAML files parsed with duplicate-key protection
- 38 maintained Kustomize references checked
- 291 structural checks passed
- Public and private generated-service templates rendered and tested
- Six demo-service tests passed
- 93.55% branch-aware coverage, above the 85% gate
- Existing `scripts/validate_idp.py` passed
- All shell scripts passed `bash -n`
- Workflow assertions confirmed pip-based Semgrep is absent

The Semgrep image itself could not be pulled in the validation container because external Docker/network execution is unavailable there. GitHub Actions performs that target-environment pull and scan.

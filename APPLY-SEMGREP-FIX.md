# Apply the Semgrep workflow correction

From the repository root, extract this ZIP as an overlay:

```bash
unzip -o StoneTusker_Semgrep_Container_Workflow_Fix.zip -d .
```

Verify the pip installation is gone:

```bash
grep -RIn 'pip install semgrep' \
  .github/workflows/demo-service-ci.yml \
  software-templates/tusker-service/skeleton/service/.github/workflows/ci.yml \
  || true
```

Expected: no output.

Verify the pinned image:

```bash
grep -RIn 'semgrep/semgrep:1.100.0' \
  .github/workflows/demo-service-ci.yml \
  software-templates/tusker-service/skeleton/service/.github/workflows/ci.yml
```

Run validation:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 scripts/demo/validate-demo-source.py
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py
```

Review and commit:

```bash
git diff --check

git diff -- \
  .github/workflows/demo-service-ci.yml \
  software-templates/tusker-service/skeleton/service/.github/workflows/ci.yml \
  scripts/demo/validate-demo-source.py

git add \
  .github/workflows/demo-service-ci.yml \
  software-templates/tusker-service/skeleton/service/.github/workflows/ci.yml \
  scripts/demo/validate-demo-source.py

git commit -m "fix(ci): run Semgrep from pinned container"
git push
```

The next GitHub Actions run should display:

```text
Run Semgrep SAST with pinned container
```

It should no longer invoke `pysemgrep` or depend on runner-installed `pkg_resources`.

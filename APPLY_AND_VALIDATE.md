# Apply and validate the corrected demo patch

1. Create a branch from current `main`.
2. Extract this ZIP at the repository root. Preserve existing files not present in the ZIP.
3. Run `./scripts/demo/cleanup-demo-source.sh`.
4. Run `PYTHONDONTWRITEBYTECODE=1 python3 scripts/demo/validate-demo-source.py`.
5. Run `PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py`.
6. Run `find scripts -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n`.
7. Review `git diff --check`, `git status --short`, and `git diff --stat` before committing.

The demo validator now ignores `.generated`, `node_modules`, virtual environments, and test caches. It also works without `pytest-cov`; in that case it runs tests and prints a warning while GitHub Actions still enforces coverage.

# Contributing

1. Create a focused branch.
2. Keep secrets and generated files out of the repository.
3. Run `make idp-validate` and `make shell-check`.
4. Update documentation and catalog metadata when behavior changes.
5. Open a pull request with risk, validation, rollout, and rollback details.
6. Do not merge changes that leave an Argo CD Application in `Unknown` or `Degraded` without an approved exception.

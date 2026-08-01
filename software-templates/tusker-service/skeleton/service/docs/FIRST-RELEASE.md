# First immutable release

1. Confirm the platform owner configured Kubernetes GitHub credentials through `scripts/backstage/configure-github-platform-secret.sh` in TuskerBlueprint.
2. Open **Actions → Service CI and Release**.
3. Confirm formatting, type checks, tests, coverage, Gitleaks, Semgrep, Trivy and SBOM generation pass.
4. Confirm `ghcr.io/<owner>/<repository>:<full-commit-sha>` was published and verified through the authenticated workflow session.
5. Review the release PR. Only `deploy/overlays/development/kustomization.yaml` may change.
6. Approve workflow execution if GitHub requires it, then merge the release PR.
7. Merge the separate TuskerBlueprint onboarding PR.
8. Confirm `${{ values.name }}-development/ghcr-pull-secret` exists and Argo CD is `Synced` and `Healthy`.

The repository and package can be public or private. Private Git access uses the Argo CD organization credential, and private image access uses the Kubernetes-managed GHCR pull Secret.

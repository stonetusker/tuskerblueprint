# CI/CD and GitOps delivery

## Pull request

The workflow performs:

1. Formatting, linting, and strict type checking.
2. Unit tests and an 80 percent coverage gate.
3. Gitleaks secret scanning.
4. Semgrep static analysis.
5. Trivy filesystem and dependency scanning.
6. Container build and image vulnerability scanning.
7. SPDX SBOM generation.

## Main branch

After merge, the workflow publishes immutable and bootstrap image tags to GHCR. It then opens a release pull request that changes only the development image tag and release annotation.

## Deployment

After the release pull request is approved and merged, Argo CD detects the Git change and reconciles the development namespace. Manual cluster changes are corrected back to the approved Git state.

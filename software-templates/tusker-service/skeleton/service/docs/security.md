# Security

The container runs as UID/GID 10001, drops all capabilities, uses a read-only root filesystem and does not receive a Kubernetes API token. NetworkPolicies default-deny traffic and allow only approved ingress, DNS and workload-to-workload egress.

CI uses current-source Gitleaks, Semgrep, Trivy and an SPDX SBOM artifact. GitHub Advanced Security is not required.

The ServiceAccount references `ghcr-pull-secret`. TuskerBlueprint creates that Secret from a centrally stored Kubernetes credential through External Secrets Operator. No GitHub token or Docker configuration is committed to this repository.


Kubernetes Secret data is not a substitute for encryption at rest. Production clusters should enable API-server Secret encryption, apply least-privilege RBAC to `platform-secrets`, use a dedicated GHCR read-only machine credential, and rotate the source Secret regularly.

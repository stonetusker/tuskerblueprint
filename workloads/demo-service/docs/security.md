# Security controls

The reference workflow includes:

- Gitleaks secret scanning
- Semgrep SAST rules
- Trivy filesystem and dependency scanning
- Trivy container image scanning
- SPDX JSON SBOM generation
- Immutable SHA image tagging
- Git review before deployment
- Non-root runtime
- Read-only root filesystem
- Dropped Linux capabilities
- Disabled service-account token mounting
- Resource requests and limits
- Default-deny network policy

These controls support a security program. They do not by themselves establish
regulatory compliance or complete production security.

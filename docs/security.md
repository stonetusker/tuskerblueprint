# Security

Application workflows use GitHub Free-compatible security gates: current-source Gitleaks CLI, Semgrep container scanning, Trivy filesystem and image scanning, and SPDX SBOM artifacts. They do not depend on GitHub Advanced Security SARIF uploads.

Backstage publishing credentials are platform secrets and must never be committed. Historical credentials found by Gitleaks must be rotated and removed from Git history separately.

Workloads run as non-root, disable service-account token mounting, drop Linux capabilities, use a read-only root filesystem and are protected by default-deny NetworkPolicies.

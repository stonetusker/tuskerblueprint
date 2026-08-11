# TuskerBlueprint platform roadmap

This file describes repository implementation status. It does not assert the
health of a particular cluster; use scripts/demo/preflight.sh for live evidence.

## Current implementation

| Capability | Repository status | Acceptance needed |
| --- | --- | --- |
| VPS provisioning | Scaffold only | Add a real Terraform provider and managed resources, or document the external provisioning boundary |
| Ubuntu, user, kernel and k3s bootstrap | Ansible implementation present | Run idempotence and recovery tests on a clean host |
| Argo CD bootstrap and root application | Implementation present | Rebuild a cluster from scratch and record the result |
| Backstage catalog and Tusker Service template | Implementation present | Complete public and private disposable-service acceptance tests |
| Immutable application delivery | Implemented in the generated service | Verify CI gates, GHCR publication, release PR and Argo CD deployment |
| External Secrets and GitHub access | Implementation present | Verify namespace restrictions, rotation and recovery |
| Prometheus and Grafana | Implementation present | Verify live scrape targets and the provisioned service dashboard |
| Loki | Implementation present | Resolve any Argo CD Unknown state and test retention/recovery |
| Alloy log collection | Optional, not activated by the root application | Validate on the target architecture before activation |
| Kyverno | Implementation present | Resolve all degraded policies and add enforcement acceptance tests |
| Public ingress and TLS | Environment-specific | Configure DNS, certificates and edge exposure for the selected host |

## Before the recorded demo

- Make every application required by scripts/demo/preflight.sh Synced and Healthy.
- Create a disposable service from Backstage and complete its first immutable release.
- Verify two ready application replicas, Prometheus data and the Grafana dashboard.
- Use Alloy only after it passes target-cluster validation; otherwise demonstrate
  kubectl logs and state that centralized log collection is the next step.
- Remove disposable repositories and generated workload registrations after rehearsal.

## Post-demo priorities

1. Make Backstage generation reproducible by pinning the generator and committing a
   reviewed lockfile/runtime source.
2. Implement real infrastructure provisioning and clean-room disaster-recovery tests.
3. Add signed image attestations and Kyverno verification after policy health is stable.
4. Add staging/production promotion with approvals, rollback evidence and SLOs.
5. Add a self-service service-retirement workflow with audited GitHub and GitOps cleanup.

## Production-readiness gate

Production readiness requires clean-room provisioning, enforced security policy,
tested backup/restore, documented SLOs and on-call ownership, capacity testing,
credential rotation and repeatable rollback. A successful sales demo is not that gate.

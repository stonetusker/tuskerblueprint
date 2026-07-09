# TuskerBlueprint Platform Roadmap

## Purpose

This document tracks the implementation status of all platform capabilities defined by the Tusker Platform Reference Architecture (TPRA).

It provides a single view of platform maturity and implementation progress.

---

# Platform Status

| Capability                  | Status         | Owner     | Deployment | Notes                   |
| --------------------------- | -------------- | --------- | ---------- | ----------------------- |
| Infrastructure Provisioning | ✅ Complete     | Terraform | Terraform  | VPS provisioning        |
| Ubuntu Bootstrap            | ✅ Complete     | Ansible   | Ansible    | Ubuntu Server 24.04 LTS |
| User Management             | ✅ Complete     | Ansible   | Ansible    | Bootstrap               |
| SSH Configuration           | ✅ Complete     | Ansible   | Ansible    | Bootstrap               |
| Firewall                    | ✅ Complete     | Ansible   | Ansible    | Bootstrap               |
| Kernel Configuration        | ✅ Complete     | Ansible   | Ansible    | Bootstrap               |
| k3s                         | ✅ Complete     | Ansible   | Ansible    | Bootstrap               |
| kubectl                     | ✅ Complete     | Ansible   | Ansible    | Bootstrap               |
| Argo CD Installation        | ✅ Complete     | Ansible   | Ansible    | Bootstrap               |
| Repository Registration     | ✅ Complete     | Ansible   | Ansible    | Bootstrap               |
| Root Application            | ✅ Complete     | Ansible   | Ansible    | GitOps handoff complete |
| Traefik                     | ✅ Complete    | Git       | Argo CD    | GitOps implementation   |
| cert-manager                | ⏳ Planned      | Git       | Argo CD    | PR-003                  |
| External Secrets Operator   | ⏳ Planned      | Git       | Argo CD    | PR-004                  |
| Doppler Integration         | ⏳ Planned      | Git       | Argo CD    | PR-005                  |
| Kyverno                     | ⏳ Planned      | Git       | Argo CD    | PR-006                  |
| Prometheus                  | ⏳ Planned      | Git       | Argo CD    | PR-007                  |
| Grafana                     | ⏳ Planned      | Git       | Argo CD    | PR-008                  |
| Loki                        | ⏳ Planned      | Git       | Argo CD    | PR-009                  |
| Backstage                   | ⏳ Planned      | Git       | Argo CD    | PR-010                  |
| Reference Workloads         | ⏳ Planned      | Git       | Argo CD    | PR-011                  |

---

# Milestones

## Phase 1 – Platform Bootstrap

Status: ✅ Complete

Deliverables:

* Infrastructure provisioned
* Kubernetes installed
* Argo CD installed
* Repository registered
* Root Application deployed
* GitOps handoff completed

---

## Phase 2 – Platform Services

Status: 🚧 In Progress

Deliverables:

* Traefik
* cert-manager
* External Secrets Operator
* Doppler
* Kyverno
* Prometheus
* Grafana
* Loki
* Backstage

---

## Phase 3 – Platform Workloads

Status: ⏳ Planned

Deliverables:

* Reference applications
* Developer onboarding
* Self-service platform

---

# Success Criteria

The platform is considered production-ready when:

* All platform services are GitOps managed.
* All workloads are deployed via Argo CD.
* Observability is fully operational.
* Security policies are enforced.
* Secrets are externally managed.
* Documentation is synchronized with implementation.


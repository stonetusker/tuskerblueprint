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
| cert-manager                | ✅ Complete     | Git       | Argo CD    | GitOps implementation   |
| External Secrets Operator   | ✅ Implemented (scaffolded) | Git       | Argo CD    | GitOps implementation   |
| Doppler Integration         | ✅ Implemented (scaffolded) | Git       | Argo CD    | GitOps implementation   |
| Kyverno                     | ✅ Implemented (scaffolded) | Git       | Argo CD    | GitOps implementation   |
| Prometheus                  | ✅ Implemented (scaffolded) | Git       | Argo CD    | GitOps implementation   |
| Grafana                     | ✅ Implemented (scaffolded) | Git       | Argo CD    | GitOps implementation   |
| Loki                        | ✅ Implemented (scaffolded) | Git       | Argo CD    | GitOps implementation   |
| Backstage                   | ✅ Implemented (scaffolded) | Git       | Argo CD    | GitOps implementation   |
| Reference Workloads         | ✅ Implemented (scaffolded) | Git       | Argo CD    | GitOps implementation   |

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


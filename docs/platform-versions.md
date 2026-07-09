# TuskerBlueprint Platform Compatibility Matrix

## Purpose

This document defines the approved versions of all platform components used by the TuskerBlueprint Platform Reference Architecture (TPRA).

It is the authoritative source for:

* Platform component versions
* Upgrade planning
* Compatibility validation
* Platform release management

Every platform component upgrade must update this document as part of the same pull request.

---

# Platform Information

| Property                | Value                   |
| ----------------------- | ----------------------- |
| Platform                | TuskerBlueprint         |
| Architecture            | TPRA                    |
| Deployment Model        | GitOps                  |
| Kubernetes Distribution | k3s                     |
| Operating System        | Ubuntu Server 24.04 LTS |

---

# Platform Components

| Component                 | Current Version | Upgrade Policy  | Status   | Notes                |
| ------------------------- | --------------: | --------------- | -------- | -------------------- |
| Ubuntu Server             |       24.04 LTS | LTS Only        | Approved | Managed by Ansible   |
| k3s                       |             TBD | Stable Releases | Planned  | Managed by Ansible   |
| Kubernetes                |             TBD | k3s Compatible  | Planned  | Managed by k3s       |
| Argo CD                   |           3.1.1 | Stable Minor    | Approved | Installed by Ansible |
| Traefik                   |          37.1.0 | Stable Minor    | Approved | Managed by GitOps    |
| cert-manager              |             TBD | Stable Minor    | Planned  | Managed by GitOps    |
| External Secrets Operator |             TBD | Stable Minor    | Planned  | Managed by GitOps    |
| Doppler Operator          |             TBD | Stable Minor    | Planned  | Managed by GitOps    |
| Kyverno                   |             TBD | Stable Minor    | Planned  | Managed by GitOps    |
| Prometheus                |             TBD | Stable Minor    | Planned  | Managed by GitOps    |
| Grafana                   |             TBD | Stable Minor    | Planned  | Managed by GitOps    |
| Loki                      |             TBD | Stable Minor    | Planned  | Managed by GitOps    |
| Backstage                 |             TBD | Stable Minor    | Planned  | Managed by GitOps    |

---

# Supporting Toolchain

| Component                 | Version       | Notes                       |
| ------------------------- | ------------- | --------------------------- |
| Terraform                 | TBD           | Infrastructure provisioning |
| Ansible                   | TBD           | Platform bootstrap          |
| Helm                      | TBD           | Helm chart management       |
| Kustomize                 | TBD           | GitOps composition          |
| kubectl                   | TBD           | Kubernetes CLI              |
| GitHub Actions            | GitHub Hosted | CI/CD                       |
| GitHub Container Registry | GitHub Hosted | OCI Registry                |

---

# Versioning Policy

## Infrastructure

Infrastructure components should use Long Term Support (LTS) releases wherever available.

## Kubernetes

Follow the supported k3s release cadence.

Avoid unsupported Kubernetes versions.

## Platform Services

Platform services should use:

* Stable releases
* Pinned versions
* Explicit upgrade pull requests

Automatic upgrades are not permitted.

## Helm Charts

Every Helm chart version must be pinned.

Floating versions such as:

* latest
* "*"

are prohibited.

---

# Upgrade Procedure

Every platform upgrade must include:

1. Version update
2. Compatibility validation
3. Documentation update
4. Validation evidence
5. Rollback verification

---

# Validation Checklist

* Component version updated
* GitOps reconciliation successful
* Platform healthy
* No Argo CD drift
* Monitoring operational
* Rollback validated

---

# Platform Release History

| Date       | Component                    | Version | Notes                     |
| ---------- | ---------------------------- | ------- | ------------------------- |
| 2026-07-09 | Initial Compatibility Matrix | 1.0     | Initial platform baseline |


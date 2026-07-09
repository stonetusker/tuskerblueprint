# TuskerBlueprint GitOps Standards

## Purpose

This document defines the GitOps implementation standards for the TuskerBlueprint Platform.

It standardizes how GitOps is implemented across the entire platform.

This document complements the TPRA and the Implementation Guide.

All GitOps implementations must comply with this standard.

---

# GitOps Principles

Git is the single source of truth.

GitOps is the only deployment mechanism after bootstrap.

Every desired platform state must exist in Git.

Manual changes to Kubernetes resources are prohibited after bootstrap.

---

# GitOps Ownership

Terraform owns infrastructure.

Ansible owns bootstrap.

Git owns platform services.

Argo CD reconciles Git into Kubernetes.

Ownership never overlaps.

---

# Bootstrap Boundary

Bootstrap ends after:

1. Argo CD Installation
2. Repository Registration
3. Root Application Deployment
4. Validation

Once complete:

GitOps owns the platform.

Ansible no longer deploys Kubernetes resources.

---

# GitOps Flow

Developer

↓

Git Commit

↓

GitHub

↓

GitHub Actions

↓

Git Repository

↓

Argo CD

↓

Kubernetes

↓

Continuous Reconciliation

---

# App-of-Apps Architecture

The platform uses the App-of-Apps pattern.

Hierarchy:

Platform Root

↓

Capability Domain

↓

Platform Capability

This hierarchy must remain stable.

---

# Application Hierarchy

Platform Root

↓

Networking

↓

Traefik

Platform Root

↓

Security

↓

cert-manager

↓

External Secrets Operator

↓

Doppler

↓

Kyverno

Platform Root

↓

Observability

↓

Prometheus

↓

Grafana

↓

Loki

Platform Root

↓

Developer Platform

↓

Backstage

---

# Capability Domains

Platform Applications are grouped into capability domains.

Networking

Security

Observability

Developer Platform

Every new platform capability must belong to one of these domains.

---

# Repository Layout

GitOps repository layout is frozen.

```text
gitops/

bootstrap/

environments/

projects/

appsets/

applications/

root/

platform/

networking/

security/

observability/

developer-platform/

workloads/
```

Repository redesign is prohibited without an approved ADR.

---

# Root Applications

The platform consists of multiple Root Applications.

Platform Root

Networking Root

Security Root

Observability Root

Developer Platform Root

Each Root Application owns its capability domain.

---

# Argo CD Standards

Use:

* Argo CD Applications
* AppProjects
* Automated Sync
* Self Heal
* Prune

Enable:

* CreateNamespace
* ApplyOutOfSyncOnly
* Foreground Pruning

Disable manual synchronization unless troubleshooting.

---

# Helm Standards

Use:

Official upstream Helm charts

Native Argo CD Helm support

Pinned chart versions

Do not use:

Wrapper Helm charts

Rendered manifests

Floating versions

latest

Wildcard versions

---

# Environment Strategy

Supported environments:

Development

Staging

Production

Every environment is independent.

Configuration differences should be minimal.

---

# Namespace Strategy

Each platform capability owns its namespace.

Examples:

traefik

cert-manager

external-secrets

monitoring

grafana

loki

backstage

Namespaces are created by GitOps.

---

# Dependency Management

Dependencies must be explicit.

Preferred order:

Networking

↓

Security

↓

Observability

↓

Developer Platform

Avoid circular dependencies.

---

# Synchronization

Applications should reconcile automatically.

Self-healing must remain enabled.

Pruning must remain enabled.

Platform drift is unacceptable.

---

# Repository Registration

Repository registration is part of bootstrap.

It is never performed manually.

Repository registration is owned exclusively by Ansible.

---

# Root Application

Root Application bootstrap is owned by Ansible.

After deployment:

GitOps owns the platform.

---

# Secrets

Git must never contain:

Passwords

API Keys

Certificates

Private Keys

Secrets must be managed through:

External Secrets Operator

↓

Doppler

---

# Validation

Every GitOps implementation must validate:

Application Healthy

Application Synced

Pods Running

Services Available

Ingress Operational

Metrics Available

---

# Rollback

Rollback must occur through Git.

Rollback procedure:

Git Revert

↓

Git Push

↓

Argo CD Reconciliation

Manual rollback is prohibited.

---

# Operational Principles

GitOps must always provide:

Reproducibility

Auditability

Observability

Repeatability

Deterministic deployments

---

# Future Growth

Future platform capabilities must follow the same GitOps model.

Do not introduce multiple deployment models.

Maintain one consistent GitOps architecture across the platform.

---

# Compliance

Every GitOps implementation must comply with:

TPRA

Accepted ADRs

Implementation Guide

Platform Standards

GitOps Standards

Non-compliant implementations must not be merged.


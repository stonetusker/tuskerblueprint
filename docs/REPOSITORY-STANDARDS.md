# TuskerBlueprint Repository Standards

## Purpose

This document defines the repository standards for the TuskerBlueprint Platform.

It establishes the canonical repository layout, directory ownership, file organization, naming conventions, and implementation rules.

All future repository changes must comply with this document.

---

# Repository Philosophy

The repository is organized around platform responsibilities rather than technologies.

Every directory has a single responsibility.

Repository ownership is explicit.

Repository structure is considered stable.

Do not redesign the repository without an approved Architecture Decision Record (ADR).

---

# Top-Level Repository Layout

```text
tuskerblueprint/

docs/

gitops/

infrastructure/

platform-services/

workloads/

.github/

scripts/
```

No additional top-level directories should be introduced without architectural review.

---

# Directory Responsibilities

## docs/

Platform governance.

Architecture.

Standards.

Runbooks.

Architecture Decision Records.

No implementation YAML belongs here.

---

## gitops/

Contains every GitOps deployment artifact.

Examples:

* Applications
* Root Applications
* AppProjects
* Environment composition
* ApplicationSets

No Terraform.

No Ansible.

No shell scripts.

---

## infrastructure/

Infrastructure automation.

Contains:

Terraform

Ansible

Bootstrap automation

Nothing inside this directory is managed by Argo CD.

---

## platform-services/

Contains reusable platform service configuration.

Examples:

Traefik

cert-manager

External Secrets Operator

Kyverno

Prometheus

Grafana

Loki

Backstage

This directory never contains workload-specific configuration.

---

## workloads/

Business applications.

Reference workloads.

Developer workloads.

No platform infrastructure belongs here.

---

## scripts/

Repository automation.

Developer utilities.

Validation helpers.

Scripts must never replace GitOps.

---

## .github/

GitHub Actions

Issue templates

Pull request templates

Repository automation

---

# GitOps Layout

```text
gitops/

bootstrap/

projects/

environments/

appsets/

applications/

    root/

    platform/

    workloads/
```

This layout is frozen.

---

# Platform Capability Layout

Every platform capability follows exactly the same structure.

Example:

```text
gitops/

applications/

platform/

networking/

traefik/

application.yaml

values/

development.yaml

staging.yaml

production.yaml

README.md

CHANGELOG.md
```

Every capability must contain:

Application

Values

Documentation

Change history

---

# Capability Domains

Platform capabilities are grouped into:

Networking

Security

Observability

Developer Platform

Every capability belongs to exactly one domain.

---

# Naming Standards

Use lowercase.

Use hyphens.

Examples:

external-secrets

developer-platform

cert-manager

Avoid:

CamelCase

snake_case

Abbreviations unless they are industry standard.

---

# File Naming Standards

Application manifests:

application.yaml

Domain root:

root-application.yaml

Values:

development.yaml

staging.yaml

production.yaml

Documentation:

README.md

CHANGELOG.md

Use consistent names across all platform capabilities.

---

# Documentation Requirements

Every platform capability must include:

README.md

CHANGELOG.md

README must describe:

Purpose

Architecture

Configuration

Validation

Rollback

CHANGELOG must document:

Version

Changes

Upgrade notes

---

# Version Management

Pinned versions only.

Never use:

latest

*

floating versions

Platform versions are tracked in:

docs/platform-versions.md

---

# Configuration Standards

Environment-specific configuration belongs only in:

values/

Do not duplicate configuration.

Do not hardcode environment values.

---

# Security Standards

Never commit:

Secrets

Passwords

Private keys

Certificates

Tokens

Secrets are managed externally.

---

# Validation Standards

Every platform capability must include:

Validation procedure

Rollback procedure

Health verification

Operational notes

---

# Repository Ownership

| Directory         | Owner                |
| ----------------- | -------------------- |
| infrastructure    | Terraform / Ansible  |
| gitops            | Git / Argo CD        |
| platform-services | Git                  |
| workloads         | Git                  |
| docs              | Platform Engineering |

Ownership must remain explicit.

---

# Prohibited Practices

Do not introduce:

Manual deployment manifests

Rendered Helm templates

Duplicate configuration

Environment-specific branches

Floating versions

Technology-specific directory layouts

Repository sprawl

---

# Repository Evolution

Repository evolution is controlled by Architecture Decision Records (ADRs).

Structural changes require:

Architecture review

ADR approval

Documentation update

Implementation update

---

# AI Implementation Rules

When generating repository content:

Always use existing directory structure.

Never invent new top-level directories.

Never duplicate existing capabilities.

Never redesign repository layout.

Generate production-ready files only.

Every generated file must include:

Correct repository path

Complete implementation

Validation guidance

Rollback guidance

---

# Compliance

Every repository change must comply with:

TPRA

Accepted ADRs

Implementation Guide

Platform Standards

GitOps Standards

Repository Standards

Changes that violate these standards must not be merged.


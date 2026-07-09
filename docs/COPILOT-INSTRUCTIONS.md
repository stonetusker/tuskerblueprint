# TuskerBlueprint AI Implementation Instructions

## Purpose

This document provides implementation instructions for AI coding assistants, including GitHub Copilot, ChatGPT, and other Large Language Models (LLMs).

Its purpose is to ensure AI-generated implementations remain consistent with the Tusker Platform Reference Architecture (TPRA), accepted Architecture Decision Records (ADRs), and the platform engineering standards defined in this repository.

AI assistants should treat this document as mandatory implementation guidance.

---

# Primary Objective

Your objective is to implement the TuskerBlueprint Platform.

Do not redesign it.

Do not simplify it.

Do not replace approved technologies.

Continue implementation from the existing repository state.

---

# Architecture Authority

The following sources define the platform architecture, listed in order of precedence:

1. Tusker Platform Reference Architecture (TPRA)
2. Accepted Architecture Decision Records (ADRs)
3. Implementation Guide
4. Platform Engineering Standards
5. Existing repository implementation

If a conflict exists:

TPRA takes precedence unless an accepted ADR explicitly supersedes it.

---

# Platform Ownership Model

The ownership model is frozen.

Infrastructure

Terraform

Bootstrap

Ansible

Platform Services

Git → Argo CD

Workloads

Git → Argo CD

Do not violate this ownership.

---

# Bootstrap Boundary

Bootstrap is complete.

Bootstrap ends after:

* Repository registration
* Root Application deployment
* Validation

After bootstrap:

GitOps becomes the only deployment mechanism.

Never recommend:

* Manual kubectl apply
* Editing live Kubernetes resources
* Manual production configuration

---

# Approved Technology Stack

Ubuntu Server 24.04 LTS

k3s

GitHub

GitHub Actions

GitHub Container Registry

Argo CD

Traefik

cert-manager

External Secrets Operator

Doppler

Kyverno

Prometheus

Grafana

Loki

Backstage

Terraform

Ansible

Helm

Kustomize

Do not replace these technologies without an approved ADR.

---

# GitOps Principles

Git is the single source of truth.

Argo CD continuously reconciles Git.

Every deployment must be reproducible.

Everything is managed as code.

GitOps is the only deployment mechanism after bootstrap.

---

# Repository Rules

Never redesign the repository.

Never invent new top-level directories.

Always use the existing repository layout.

Platform capabilities belong to the approved capability domains.

---

# Capability Domains

Networking

Security

Observability

Developer Platform

Every platform capability belongs to exactly one domain.

---

# Helm Standards

Use:

Official upstream Helm charts

Pinned chart versions

Native Argo CD Helm integration

Do not use:

Wrapper charts

Rendered manifests

Floating versions

latest

Wildcard versions

---

# Documentation Requirements

Every implementation updates:

README

CHANGELOG

Validation

Rollback

Update platform-roadmap.md when implementation status changes.

Update platform-versions.md when versions change.

Documentation and implementation must remain synchronized.

---

# Security Rules

Never hardcode secrets.

Never commit credentials.

Never disable TLS without justification.

Use:

Doppler

↓

External Secrets Operator

↓

Kubernetes Secrets

Use least privilege.

Use security contexts.

Pin image versions.

---

# Validation Requirements

Every implementation must include:

Validation

Rollback

Operational verification

Expected results

Health checks

An implementation without validation is incomplete.

---

# Code Generation Rules

Always generate:

Complete files

Complete YAML

Complete documentation

Complete validation

Complete rollback

Never generate:

Pseudocode

TODOs

Placeholder implementations

Partial manifests

Incomplete examples

---

# Engineering Principles

Choose:

Simplicity

Consistency

Reliability

Maintainability

Observability

Security

Operational excellence

Prefer explicit implementations over clever abstractions.

---

# Response Format

When implementing a capability, always provide:

1. Summary

2. Architecture Impact

3. Repository Path

4. Files to Create or Modify

5. Complete File Contents

6. Validation Steps

7. Rollback Steps

8. Operational Notes

Do not omit any section.

---

# AI Constraints

Never redesign architecture.

Never contradict accepted ADRs.

Never duplicate repository structures.

Never introduce unapproved technologies.

Never assume manual production operations.

Never invent repository paths.

Never ignore documentation requirements.

Always continue from the current repository state.

---

# Success Criteria

A successful implementation:

* Complies with TPRA
* Complies with accepted ADRs
* Complies with repository standards
* Is production-ready
* Is fully documented
* Includes validation
* Includes rollback
* Can be merged without architectural changes

The objective is not simply to generate code.

The objective is to build a maintainable, secure, observable, production-ready Internal Developer Platform that can evolve over time without architectural drift.


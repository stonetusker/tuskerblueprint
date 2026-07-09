# TuskerBlueprint Security Standards

## Purpose

This document defines the security baseline for the TuskerBlueprint Platform.

Every platform capability, Kubernetes resource, GitHub workflow, Terraform module, Ansible role, and GitOps deployment must comply with these standards.

Security is not optional.

Security is implemented by default.

---

# Security Philosophy

TuskerBlueprint follows the principle of **Secure by Default**.

Every platform capability should:

* Minimize attack surface
* Follow least privilege
* Reduce operational risk
* Prevent configuration drift
* Support auditability

Security must never depend on manual operator actions.

---

# Security Principles

The platform adopts the following principles:

* Least Privilege
* Zero Trust
* Defense in Depth
* Immutable Infrastructure
* GitOps
* Secrets Externalization
* Continuous Validation
* Policy Enforcement
* Supply Chain Security

---

# Secrets Management

Secrets must never exist in Git.

The following are prohibited:

* Passwords
* Tokens
* API Keys
* SSH Private Keys
* TLS Certificates
* Cloud Credentials

Secrets are managed using:

Doppler

↓

External Secrets Operator

↓

Kubernetes Secret

Applications consume only Kubernetes Secrets.

No application should communicate directly with Doppler.

---

# Identity

Human access must use:

SSH Keys

GitHub Identity

Least Privilege

Root login is prohibited.

Password authentication is prohibited.

---

# Kubernetes Security

Every workload should use:

* Dedicated ServiceAccount
* Dedicated Namespace
* RBAC
* Security Context
* Resource Limits
* Resource Requests

Avoid using the default ServiceAccount.

---

# Pod Security

Every Pod should:

Run as non-root whenever supported.

Drop unnecessary Linux capabilities.

Disable privilege escalation.

Use read-only root filesystem where supported.

Specify:

* runAsNonRoot
* seccompProfile
* fsGroup
* runAsUser

Privileged containers are prohibited unless explicitly approved.

---

# RBAC

Every platform capability should have the minimum permissions required.

Avoid:

cluster-admin

wildcard permissions

unrestricted API access

RBAC should be explicitly documented.

---

# Network Security

Every namespace should support Network Policies.

Default posture:

Deny by default.

Explicitly allow required traffic.

Avoid unrestricted east-west communication.

---

# TLS

All ingress traffic should use TLS.

TLS certificates are managed by cert-manager.

Certificates must never be manually installed.

Self-signed certificates are permitted only for local development.

---

# Container Images

Only trusted images should be deployed.

Preferred registries:

* GitHub Container Registry
* Official upstream registries

Avoid:

Unknown publishers

Community images without provenance

Unmaintained images

Always pin image versions.

---

# Supply Chain Security

Every image should support:

* Immutable tags
* Signed releases where available
* Published checksums
* Vendor-supported releases

Floating image tags are prohibited.

---

# Helm Charts

Only official upstream Helm charts should be used.

Chart versions must be pinned.

Avoid community forks unless formally approved.

---

# GitHub Security

GitHub should enable:

* Branch protection
* Pull request reviews
* Secret scanning
* Dependabot
* Code scanning

Direct commits to protected branches should be restricted.

---

# GitHub Actions

GitHub Actions should:

Use pinned action versions.

Avoid untrusted third-party actions.

Use GitHub OIDC where applicable.

Do not store long-lived credentials.

---

# Kubernetes Admission Control

Kyverno is the platform policy engine.

Admission policies should enforce:

* Non-root containers
* Resource limits
* Required labels
* Approved registries
* Security contexts

Policy exceptions should be documented.

---

# Namespace Isolation

Every platform capability owns its namespace.

Cross-namespace communication should be explicit.

Avoid sharing namespaces between unrelated capabilities.

---

# Resource Management

Every deployment should define:

Resource Requests

Resource Limits

Avoid unlimited CPU or memory allocation.

---

# Logging

Sensitive information must never appear in logs.

Avoid logging:

Passwords

Tokens

Secrets

Certificates

Personal data

Audit logs should remain enabled.

---

# Observability

Security events should be observable.

Platform monitoring should expose:

Authentication failures

Certificate status

Admission failures

Policy violations

Secret synchronization status

---

# Backup

Configuration is backed up through Git.

Secrets remain external.

Recovery procedures should restore infrastructure without exposing credentials.

---

# Incident Response

Every platform capability should support:

Isolation

Rollback

Recovery

Auditability

Operational procedures should be documented.

---

# Compliance

Every platform implementation must comply with:

TPRA

Accepted ADRs

Implementation Guide

Platform Standards

GitOps Standards

Repository Standards

Engineering Standards

Security Standards

---

# AI Implementation Rules

When generating security-related code:

Always:

* Use least privilege.
* Use dedicated ServiceAccounts.
* Use RBAC.
* Use Security Contexts.
* Use Resource Limits.
* Use Resource Requests.
* Use official images.
* Pin versions.
* Externalize secrets.

Never:

* Hardcode secrets.
* Disable TLS.
* Use privileged containers without justification.
* Use wildcard RBAC permissions.
* Use floating versions.
* Recommend manual secret creation.

Security is mandatory.

There are no exceptions without an approved Architecture Decision Record (ADR).


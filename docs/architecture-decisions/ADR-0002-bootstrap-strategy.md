# ADR-0002 – Platform Bootstrap Strategy

## Status

Accepted

## Context

A repeatable bootstrap process is required to establish the platform before GitOps assumes responsibility.

## Decision

Bootstrap sequence:

1. Terraform provisions infrastructure.
2. Ansible configures the operating system.
3. Ansible installs k3s.
4. Ansible installs Argo CD.
5. Ansible registers the Git repository.
6. Ansible deploys the Root Application.
7. GitOps assumes ownership.

## Consequences

* Bootstrap is repeatable.
* No manual production deployment.
* Clear handoff from imperative automation to declarative GitOps.


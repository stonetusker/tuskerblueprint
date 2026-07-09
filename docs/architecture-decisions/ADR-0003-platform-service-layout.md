# ADR-0003 – Platform Service Repository Layout

## Status

Accepted

## Context

Platform services require a consistent repository structure to improve maintainability and onboarding.

## Decision

* `gitops/` contains GitOps orchestration artifacts.
* `platform-services/` contains platform service configuration.
* `workloads/` contains business workloads.
* `infrastructure/` contains Terraform and Ansible.

## Consequences

* Clear separation of concerns.
* Consistent service implementation.
* Simplified repository navigation.


# ADR-0004 – Argo CD Native Helm

## Status

Accepted

## Context

The platform requires a consistent method for deploying upstream Helm charts.

## Decision

Platform services use Argo CD's native Helm integration.

Charts are consumed from upstream repositories.

Helm chart versions are pinned.

Environment-specific configuration is maintained in Git.

## Consequences

* Minimal maintenance overhead.
* Simple chart upgrades.
* Declarative configuration.
* Alignment with GitOps principles.


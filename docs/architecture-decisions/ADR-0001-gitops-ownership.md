# ADR-0001 – Platform Ownership Model

## Status

Accepted

## Context

The platform requires clear ownership boundaries between infrastructure provisioning, platform bootstrap, and ongoing operations.

## Decision

Ownership is defined as follows:

| Component         | Owner         |
| ----------------- | ------------- |
| Infrastructure    | Terraform     |
| Bootstrap         | Ansible       |
| Platform Services | Git → Argo CD |
| Workloads         | Git → Argo CD |

Bootstrap concludes after the Root Application has been successfully deployed and validated.

GitOps is the only deployment mechanism after bootstrap.

## Consequences

* Infrastructure remains reproducible.
* Bootstrap is deterministic.
* Operational drift is minimized.
* Platform services are managed declaratively.
* Manual production changes are prohibited.


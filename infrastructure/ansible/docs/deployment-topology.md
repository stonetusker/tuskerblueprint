# Deployment Topology

## Current Environment

| Property | Value |
|----------|-------|
| Environment | Development |
| Deployment Model | Single Node |
| Operating System | Ubuntu Server 24.04 LTS |
| Kubernetes | k3s (planned) |
| GitOps | Argo CD (planned) |

## Node

| Name | Role |
|------|------|
| VPS8 | k3s Server + Platform Services |

All platform services are currently deployed to the single control-plane node.

This includes:

- Argo CD
- Traefik
- cert-manager
- External Secrets Operator
- Kyverno
- Prometheus
- Grafana
- Loki
- Backstage

## Future Evolution

The automation is designed for multi-node deployments.

When worker nodes are introduced:

- Existing playbooks remain unchanged.
- Only the inventory is expanded.
- Platform capabilities continue to work without modification.

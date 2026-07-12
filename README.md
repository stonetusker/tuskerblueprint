# TuskerBlueprint

TuskerBlueprint is a production-ready Internal Developer Platform (IDP)
reference implementation built according to the Tusker Platform Reference
Architecture (TPRA).

## Goals

- GitOps-first
- Infrastructure as Code
- Secure by Default
- Kubernetes Native
- Observable
- Reproducible
- Production Ready

## Technology Stack

- Ubuntu Server 24.04 LTS
- k3s
- Argo CD
- Traefik
- cert-manager
- Kyverno
- External Secrets Operator
- Doppler
- Prometheus
- Grafana
- Loki
- Backstage
- Terraform
- Ansible
- Helm
- Kustomize
- GitHub Actions

## Repository Structure

- infrastructure/
- gitops/
- platform-services/
- workloads/
- docs/

## Current Platform Capability Coverage

The repository now includes GitOps-ready scaffolds for the core TPRA-aligned platform capabilities:

- Networking: Traefik ingress and routing
- Security: cert-manager, External Secrets Operator, Doppler, Kyverno
- Observability: Prometheus, Grafana, Loki
- Developer Platform: Backstage
- Workloads: reference workload onboarding and deployment manifests

These capabilities are organized under the GitOps application tree and are intended to be reconciled by Argo CD.

See the TPRA documentation for architecture decisions.

# Backstage Software Catalog Architecture

## Purpose

This architecture defines a reusable catalog model for TuskerBlueprint that supports platform capabilities and future application onboarding while remaining GitOps-managed and aligned with the repository's existing Argo CD structure.

The catalog is designed to register:

- Components
- Systems
- APIs
- Resources
- Groups
- Users
- Locations
- Templates

It also supports automatic registration of the platform capabilities that already exist in the repository.

---

## 1. Catalog Model

Backstage entities are grouped into the following canonical types:

### Component
Represents a deployable unit such as a service, workload, or platform subsystem.

Examples:
- Traefik
- Argo CD
- Prometheus
- Grafana
- External Secrets
- Backstage
- Reference Workload

### System
Represents a logical grouping of related components.

Examples:
- Networking
- Security
- Observability
- Developer Platform
- Platform Core

### API
Represents a public or internal interface exposed by a component.

Examples:
- Backstage API
- Grafana API
- Argo CD API

### Resource
Represents infrastructure or platform resources consumed by components.

Examples:
- PostgreSQL database
- Kubernetes cluster
- External Secret store
- Object storage bucket

### Group
Represents a team or organizational boundary.

Examples:
- Platform Engineering
- Platform Operations
- Developers

### User
Represents a human identity or service identity.

Examples:
- platform-admin
- sre-team
- developer

### Location
Represents the source location of catalog metadata.

Examples:
- GitHub repository path
- GitOps manifests folder
- Template repository

### Template
Represents a scaffolder template that can create new catalog entities or repositories.

Examples:
- Service template
- Platform component template
- Workload template

---

## 2. Catalog Structure for TuskerBlueprint

The catalog should be backed by Git and discovered from repository locations that reflect the platform layout.

Recommended locations:

- platform-services/backstage/catalog
- gitops/applications/platform
- gitops/applications/workloads
- docs

This allows Backstage to ingest:

- platform capability metadata
- workload metadata
- documentation references
- ownership and lifecycle information

---

## 3. Automatic Registration of Platform Capabilities

The following platform capabilities should be automatically registered:

### Traefik
- Type: Component
- System: Networking
- Owner: Platform Engineering
- Lifecycle: production
- Description: Ingress and routing layer
- Source: GitOps application manifest and Helm values

### Argo CD
- Type: Component
- System: Platform Core
- Owner: Platform Engineering
- Lifecycle: production
- Description: GitOps reconciliation engine
- Source: GitOps application manifest and bootstrap resources

### Prometheus
- Type: Component
- System: Observability
- Owner: Platform Engineering
- Lifecycle: production
- Description: Metrics collection and alerting baseline
- Source: Prometheus Helm chart and values

### Grafana
- Type: Component
- System: Observability
- Owner: Platform Engineering
- Lifecycle: production
- Description: Dashboard and visualization layer
- Source: Grafana Helm chart and values

### Kyverno
- Type: Component
- System: Security
- Owner: Platform Engineering
- Lifecycle: production
- Description: Policy-as-code enforcement layer
- Source: Kyverno application manifest and values

### External Secrets
- Type: Component
- System: Security
- Owner: Platform Engineering
- Lifecycle: production
- Description: Kubernetes secret synchronization and secret management integration
- Source: External Secrets Helm chart and values

### Backstage
- Type: Component
- System: Developer Platform
- Owner: Platform Engineering
- Lifecycle: production
- Description: Internal Developer Portal
- Source: Backstage Helm deployment and GitOps application manifest

### Reference Workload
- Type: Component
- System: Workloads
- Owner: Platform Engineering
- Lifecycle: experimental
- Description: Example workload for validating platform capabilities
- Source: Workloads GitOps manifests

---

## 4. Entity Relationship Model

The catalog should model the following relationships:

- Systems contain Components
- Components may depend on Resources
- Components may expose APIs
- Components may belong to Groups
- Components may reference Locations
- Templates create new Components

Suggested relationships:

- Traefik -> depends on Kubernetes cluster and ingress resources
- Argo CD -> manages platform applications and workloads
- Prometheus -> depends on Kubernetes metrics API and Grafana dashboards
- Grafana -> depends on Prometheus and Kubernetes data sources
- Kyverno -> depends on Kubernetes admission control resources
- External Secrets -> depends on secret backend and Kubernetes secrets
- Backstage -> depends on PostgreSQL, GitHub, and Kubernetes API access
- Reference Workload -> depends on Traefik, External Secrets, and Observability components

---

## 5. Catalog Registration Strategy

### 5.1 GitHub discovery

The catalog should automatically discover repositories from GitHub using repository and org-based providers.

Recommended discovery scope:
- platform repositories
- workload repositories
- documentation repositories
- templates repositories

### 5.2 Location-based registration

Backstage should ingest the catalog from Git locations such as:

- /catalog/platform
- /catalog/workloads
- /catalog/templates

Each location should contain manifest files with metadata for entities.

### 5.3 Argo CD-driven registration

The catalog should reflect Argo CD-managed applications by using annotations or metadata that link entities to the GitOps application definitions.

Recommended annotations:
- argocd/app-name
- argocd/project
- argocd/instance
- github.com/repo-url

### 5.4 Component ownership

Every component should have:

- owner
- lifecycle
- system
- domain
- tags
- description

---

## 6. Catalog Entity Template Pattern

Each entity should follow a consistent structure.

Example structure:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: traefik
  title: Traefik
  description: Ingress and routing layer for the platform
  annotations:
    github.com/project-slug: stonetusker/tuskerblueprint
    argocd/app-name: traefik-development
    backstage.io/techdocs-ref: dir:.
spec:
  type: service
  lifecycle: production
  owner: platform-engineering
  system: networking
  dependsOn:
    - resource:kubernetes-cluster
  providesApis: []
```

---

## 7. Onboarding Future Applications

Future applications should follow a standard onboarding flow.

### Required onboarding steps

1. Create a Git repository for the application.
2. Add a catalog-info.yaml file describing the component.
3. Add ownership, lifecycle, and system metadata.
4. Add a GitHub repository location to the Backstage catalog configuration.
5. Add the application deployment manifests to the appropriate GitOps path.
6. Ensure the application is deployed through Argo CD.
7. Add documentation and TechDocs content.
8. Add templates or scaffolder inputs if the application should be reusable.

### Minimum required catalog metadata

Every onboarded application should include:

- name
- title
- description
- owner
- lifecycle
- system
- type
- annotations for source and deployment

### Recommended onboarding checklist

- Component entity exists
- System assignment exists
- Owner is assigned
- TechDocs are present
- GitHub repository is discovered
- Argo CD app is linked
- Kubernetes resources are connected where appropriate

---

## 8. Governance and Ownership Model

### Groups

Recommended groups:

- platform-engineering
- platform-operations
- developers
- security-engineering

### Ownership rules

- Platform capabilities are owned by Platform Engineering.
- Workloads are owned by the team that owns the repository.
- Shared infrastructure is owned by Platform Engineering.

### Lifecycle values

Recommended lifecycle values:

- experimental
- development
- production
- deprecated

---

## 9. Suggested Catalog Layout in Git

A simple Git layout for the catalog could be:

```text
platform-services/backstage/catalog/
  systems/
    networking.yaml
    security.yaml
    observability.yaml
    developer-platform.yaml
    workloads.yaml
  components/
    traefik.yaml
    argocd.yaml
    prometheus.yaml
    grafana.yaml
    kyverno.yaml
    external-secrets.yaml
    backstage.yaml
    reference-workload.yaml
  groups/
    platform-engineering.yaml
  locations/
    github.yaml
    templates.yaml
```

---

## 10. Validation and Operational Considerations

### Validation

Validate catalog onboarding by confirming:

- entities are discovered from GitHub
- entity metadata renders correctly in Backstage
- ownership and lifecycle values are visible
- system relationships are visible
- TechDocs and template links work

### Operational considerations

- Keep entity definitions versioned in Git
- Ensure automatic discovery is scoped to approved repositories only
- Avoid overloading the catalog with too many entities too early
- Maintain ownership metadata as a first-class requirement
- Monitor catalog refresh failures

---

## 11. Recommendation for TuskerBlueprint

The catalog should be configured to automatically register:

- platform capabilities as first-class components
- platform systems as groupings
- workloads as components
- GitHub repositories as locations
- templates for future onboarding

The initial catalog should be conservative and opinionated:

- every component should have an owner
- every component should be linked to Git and Argo CD where possible
- every platform capability should be represented as a component in the catalog
- templates should be provided for future application onboarding

This creates a strong foundation for a production-ready Internal Developer Portal without introducing unnecessary complexity at the start.

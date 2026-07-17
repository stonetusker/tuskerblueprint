# Backstage Production Architecture Review

## Scope

This review treats the current Backstage deployment as a minimal bootstrap installation and proposes a production-ready Internal Developer Portal architecture that preserves the existing TuskerBlueprint GitOps model.

The design is intentionally GitOps-first, externalized, secure-by-default, and compatible with future enterprise authentication migration.

---

## 1. Current Implementation Review

### 1.1 Deployment manifests

Current deployment entry points are Argo CD Applications under:

- gitops/applications/platform/developer-platform/backstage/application-development.yaml
- gitops/applications/platform/developer-platform/backstage/application-staging.yaml
- gitops/applications/platform/developer-platform/backstage/application-production.yaml

These applications:

- deploy the upstream Backstage Helm chart from the Backstage chart repository
- target the namespace backstage, backstage-staging, or backstage-production
- use the values files from platform-services/backstage/values
- use Argo CD sync policy with CreateNamespace=true

### 1.2 Helm values

Current values files are minimal and only define:

- platform-services/backstage/values/development.yaml
- platform-services/backstage/values/staging.yaml
- platform-services/backstage/values/production.yaml

They currently contain only basic replica count, service type, and resource requests/limits.

### 1.3 ConfigMaps

No dedicated Backstage ConfigMaps exist yet.

### 1.4 Secrets

No Backstage secrets are defined yet.

### 1.5 app-config configuration

No app-config file is currently provided in the repository.

### 1.6 Plugins

No Backstage plugins are configured yet.

### 1.7 Authentication

No explicit authentication mechanism is configured yet.

### 1.8 Catalog configuration

No software catalog providers, GitHub ingestion rules, or catalog locations are configured yet.

---

## 2. Gap Analysis: Bootstrap vs Production-Ready

| Area | Current Bootstrap State | Production-Ready Requirement | Gap |
| --- | --- | --- | --- |
| Deployment model | Argo CD + Helm chart only | GitOps-managed, environment-specific, repeatable | Medium |
| Configuration | Values only, no externalized app-config | ConfigMaps + External Secrets + env vars | High |
| Authentication | Not defined | Guest-first bootstrap, future GitHub/Azure/Keycloak migration | High |
| Catalog | Not defined | GitHub discovery, catalog import, entity ingestion | High |
| Plugins | None | Kubernetes, Argo CD, Grafana, TechDocs, Search, Scaffolder | High |
| Data store | None | PostgreSQL backend | High |
| Secrets | None | External Secrets integration | High |
| TechDocs | None | Git-backed docs publishing | High |
| RBAC | None | Role-based access with policy-as-code | High |
| Observability | None | Metrics, logs, health checks | Medium |
| CI/CD | Placeholder workflow | Validate charts, manifests, values, docs | Medium |

---

## 3. Proposed Production Architecture

### 3.1 Architectural goals

The production architecture will:

- preserve the current GitOps pattern through Argo CD
- keep Git as the source of truth
- externalize all configuration
- support a secure, scalable Internal Developer Portal
- allow future enterprise SSO migration without application code changes

### 3.2 Deployment topology

Backstage will be deployed as a standard Kubernetes workload managed by Argo CD.

The deployment will consist of:

- Backstage application pod
- PostgreSQL backend for catalog and scaffolder state
- Ingress routing through Traefik
- ConfigMaps for non-sensitive configuration
- External Secrets for sensitive values
- Optional object storage for TechDocs publishing
- Argo CD and Kubernetes integrations for runtime discovery

### 3.3 GitOps structure

All production configuration will remain under Git and be reconciled by Argo CD.

Recommended structure:

- platform-services/backstage/values/development.yaml
- platform-services/backstage/values/staging.yaml
- platform-services/backstage/values/production.yaml
- platform-services/backstage/app-config/app-config.development.yaml
- platform-services/backstage/app-config/app-config.staging.yaml
- platform-services/backstage/app-config/app-config.production.yaml
- platform-services/backstage/manifests/configmap-app-config.yaml
- platform-services/backstage/manifests/configmap-rbac.yaml
- platform-services/backstage/manifests/configmap-techdocs.yaml
- platform-services/backstage/manifests/externalsecret-backstage.yaml
- platform-services/backstage/manifests/externalsecret-postgres.yaml

These files will be referenced by the existing Argo CD Applications through the repo source.

---

## 4. Required Capabilities

### 4.1 GitHub integration

Backstage must integrate with GitHub for:

- repository discovery
- catalog ingestion
- scaffolder actions
- GitHub Actions integration metadata

Implementation approach:

- configure GitHub provider in app-config
- inject GitHub token from an External Secret
- enable org-based discovery for selected repositories

### 4.2 Software Catalog

The catalog should be backed by GitHub and automatically discover repositories.

Recommended configuration:

- GitHub org discovery provider
- location rules for platform repositories
- entity annotations for ownership, lifecycle, and domain

### 4.3 Catalog Import

Backstage should support import flows for existing repositories.

Recommended configuration:

- enable catalog import plugin
- expose import endpoints through the UI
- require authenticated users for import actions

### 4.4 Kubernetes plugin

The Kubernetes plugin should support multiple clusters.

Recommended approach:

- define a cluster catalog in app-config
- supply kubeconfig or service account credentials via secret-backed configuration
- support per-cluster auth and RBAC-aware visibility

### 4.5 Argo CD plugin

The Argo CD plugin should discover applications automatically.

Recommended approach:

- configure the Argo CD API endpoint
- inject credentials from an External Secret
- allow Backstage to surface application health and sync state

### 4.6 Grafana plugin

The Grafana plugin should integrate with the existing Grafana deployment.

Recommended approach:

- configure Grafana base URL from ConfigMap
- use a read-only service account or service token where possible
- expose dashboard links from catalog entities

### 4.7 TechDocs

TechDocs should publish TPRA documentation from Git repositories.

Recommended approach:

- enable TechDocs builder and publisher
- use GitHub repository sources as the doc source
- publish generated docs to an external object storage backend such as S3-compatible storage or a managed blob store
- keep publisher configuration externalized via ConfigMap and Secret

### 4.8 Scaffolder

The scaffolder should support repository creation and template execution.

Recommended approach:

- enable scaffolder and template actions
- provide GitHub token-backed actions
- use templates that follow TuskerBlueprint conventions

### 4.9 Search

Search should be enabled and backed by the catalog and TechDocs content.

Recommended approach:

- enable the default search engine and indexed content providers
- ensure docs and catalog items are searchable

### 4.10 Authentication

Authentication should support future migration to enterprise SSO.

Recommended approach:

- define authentication in a provider-agnostic way through app-config and environment variables
- use guest auth initially as a bootstrap default
- allow provider selection via ConfigMap/env vars, for example:
  - guest
  - github-oauth
  - azure-auth
  - keycloak
- keep the application code free of provider-specific assumptions

### 4.11 RBAC

RBAC should be policy-driven and externalized.

Recommended approach:

- define permission policies in a ConfigMap
- map GitHub or enterprise groups to Backstage roles
- enforce read/write boundaries by default

### 4.12 PostgreSQL backend

Backstage should use PostgreSQL for catalog and scaffolder persistence.

Recommended approach:

- deploy PostgreSQL through a managed service or a GitOps-compatible operator
- provide host, database, username, and password via External Secret
- configure the Backstage backend connection string via environment variables

### 4.13 External Secrets integration

Sensitive values should be sourced from External Secrets instead of being stored directly in manifests.

Recommended approach:

- create ExternalSecret resources per environment
- source secrets from Doppler or another configured secret backend
- mount secrets into Backstage as environment variables or files

### 4.14 GitHub Actions integration

Backstage should integrate with GitHub Actions metadata and workflows.

Recommended approach:

- expose repository workflow metadata in catalog entities
- validate Backstage config and docs in CI
- enforce schema and lint checks on app-config and templates

---

## 5. Configuration Strategy

### 5.1 ConfigMaps for non-sensitive values

Use ConfigMaps for:

- Backstage app-config fragments
- auth provider selection
- catalog provider settings
- Kubernetes cluster definitions
- Argo CD connection settings
- Grafana URL settings
- TechDocs publisher settings
- RBAC policy definitions

### 5.2 External Secrets for sensitive values

Use External Secrets for:

- GitHub token
- Argo CD token
- Grafana token or service account secret
- PostgreSQL credentials
- any cloud/object-store credentials

### 5.3 Environment variables for runtime wiring

Use environment variables to inject:

- secrets into the app container
- provider selection values
- feature flags
- service endpoint URLs

This keeps all sensitive and dynamic values externalized.

---

## 6. Recommended File Set for the Next Implementation Phase

The following files should be introduced in a subsequent implementation phase:

- platform-services/backstage/values/development.yaml
- platform-services/backstage/values/staging.yaml
- platform-services/backstage/values/production.yaml
- platform-services/backstage/app-config/app-config.development.yaml
- platform-services/backstage/app-config/app-config.staging.yaml
- platform-services/backstage/app-config/app-config.production.yaml
- platform-services/backstage/manifests/configmap-app-config.yaml
- platform-services/backstage/manifests/configmap-rbac.yaml
- platform-services/backstage/manifests/configmap-techdocs.yaml
- platform-services/backstage/manifests/externalsecret-backstage.yaml
- platform-services/backstage/manifests/externalsecret-postgres.yaml
- .github/workflows/backstage.yml updates

These files should be wired into the existing Argo CD application manifests through GitOps, not through ad-hoc cluster changes.

---

## 7. Validation Steps

Validation should be performed after implementation, not during this review phase.

Recommended validation steps:

1. Confirm Argo CD syncs the Backstage application successfully.
2. Confirm the Backstage pod starts and becomes healthy.
3. Confirm the PostgreSQL backend is reachable.
4. Confirm app-config is loaded from ConfigMap and env vars.
5. Confirm GitHub catalog discovery works.
6. Confirm TechDocs build and publish successfully.
7. Confirm the Kubernetes plugin can read configured clusters.
8. Confirm Argo CD plugin surfaces applications correctly.
9. Confirm Grafana plugin resolves the existing Grafana deployment.
10. Confirm RBAC and authentication behavior is correct.

---

## 8. Rollback Plan

Rollback should be GitOps-native.

Recommended rollback strategy:

1. Revert the target values, ConfigMap, or ExternalSecret changes in Git.
2. Allow Argo CD to reconcile the rollback.
3. Restore the previous Backstage Helm values or app-config version.
4. Validate pod health and catalog availability after rollback.
5. If the PostgreSQL backend is impacted, restore the previous database connection settings and verify application reconnectivity.

Because the deployment is GitOps-driven, rollback remains a safe Git revert plus Argo CD reconciliation flow.

---

## 9. Recommended Implementation Sequence

1. Introduce externalized app-config and ConfigMaps.
2. Add PostgreSQL configuration and External Secrets.
3. Enable GitHub integration and catalog discovery.
4. Add Kubernetes, Argo CD, and Grafana plugins.
5. Enable TechDocs publishing.
6. Add scaffolder and search.
7. Add RBAC and authentication abstraction.
8. Extend CI/CD validation and rollout automation.

---

## 10. Summary

The current Backstage setup is a valid bootstrap scaffold, but it is not yet production-ready.

The next step is to evolve it into a GitOps-managed Internal Developer Portal with:

- externalized configuration
- PostgreSQL persistence
- GitHub-backed software catalog discovery
- Kubernetes and Argo CD integration
- Grafana integration
- TechDocs publishing
- authentication abstraction for future SSO migration
- RBAC and secure secret handling

This approach fits the existing TuskerBlueprint platform principles and preserves the current GitOps architecture.

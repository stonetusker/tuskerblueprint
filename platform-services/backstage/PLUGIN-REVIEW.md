# Backstage Plugin Review

## Purpose

This review classifies Backstage plugins for the TuskerBlueprint platform into Core, Platform, Optional, and Future categories. The recommendations are designed for a GitOps-managed Internal Developer Portal that fits the repository’s existing platform services.

---

## 1. Classification

### Core Plugins

These plugins are foundational for a usable developer portal and should be enabled by default in TuskerBlueprint.

- Catalog
- Catalog Import
- Search
- Scaffolder
- TechDocs
- Authentication provider integration

### Platform Plugins

These plugins directly support the TuskerBlueprint platform capabilities already scaffolded in the repository.

- Kubernetes plugin
- Argo CD plugin
- Grafana plugin
- GitHub integration

### Optional Plugins

These plugins provide value but are not required for the initial production rollout.

- GitHub Actions integration
- Permissions / RBAC policy integration
- CI/CD workflow metadata enrichment

### Future Plugins

These plugins are useful for a mature enterprise portal but are not required for the first production-ready deployment.

- Azure DevOps integration
- Jira integration
- PagerDuty integration
- ServiceNow integration
- Security scanning plugins
- Cost management plugins
- Datadog / New Relic integrations

---

## 2. Plugin-by-Plugin Review

### 2.1 Catalog

Category: Core

Purpose
- Provides the Software Catalog for services, resources, APIs, and systems.
- Serves as the primary inventory for the Internal Developer Portal.

Dependencies
- PostgreSQL backend
- Configured catalog locations
- GitHub or filesystem ingestion providers

Required configuration
- Catalog locations
- Entity annotations and ownership metadata
- Refresh interval and ingestion rules

Secrets
- None required for basic use
- Optional GitHub token if repository discovery is enabled

RBAC
- Read access should be role-based
- Write access should be restricted to platform admins and service owners

GitHub permissions
- Read access to repository metadata for discovery
- Optional read access to repository contents for catalog enrichment

Network requirements
- Outbound access to GitHub or configured SCM provider
- Internal access to the Backstage backend

Validation
- Confirm catalog entities appear after ingestion
- Verify ownership and lifecycle metadata render correctly

Operational considerations
- Catalog refreshes should be scheduled and observable
- Entity ingestion failures should be surfaced clearly

---

### 2.2 Catalog Import

Category: Core

Purpose
- Allows users to import existing repositories into the catalog.
- Supports onboarding of services that already exist in GitHub.

Dependencies
- Catalog plugin
- GitHub integration
- Authentication

Required configuration
- Import providers enabled
- Allowed repository patterns
- Import workflow configuration

Secrets
- GitHub token for repository inspection

RBAC
- Importing should require authenticated users and explicit permissions

GitHub permissions
- Read access to repository metadata
- Read access to repository contents for import validation

Network requirements
- Outbound HTTPS to GitHub
- Access to Backstage backend API

Validation
- Import flow completes for a known repository
- Imported entities appear in the catalog

Operational considerations
- Restrict import to approved repository owners or orgs
- Log and audit import actions

---

### 2.3 Search

Category: Core

Purpose
- Enables discovery across catalog entities, TechDocs, and platform content.
- Improves discoverability across the portal.

Dependencies
- Catalog and TechDocs
- Search backend configuration

Required configuration
- Search engine enabled
- Indexing rules for catalog and docs
- Search provider configuration

Secrets
- None for the initial setup

RBAC
- Search should respect entity visibility

GitHub permissions
- None directly required
- Indirectly depends on repository access for indexing

Network requirements
- Internal Backstage service connectivity
- Outbound access for remote content sources if used

Validation
- Search returns entities and documentation content

Operational considerations
- Index freshness should be monitored
- Large catalogs need tuning for performance

---

### 2.4 Scaffolder

Category: Core

Purpose
- Enables template-driven project and service creation.
- Supports platform-approved scaffolding for new services.

Dependencies
- Catalog
- GitHub integration
- Authentication
- Template repository

Required configuration
- Scaffolder templates
- GitHub token for repository creation
- Allowed template namespaces

Secrets
- GitHub token
- Optional source-control credentials

RBAC
- Only authorized users should create repositories or templates

GitHub permissions
- Repo create / push permissions as required by policy
- Must be scoped carefully

Network requirements
- Outbound HTTPS to GitHub
- Access to GitHub API

Validation
- A template can create a repository successfully
- The created repository is registered in the catalog

Operational considerations
- Restrict to approved templates and policies
- Audit template execution outcomes

---

### 2.5 TechDocs

Category: Core

Purpose
- Publishes and serves documentation from Git repositories.
- Supports TPRA docs and platform documentation lifecycle.

Dependencies
- GitHub or Git provider integration
- Publisher backend
- Optional object storage for published docs

Required configuration
- TechDocs enabled
- Documentation source locations
- Publisher configuration
- Storage backend for built docs

Secrets
- Optional object store credentials
- GitHub token if repository access is required

RBAC
- Read access should follow catalog visibility
- Authoring access should be restricted

GitHub permissions
- Read access to documentation repositories
- Optional write access if publishing from CI is used

Network requirements
- Outbound access to GitHub
- Access to storage backend if publishing externally

Validation
- A markdown docs repository renders successfully
- TechDocs pages are searchable and accessible

Operational considerations
- Keep docs source repositories versioned and reviewed
- Publish pipeline should be deterministic

---

### 2.6 Authentication Provider Integration

Category: Core

Purpose
- Enables users to sign in and access the portal.
- Provides the foundation for future SSO migration.

Dependencies
- Backstage auth framework
- Secret storage for provider credentials
- Ingress and proper session handling

Required configuration
- Provider selection
- Redirect URIs
- Session secret
- Allowed organizations or groups

Secrets
- Client ID, client secret, session secret

RBAC
- Authentication should be paired with group-based access control

GitHub permissions
- None for Guest auth
- GitHub OAuth requires organization or user access scopes

Network requirements
- Inbound HTTPS access to Backstage
- Outbound access to identity provider endpoints

Validation
- Users can sign in with the configured provider
- User identity resolves to expected groups

Operational considerations
- Keep provider abstraction clean so Guest can later be replaced by GitHub OAuth, Azure Entra ID, or Keycloak without code changes

---

### 2.7 Kubernetes Plugin

Category: Platform

Purpose
- Exposes Kubernetes resources and cluster health inside Backstage.
- Helps developers understand workloads, deployments, and runtime status.

Dependencies
- Kubernetes clusters
- Cluster credentials or kubeconfig access
- RBAC-aware service account

Required configuration
- Cluster definitions
- Namespace and resource visibility rules
- Authentication method for each cluster

Secrets
- Cluster credentials or tokens

RBAC
- Must respect Kubernetes RBAC and cluster permissions
- Users should only see clusters and resources they are allowed to view

GitHub permissions
- None directly required

Network requirements
- Network access from Backstage to each Kubernetes API server
- Cluster-specific ingress/firewall rules

Validation
- Cluster details appear and resources are readable
- Multiple clusters are discoverable and correctly separated

Operational considerations
- Multiple-cluster support should be carefully isolated and documented
- Avoid over-broad cluster access in shared environments

---

### 2.8 Argo CD Plugin

Category: Platform

Purpose
- Surfaces Argo CD applications and their sync/health status in Backstage.
- Aligns with the existing GitOps deployment model.

Dependencies
- Argo CD installation
- Argo CD API access
- Optional token or service account for authenticated API calls

Required configuration
- Argo CD base URL
- API credentials
- Application visibility rules

Secrets
- Argo CD token or service account secret

RBAC
- Read-only by default for most users
- More privileged views only for platform admins

GitHub permissions
- None directly required

Network requirements
- Outbound HTTPS from Backstage to Argo CD API
- Access to the Argo CD server

Validation
- Applications and their health/sync states are displayed
- Auto-discovery works for known applications

Operational considerations
- The plugin should be read-only unless a dedicated approval workflow is introduced

---

### 2.9 Grafana Plugin

Category: Platform

Purpose
- Integrates Grafana dashboards and metrics context into Backstage.
- Improves operational observability from the developer portal.

Dependencies
- Grafana deployment
- Grafana endpoint and access token
- Catalog entity annotations for dashboard linking

Required configuration
- Grafana base URL
- Dashboard linkage configuration
- Token or service account access

Secrets
- Grafana token or service account secret

RBAC
- Users should only access dashboards allowed by Grafana permissions

GitHub permissions
- None directly required

Network requirements
- Outbound HTTPS from Backstage to Grafana

Validation
- Dashboard links resolve and render
- Grafana data is reachable from the portal

Operational considerations
- Keep the integration read-only where possible
- Align dashboards with the platform observability standards

---

### 2.10 GitHub Integration

Category: Platform

Purpose
- Connects Backstage to GitHub for repository discovery and catalog enrichment.
- Enables GitHub-backed templates and repository-based service onboarding.

Dependencies
- GitHub token
- GitHub organization or repository access model
- Catalog provider configuration

Required configuration
- GitHub app or token
- Organization and repository allow-list
- Catalog locations for GitHub

Secrets
- GitHub token

RBAC
- Must enforce repository access restrictions based on GitHub permissions

GitHub permissions
- Read access to repositories and metadata
- Optional write access for scaffolding flows

Network requirements
- Outbound HTTPS to GitHub APIs

Validation
- GitHub repositories are discovered and displayed in the catalog
- Templates can be invoked successfully

Operational considerations
- Use fine-grained tokens and least privilege
- Prefer GitHub App credentials over long-lived personal tokens

---

### 2.11 GitHub Actions Integration

Category: Optional

Purpose
- Surfaces workflow metadata and build status in Backstage.
- Improves developer visibility into CI health.

Dependencies
- GitHub integration
- Workflow metadata availability

Required configuration
- Repository workflow metadata integration
- Optional status mappings

Secrets
- GitHub token if workflow data is queried

RBAC
- Read-only access by default

GitHub permissions
- Read access to workflow metadata

Network requirements
- Outbound HTTPS to GitHub

Validation
- Workflow runs and status are exposed correctly

Operational considerations
- This should be enabled after core catalog and developer experience workflows are stable

---

### 2.12 Permissions / RBAC Policy Integration

Category: Optional

Purpose
- Makes access control more explicit and aligned with platform roles.
- Helps separate platform admins, developers, and operators.

Dependencies
- Authentication provider
- Catalog and entity visibility policies

Required configuration
- Role mappings
- Policy definitions
- Group-to-role assignment

Secrets
- No direct secrets required

RBAC
- This is itself the RBAC layer

GitHub permissions
- None directly required

Network requirements
- Internal only

Validation
- Different users see the correct entities and actions

Operational considerations
- Keep policy definitions externalized and reviewed

---

## 3. Recommendations for TuskerBlueprint Defaults

### Enable by default

The following plugins should be enabled by default in TuskerBlueprint:

- Catalog
- Catalog Import
- Search
- Scaffolder
- TechDocs
- Authentication provider integration
- Kubernetes plugin
- Argo CD plugin
- Grafana plugin
- GitHub integration

### Enable later or conditionally

The following should be enabled after initial rollout and platform hardening:

- GitHub Actions integration
- Advanced RBAC/policy integration
- Additional enterprise integrations such as Jira, PagerDuty, or ServiceNow

### Keep disabled by default

The following should remain disabled until the platform has the required operational maturity:

- Third-party incident or cost plugins
- Heavy enterprise SaaS integrations
- Anything requiring broad external permissions or nonessential network exposure

---

## 4. Recommended Default Plugin Set for TuskerBlueprint

For the first production-ready Backstage rollout, TuskerBlueprint should default to:

- Core portal experience: Catalog, Catalog Import, Search, Scaffolder, TechDocs
- Platform-native integrations: Kubernetes, Argo CD, Grafana, GitHub
- Authentication: Guest initially, with provider abstraction ready for GitHub OAuth, Azure Entra ID, or Keycloak
- RBAC: role-based and policy-driven

This set provides the best balance of operational value, platform alignment, and security for the current repository state.

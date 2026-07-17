# Backstage Configuration Framework

## Purpose

This framework defines a reusable, GitOps-friendly configuration model for Backstage that supports Development, Testing, Staging, and Production while keeping all sensitive values externalized.

The design follows the TuskerBlueprint principles:

- Git is the source of truth
- Everything as Code
- GitOps only
- Secure by default
- Production ready
- Observable
- Testable
- Rollback capable

---

## Configuration Model

Backstage configuration is separated into six layers:

1. Application configuration
   - runtime behavior, UI labels, catalog defaults, plugin defaults
2. Environment configuration
   - namespace, ingress host, environment name, feature flags
3. Secrets
   - GitHub tokens, PostgreSQL credentials, plugin tokens, SSO secrets
4. Plugins
   - Kubernetes, Argo CD, Grafana, TechDocs, Search, Scaffolder
5. Authentication
   - provider selection and authorization policy
6. Providers
   - GitHub, catalog ingestion, Kubernetes clusters, Argo CD endpoints, Grafana endpoints

### Recommended source of truth

- Helm values: non-sensitive runtime defaults and environment-specific structure
- ConfigMaps: non-sensitive configuration rendered into Backstage app-config and plugin settings
- External Secrets: all sensitive values exposed as environment variables or mounted files
- Environment variables: runtime wiring and provider-specific overrides

---

## File Layout

- platform-services/backstage/values/development.yaml
- platform-services/backstage/values/testing.yaml
- platform-services/backstage/values/staging.yaml
- platform-services/backstage/values/production.yaml
- platform-services/backstage/manifests/configmap-app-config.yaml
- platform-services/backstage/manifests/configmap-rbac.yaml
- platform-services/backstage/manifests/configmap-techdocs.yaml
- platform-services/backstage/manifests/externalsecret-backstage.yaml
- platform-services/backstage/manifests/externalsecret-postgres.yaml

---

## Environment Matrix

| Environment | Purpose | Auth Default | Secret Backend | Notes |
| --- | --- | --- | --- | --- |
| Development | Local bootstrap and developer validation | Guest | External Secret reference | Minimal feature set |
| Testing | Automated validation and regression checks | Guest | External Secret reference | Mirrors staging behavior |
| Staging | Pre-production validation | Guest or SSO preview | External Secret reference | Production-like config |
| Production | Full platform portal | SSO-ready provider | External Secret reference | Full RBAC and plugin set |

---

## Configuration Categories and Options

### 1. Global and environment configuration

| Configuration Name | Purpose | Source | Default | Required | Secret | Environment |
| --- | --- | --- | --- | --- | --- | --- |
| global.environment | Identifies the current environment | Helm values | development | Yes | No | all |
| global.namespace | Kubernetes namespace for the deployment | Helm values | backstage | Yes | No | all |
| global.appName | Application name | Helm values | backstage | Yes | No | all |
| global.domain | Public host or ingress domain | Helm values | empty string | No | No | all |
| global.ingress.host | Primary Backstage ingress host | Helm values | empty string | No | No | all |
| global.ingress.className | Ingress class | Helm values | empty string | No | No | all |
| global.ingress.tls.enabled | Enable TLS on ingress | Helm values | false | No | No | all |
| global.image.repository | Backstage image repository | Helm values | empty string | No | No | all |
| global.image.tag | Backstage image tag | Helm values | empty string | No | No | all |
| global.image.pullPolicy | Image pull policy | Helm values | IfNotPresent | No | No | all |

### 2. Application configuration

| Configuration Name | Purpose | Source | Default | Required | Secret | Environment |
| --- | --- | --- | --- | --- | --- | --- |
| backstage.appConfig.app.baseUrl | Base URL for the Backstage frontend | Helm values / ConfigMap | empty string | Yes | No | all |
| backstage.appConfig.app.title | Portal display title | Helm values / ConfigMap | TuskerBlueprint Internal Developer Portal | No | No | all |
| backstage.appConfig.app.support.url | Support URL | Helm values / ConfigMap | empty string | No | No | all |
| backstage.appConfig.organization.name | Organization label | Helm values / ConfigMap | TuskerBlueprint | No | No | all |
| backstage.appConfig.backend.baseUrl | Backend base URL | Helm values / ConfigMap | empty string | Yes | No | all |
| backstage.appConfig.backend.database.client | Database client | Helm values / ConfigMap | pg | Yes | No | all |
| backstage.appConfig.backend.database.connection.host | PostgreSQL host | Helm values / Secret | empty string | Yes | Yes | all |
| backstage.appConfig.backend.database.connection.port | PostgreSQL port | Helm values | 5432 | Yes | No | all |
| backstage.appConfig.backend.database.connection.user | PostgreSQL username | Helm values / Secret | empty string | Yes | Yes | all |
| backstage.appConfig.backend.database.connection.password | PostgreSQL password | External Secret | empty string | Yes | Yes | all |
| backstage.appConfig.backend.database.connection.database | PostgreSQL database | Helm values / Secret | backstage | Yes | No | all |

### 3. Authentication configuration

| Configuration Name | Purpose | Source | Default | Required | Secret | Environment |
| --- | --- | --- | --- | --- | --- | --- |
| backstage.auth.provider | Active auth provider | Helm values / ConfigMap | guest | Yes | No | all |
| backstage.auth.providers.guest.enabled | Enable guest authentication | Helm values / ConfigMap | true | No | No | all |
| backstage.auth.providers.github.enabled | Enable GitHub OAuth | Helm values / ConfigMap | false | No | No | all |
| backstage.auth.providers.azure.enabled | Enable Azure Entra authentication | Helm values / ConfigMap | false | No | No | all |
| backstage.auth.providers.keycloak.enabled | Enable Keycloak authentication | Helm values / ConfigMap | false | No | No | all |
| backstage.auth.session.secret | Session signing secret | External Secret | empty string | Yes in prod | Yes | all |
| backstage.auth.providers.github.clientId | GitHub OAuth client ID | External Secret | empty string | No | Yes | all |
| backstage.auth.providers.github.clientSecret | GitHub OAuth client secret | External Secret | empty string | No | Yes | all |
| backstage.auth.providers.azure.clientId | Azure client ID | External Secret | empty string | No | Yes | all |
| backstage.auth.providers.azure.clientSecret | Azure client secret | External Secret | empty string | No | Yes | all |
| backstage.auth.providers.keycloak.clientId | Keycloak client ID | External Secret | empty string | No | Yes | all |
| backstage.auth.providers.keycloak.clientSecret | Keycloak client secret | External Secret | empty string | No | Yes | all |

### 4. Plugin configuration

| Configuration Name | Purpose | Source | Default | Required | Secret | Environment |
| --- | --- | --- | --- | --- | --- | --- |
| backstage.plugins.catalog.enabled | Enable software catalog | Helm values / ConfigMap | true | Yes | No | all |
| backstage.plugins.catalog.import.enabled | Enable catalog import | Helm values / ConfigMap | true | No | No | all |
| backstage.plugins.kubernetes.enabled | Enable Kubernetes plugin | Helm values / ConfigMap | false | No | No | all |
| backstage.plugins.kubernetes.clusters | Kubernetes cluster definitions | Helm values / ConfigMap | empty list | No | No | all |
| backstage.plugins.argocd.enabled | Enable Argo CD plugin | Helm values / ConfigMap | false | No | No | all |
| backstage.plugins.argocd.url | Argo CD API base URL | Helm values / ConfigMap | empty string | No | No | all |
| backstage.plugins.grafana.enabled | Enable Grafana plugin | Helm values / ConfigMap | false | No | No | all |
| backstage.plugins.grafana.url | Grafana base URL | Helm values / ConfigMap | empty string | No | No | all |
| backstage.plugins.techdocs.enabled | Enable TechDocs | Helm values / ConfigMap | false | No | No | all |
| backstage.plugins.techdocs.publisher.type | TechDocs publisher type | Helm values / ConfigMap | local | No | No | all |
| backstage.plugins.search.enabled | Enable search | Helm values / ConfigMap | true | No | No | all |
| backstage.plugins.scaffolder.enabled | Enable scaffolder | Helm values / ConfigMap | true | No | No | all |

### 5. Provider configuration

| Configuration Name | Purpose | Source | Default | Required | Secret | Environment |
| --- | --- | --- | --- | --- | --- | --- |
| backstage.providers.github.tokenEnvVar | GitHub token env var name | Helm values / ConfigMap | GITHUB_TOKEN | No | Yes | all |
| backstage.providers.github.orgs | GitHub organization names to discover | Helm values / ConfigMap | empty list | No | No | all |
| backstage.providers.github.repositories | GitHub repositories to ingest | Helm values / ConfigMap | empty list | No | No | all |
| backstage.providers.catalog.locations | Catalog locations for GitHub or local files | Helm values / ConfigMap | empty list | Yes | No | all |
| backstage.providers.kubernetes.clusterName | Cluster identifier | Helm values / ConfigMap | empty string | No | No | all |
| backstage.providers.argocd.tokenEnvVar | Argo CD token environment variable | Helm values / Secret | ARGOCD_TOKEN | No | Yes | all |
| backstage.providers.grafana.tokenEnvVar | Grafana token environment variable | Helm values / Secret | GRAFANA_TOKEN | No | Yes | all |

### 6. RBAC and policy configuration

| Configuration Name | Purpose | Source | Default | Required | Secret | Environment |
| --- | --- | --- | --- | --- | --- | --- |
| backstage.rbac.policies | RBAC policy definitions | ConfigMap | empty list | No | No | all |
| backstage.rbac.roles | Role mappings | ConfigMap | empty list | No | No | all |

### 7. Secrets and secret wiring

| Configuration Name | Purpose | Source | Default | Required | Secret | Environment |
| --- | --- | --- | --- | --- | --- | --- |
| backstage.secrets.existingSecret | Existing Kubernetes secret name | Helm values | backstage-secrets | Yes | Yes | all |
| backstage.secrets.backend | Secret backend type | Helm values | doppler | No | No | all |
| backstage.secrets.storeRef.name | External secret store name | Helm values | empty string | Yes | No | all |
| backstage.secrets.storeRef.kind | Store kind | Helm values | ClusterSecretStore | No | No | all |

---

## Configuration Injection Pattern

The recommended pattern is:

1. Put non-sensitive defaults in Helm values.
2. Render non-sensitive app-config fragments into a ConfigMap.
3. Inject secrets through environment variables or mounted files from an External Secret.
4. Let Backstage read the rendered app-config from the mounted ConfigMap.

Example mapping:

- app-config.yaml -> ConfigMap
- GitHub token -> External Secret -> environment variable
- PostgreSQL credentials -> External Secret -> environment variable
- authentication provider selection -> ConfigMap + env var

---

## Environment-Specific Guidance

### Development

- guest authentication enabled
- minimal catalog and plugin set
- no production SSO dependency
- TechDocs optional

### Testing

- same provider structure as development
- more complete catalog discovery checks
- staging-like plugin wiring without production-sensitive settings

### Staging

- production-like plugin set
- SSO provider selection can be previewed without full production rollout
- RBAC policies validated

### Production

- full plugin set enabled
- enterprise authentication provider selected
- RBAC enforced
- GitHub and PostgreSQL secrets sourced from External Secrets

---

## Notes

- No URLs, credentials, namespaces, cluster names, or tokens should be hardcoded in manifests.
- All secrets must be sourced from External Secrets.
- All non-sensitive values should be managed through Helm values and ConfigMaps.
- The authentication layer should support a provider abstraction so Guest can later be replaced by GitHub OAuth, Azure Entra ID, or Keycloak without changing application code.

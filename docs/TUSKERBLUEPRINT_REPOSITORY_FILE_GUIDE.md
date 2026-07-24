# TuskerBlueprint repository file guide

This learning guide explains all **340 files** in the IDP reference repository. Paths are relative to the repository root.

## Recommended learning order

1. `README.md` and `docs/architecture.md`
2. `catalog-info.yaml` and `catalog/`
3. `platform-services/backstage/` and `backstage-app/`
4. `software-templates/`
5. `gitops/` and `workloads/demo-service/`
6. `scripts/` and `.github/workflows/`
7. `infrastructure/`

## Repository root

### `.gitignore`

Excludes local environments, generated artifacts, secrets, key material, state files, and build output from Git.

### `CHANGELOG-IDP.md`

Summarizes the IDP additions, GitOps corrections, security improvements, and migration features in version 1.1.0.

### `CODE_OF_CONDUCT.md`

Defines professional conduct expectations for contributors.

### `CONTRIBUTING.md`

Defines contribution, validation, documentation, rollout, and rollback expectations.

### `LICENSE`

Provides the MIT license for reuse of the reference implementation.

### `Makefile`

Provides convenient validation, Backstage bootstrap, and customer-demo command targets.

### `README.md`

Introduces the TuskerBlueprint IDP, its capabilities, migration model, important paths, validation, and security expectations.

### `SECURITY.md`

Explains private vulnerability reporting, supported scope, secret handling, and credential rotation.

### `SUPPORT.md`

Explains where to report normal issues and where to send sensitive support requests.

### `catalog-info.yaml`

Acts as the root Backstage Location and registers every structured catalog entity and golden-path template.

### `mkdocs.yml`

Defines the platform-level TechDocs site navigation and repository integration.

## `.github`

### `.github/CODEOWNERS`

Assigns review ownership for the platform, catalog, GitOps, Backstage, and template areas.

### `.github/PULL_REQUEST_TEMPLATE.md`

Collects change summary, risk, validation, rollout, and rollback information in pull requests.

### `.github/workflows/backstage-image.yml`

Defines the `backstage-image` GitHub Actions workflow for automated repository or image validation.

### `.github/workflows/idp-validation.yml`

Defines the `idp-validation` GitHub Actions workflow for automated repository or image validation.

## `catalog`

### `catalog/apis/demo-service-api.yaml`

Defines the `demo-service-api` API and its declarative configuration.

### `catalog/components/argocd.yaml`

Defines the `argocd` Component and its declarative configuration.

### `catalog/components/backstage.yaml`

Defines the `backstage` Component and its declarative configuration.

### `catalog/components/cert-manager.yaml`

Defines the `cert-manager` Component and its declarative configuration.

### `catalog/components/demo-service.yaml`

Defines the `demo-service` Component and its declarative configuration.

### `catalog/components/external-secrets.yaml`

Defines the `external-secrets` Component and its declarative configuration.

### `catalog/components/grafana.yaml`

Defines the `grafana` Component and its declarative configuration.

### `catalog/components/kyverno.yaml`

Defines the `kyverno` Component and its declarative configuration.

### `catalog/components/loki.yaml`

Defines the `loki` Component and its declarative configuration.

### `catalog/components/prometheus.yaml`

Defines the `prometheus` Component and its declarative configuration.

### `catalog/components/traefik.yaml`

Defines the `traefik` Component and its declarative configuration.

### `catalog/domains/platform-engineering.yaml`

Defines the `platform-engineering` Domain and its declarative configuration.

### `catalog/groups/platform-team.yaml`

Defines the `platform-team` Group and its declarative configuration.

### `catalog/resources/development-cluster.yaml`

Defines the `tuskerblueprint-development-cluster` Resource and its declarative configuration.

### `catalog/resources/tuskerblueprint-repository.yaml`

Defines the `tuskerblueprint-repository` Resource and its declarative configuration.

### `catalog/systems/tuskerblueprint.yaml`

Defines the `tuskerblueprint` System and its declarative configuration.

### `catalog/users/subeesh.yaml`

Defines the `subeesh` User and its declarative configuration.

## `apis`

### `apis/demo-service/openapi.yaml`

Defines the OpenAPI contract rendered in the Backstage API explorer.

## `backstage-app`

### `backstage-app/README.md`

Explains how the custom Backstage app overlay is generated, validated, built, and later converted to a committed lockfile-based application.

### `backstage-app/backstage-release.txt`

Pins the Backstage release line used by the custom-application bootstrap process.

### `backstage-app/overrides/app-config.production.yaml`

Provides production-oriented Backstage configuration with GitHub auth, catalog, TechDocs, Kubernetes, and Argo CD integration.

### `backstage-app/overrides/packages/app/src/App.tsx`

Overrides the generated Backstage frontend to configure navigation, GitHub sign-in, entity pages, Kubernetes, CI/CD, and Argo CD views.

### `backstage-app/overrides/packages/app/src/components/catalog/EntityPage.tsx`

Overrides the generated Backstage frontend to configure navigation, GitHub sign-in, entity pages, Kubernetes, CI/CD, and Argo CD views.

### `backstage-app/overrides/packages/backend/src/index.ts`

Overrides the generated Backstage backend to register core IDP modules, platform plugins, and the permission policy.

### `backstage-app/overrides/packages/backend/src/modules/permissionPolicy.ts`

Overrides the generated Backstage backend to register core IDP modules, platform plugins, and the permission policy.

## `software-templates`

### `software-templates/tusker-service/skeleton/gitops-registration/application.yaml`

Template content that creates the generated service Argo CD Application in the platform GitOps repository.

### `software-templates/tusker-service/skeleton/service/.dockerignore`

Supports the generated golden-path service repository.

### `software-templates/tusker-service/skeleton/service/.github/workflows/ci.yml`

Provides the generated service test, container build, publish, and security scan workflow.

### `software-templates/tusker-service/skeleton/service/CODEOWNERS`

Supports the generated golden-path service repository.

### `software-templates/tusker-service/skeleton/service/Dockerfile`

Builds the generated service as a non-root Python container.

### `software-templates/tusker-service/skeleton/service/catalog-info.yaml`

Registers the generated service and API in Backstage with GitHub, Argo CD, Kubernetes, and TechDocs annotations.

### `software-templates/tusker-service/skeleton/service/deploy/base/deployment.yaml`

Defines the `${{ values.name }}` Deployment and its declarative configuration.

### `software-templates/tusker-service/skeleton/service/deploy/base/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `software-templates/tusker-service/skeleton/service/deploy/base/network-policy.yaml`

Defines 2 YAML resources, including NetworkPolicy objects.

### `software-templates/tusker-service/skeleton/service/deploy/base/pod-disruption-budget.yaml`

Defines the `${{ values.name }}` PodDisruptionBudget and its declarative configuration.

### `software-templates/tusker-service/skeleton/service/deploy/base/service-account.yaml`

Defines the `${{ values.name }}` ServiceAccount and its declarative configuration.

### `software-templates/tusker-service/skeleton/service/deploy/base/service.yaml`

Defines the `${{ values.name }}` Service and its declarative configuration.

### `software-templates/tusker-service/skeleton/service/deploy/overlays/development/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `software-templates/tusker-service/skeleton/service/deploy/overlays/production/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `software-templates/tusker-service/skeleton/service/deploy/overlays/staging/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `software-templates/tusker-service/skeleton/service/docs/index.md`

Provides generated service documentation or an operations runbook.

### `software-templates/tusker-service/skeleton/service/docs/runbook.md`

Provides generated service documentation or an operations runbook.

### `software-templates/tusker-service/skeleton/service/mkdocs.yml`

Defines the generated service TechDocs navigation.

### `software-templates/tusker-service/skeleton/service/openapi.yaml`

Defines the generated service OpenAPI contract.

### `software-templates/tusker-service/skeleton/service/requirements.txt`

Pins the generated FastAPI service runtime and test dependencies.

### `software-templates/tusker-service/skeleton/service/src/__init__.py`

Implements or tests the generated FastAPI service.

### `software-templates/tusker-service/skeleton/service/src/main.py`

Implements or tests the generated FastAPI service.

### `software-templates/tusker-service/skeleton/service/tests/test_main.py`

Implements or tests the generated FastAPI service.

### `software-templates/tusker-service/template.yaml`

Defines the Backstage golden path that creates a secure service repository, registers it, and opens a GitOps onboarding pull request.

## `platform-services`

### `platform-services/backstage/ARCHITECTURE-REVIEW.md`

Documents Backstage architecture, configuration, capability status, or readiness: Backstage Production Architecture Review.

### `platform-services/backstage/CAPABILITY-MATRIX.md`

Documents Backstage architecture, configuration, capability status, or readiness: Backstage IDP capability matrix.

### `platform-services/backstage/CATALOG-ARCHITECTURE.md`

Documents Backstage architecture, configuration, capability status, or readiness: Backstage Software Catalog Architecture.

### `platform-services/backstage/CONFIGURATION-FRAMEWORK.md`

Documents Backstage architecture, configuration, capability status, or readiness: Backstage Configuration Framework.

### `platform-services/backstage/ENTERPRISE-READINESS-REVIEW.md`

Documents Backstage architecture, configuration, capability status, or readiness: Backstage Enterprise Readiness Review.

### `platform-services/backstage/PLUGIN-REVIEW.md`

Documents Backstage architecture, configuration, capability status, or readiness: Backstage Plugin Review.

### `platform-services/backstage/README.md`

Documents Backstage architecture, configuration, capability status, or readiness: Backstage platform service.

### `platform-services/backstage/examples/external-secret-argocd.yaml`

Provides a non-applied External Secret contract that must be mapped to the selected secret store.

### `platform-services/backstage/examples/external-secret-auth.yaml`

Provides a non-applied External Secret contract that must be mapped to the selected secret store.

### `platform-services/backstage/examples/external-secret-github.yaml`

Provides a non-applied External Secret contract that must be mapped to the selected secret store.

### `platform-services/backstage/manifests/cluster-role-binding.yaml`

Defines the `backstage-kubernetes-reader` ClusterRoleBinding and its declarative configuration.

### `platform-services/backstage/manifests/cluster-role.yaml`

Defines the `backstage-kubernetes-reader` ClusterRole and its declarative configuration.

### `platform-services/backstage/manifests/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `platform-services/backstage/manifests/network-policy.yaml`

Defines the `backstage-ingress` NetworkPolicy and its declarative configuration.

### `platform-services/backstage/manifests/service-account.yaml`

Defines the `backstage` ServiceAccount and its declarative configuration.

### `platform-services/backstage/values/development-idp.yaml`

Configures the Backstage Helm release for a specific environment or migration mode.

### `platform-services/backstage/values/development-stock.yaml`

Configures the Backstage Helm release for a specific environment or migration mode.

### `platform-services/backstage/values/development.yaml`

Configures the Backstage Helm release for a specific environment or migration mode.

### `platform-services/backstage/values/production.yaml`

Configures the Backstage Helm release for a specific environment or migration mode.

### `platform-services/backstage/values/staging.yaml`

Configures the Backstage Helm release for a specific environment or migration mode.

### `platform-services/backstage/values/testing.yaml`

Configures the Backstage Helm release for a specific environment or migration mode.

### `platform-services/cert-manager/CHANGELOG.md`

Documentation: Changelog.

### `platform-services/cert-manager/README.md`

Documentation: cert-manager.

### `platform-services/cert-manager/values/development.yaml`

Defines the `development` YAML configuration and its declarative configuration.

### `platform-services/cert-manager/values/production.yaml`

Defines the `production` YAML configuration and its declarative configuration.

### `platform-services/cert-manager/values/staging.yaml`

Defines the `staging` YAML configuration and its declarative configuration.

### `platform-services/doppler/README.md`

Documentation: Doppler.

### `platform-services/doppler/values/development.yaml`

Defines the `development` YAML configuration and its declarative configuration.

### `platform-services/doppler/values/production.yaml`

Defines the `production` YAML configuration and its declarative configuration.

### `platform-services/doppler/values/staging.yaml`

Defines the `staging` YAML configuration and its declarative configuration.

### `platform-services/external-secrets/README.md`

Documentation: External Secrets Operator.

### `platform-services/external-secrets/values/development.yaml`

Defines the `development` YAML configuration and its declarative configuration.

### `platform-services/external-secrets/values/production.yaml`

Defines the `production` YAML configuration and its declarative configuration.

### `platform-services/external-secrets/values/staging.yaml`

Defines the `staging` YAML configuration and its declarative configuration.

### `platform-services/grafana/README.md`

Documentation: Grafana.

### `platform-services/grafana/values/development.yaml`

Defines the `development` YAML configuration and its declarative configuration.

### `platform-services/grafana/values/production.yaml`

Defines the `production` YAML configuration and its declarative configuration.

### `platform-services/grafana/values/staging.yaml`

Defines the `staging` YAML configuration and its declarative configuration.

### `platform-services/kyverno/README.md`

Documentation: Kyverno.

### `platform-services/kyverno/values/development.yaml`

Defines the `development` YAML configuration and its declarative configuration.

### `platform-services/kyverno/values/production.yaml`

Defines the `production` YAML configuration and its declarative configuration.

### `platform-services/kyverno/values/staging.yaml`

Defines the `staging` YAML configuration and its declarative configuration.

### `platform-services/loki/README.md`

Documentation: Loki.

### `platform-services/loki/values/development.yaml`

Defines the `development` YAML configuration and its declarative configuration.

### `platform-services/loki/values/production.yaml`

Defines the `production` YAML configuration and its declarative configuration.

### `platform-services/loki/values/staging.yaml`

Defines the `staging` YAML configuration and its declarative configuration.

### `platform-services/prometheus/README.md`

Documentation: Prometheus.

### `platform-services/prometheus/values/development.yaml`

Defines the `development` YAML configuration and its declarative configuration.

### `platform-services/prometheus/values/production.yaml`

Defines the `production` YAML configuration and its declarative configuration.

### `platform-services/prometheus/values/staging.yaml`

Defines the `staging` YAML configuration and its declarative configuration.

### `platform-services/traefik/CHANGELOG.md`

Documentation: Changelog.

### `platform-services/traefik/README.md`

Documentation: Traefik.

### `platform-services/traefik/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `platform-services/traefik/values/development.yaml`

Defines the `development` YAML configuration and its declarative configuration.

### `platform-services/traefik/values/production.yaml`

Defines the `production` YAML configuration and its declarative configuration.

### `platform-services/traefik/values/staging.yaml`

Defines the `staging` YAML configuration and its declarative configuration.

## `workloads`

### `workloads/demo-service/base/content/healthz`

Provides the static health response served by the demo container.

### `workloads/demo-service/base/content/index.html`

Provides the visible demo page changed during the Git-driven release demonstration.

### `workloads/demo-service/base/deployment.yaml`

Defines the `demo-service` Deployment and its declarative configuration.

### `workloads/demo-service/base/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `workloads/demo-service/base/network-policy.yaml`

Defines 2 YAML resources, including NetworkPolicy objects.

### `workloads/demo-service/base/pod-disruption-budget.yaml`

Defines the `demo-service` PodDisruptionBudget and its declarative configuration.

### `workloads/demo-service/base/service-account.yaml`

Defines the `demo-service` ServiceAccount and its declarative configuration.

### `workloads/demo-service/base/service.yaml`

Defines the `demo-service` Service and its declarative configuration.

### `workloads/demo-service/docs/index.md`

Documents ownership, release, runtime, and rollback of the demo workload.

### `workloads/demo-service/mkdocs.yml`

Defines the `mkdocs` YAML configuration and its declarative configuration.

### `workloads/demo-service/overlays/development/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `workloads/demo-service/overlays/production/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `workloads/demo-service/overlays/staging/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

## `gitops`

### `gitops/applications/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/developer-platform/backstage/application-development.yaml`

Defines the `backstage` Application and its declarative configuration.

### `gitops/applications/platform/developer-platform/backstage/application-production.yaml`

Defines the `backstage-production` Application and its declarative configuration.

### `gitops/applications/platform/developer-platform/backstage/application-resources-development.yaml`

Defines the `backstage-platform-resources` Application and its declarative configuration.

### `gitops/applications/platform/developer-platform/backstage/application-staging.yaml`

Defines the `backstage-staging` Application and its declarative configuration.

### `gitops/applications/platform/developer-platform/backstage/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/developer-platform/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/networking/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/networking/traefik/application-development.yaml`

Defines the `traefik-development` Application and its declarative configuration.

### `gitops/applications/platform/networking/traefik/application-production.yaml`

Defines the `traefik-production` Application and its declarative configuration.

### `gitops/applications/platform/networking/traefik/application-staging.yaml`

Defines the `traefik-staging` Application and its declarative configuration.

### `gitops/applications/platform/networking/traefik/application.yaml`

Defines the `traefik` Application and its declarative configuration.

### `gitops/applications/platform/networking/traefik/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/observability/grafana/application-development.yaml`

Defines the `grafana` Application and its declarative configuration.

### `gitops/applications/platform/observability/grafana/application-production.yaml`

Defines the `grafana-production` Application and its declarative configuration.

### `gitops/applications/platform/observability/grafana/application-staging.yaml`

Defines the `grafana-staging` Application and its declarative configuration.

### `gitops/applications/platform/observability/grafana/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/observability/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/observability/loki/application-development.yaml`

Defines the `loki` Application and its declarative configuration.

### `gitops/applications/platform/observability/loki/application-production.yaml`

Defines the `loki-production` Application and its declarative configuration.

### `gitops/applications/platform/observability/loki/application-staging.yaml`

Defines the `loki-staging` Application and its declarative configuration.

### `gitops/applications/platform/observability/loki/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/observability/prometheus/application-development.yaml`

Defines the `prometheus` Application and its declarative configuration.

### `gitops/applications/platform/observability/prometheus/application-production.yaml`

Defines the `prometheus-production` Application and its declarative configuration.

### `gitops/applications/platform/observability/prometheus/application-staging.yaml`

Defines the `prometheus-staging` Application and its declarative configuration.

### `gitops/applications/platform/observability/prometheus/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/security/cert-manager/application-development.yaml`

Defines the `cert-manager` Application and its declarative configuration.

### `gitops/applications/platform/security/cert-manager/application-production.yaml`

Defines the `cert-manager-production` Application and its declarative configuration.

### `gitops/applications/platform/security/cert-manager/application-staging.yaml`

Defines the `cert-manager-staging` Application and its declarative configuration.

### `gitops/applications/platform/security/cert-manager/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/security/doppler/application-development.yaml`

Defines the `doppler` Application and its declarative configuration.

### `gitops/applications/platform/security/doppler/application-production.yaml`

Defines the `doppler-production` Application and its declarative configuration.

### `gitops/applications/platform/security/doppler/application-staging.yaml`

Defines the `doppler-staging` Application and its declarative configuration.

### `gitops/applications/platform/security/doppler/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/security/external-secrets/application-development.yaml`

Defines the `external-secrets` Application and its declarative configuration.

### `gitops/applications/platform/security/external-secrets/application-production.yaml`

Defines the `external-secrets-production` Application and its declarative configuration.

### `gitops/applications/platform/security/external-secrets/application-staging.yaml`

Defines the `external-secrets-staging` Application and its declarative configuration.

### `gitops/applications/platform/security/external-secrets/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/security/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/platform/security/kyverno/application-development.yaml`

Defines the `kyverno` Application and its declarative configuration.

### `gitops/applications/platform/security/kyverno/application-production.yaml`

Defines the `kyverno-production` Application and its declarative configuration.

### `gitops/applications/platform/security/kyverno/application-staging.yaml`

Defines the `kyverno-staging` Application and its declarative configuration.

### `gitops/applications/platform/security/kyverno/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/root/application.yaml`

Defines the `platform-root` Application and its declarative configuration.

### `gitops/applications/root/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/workloads/demo-service/application-development.yaml`

Defines the `demo-service-development` Application and its declarative configuration.

### `gitops/applications/workloads/demo-service/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/applications/workloads/generated-workloads-application.yaml`

Defines the `generated-workloads` Application and its declarative configuration.

### `gitops/applications/workloads/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/appsets/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/bootstrap/argocd/install/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/bootstrap/argocd/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/bootstrap/argocd/namespace.yaml`

Defines the `argocd` Namespace and its declarative configuration.

### `gitops/bootstrap/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/bootstrap/root-application/application.yaml`

Defines the `platform-root` Application and its declarative configuration.

### `gitops/bootstrap/root-application/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/environments/development/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/environments/production/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/environments/staging/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/generated-workloads/.gitkeep`

Holds Argo CD Application manifests created through the Backstage golden path.

### `gitops/generated-workloads/README.md`

Holds Argo CD Application manifests created through the Backstage golden path.

### `gitops/projects/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/projects/platform/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/projects/platform/project.yaml`

Defines the `platform` AppProject and its declarative configuration.

### `gitops/projects/workloads/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

### `gitops/projects/workloads/project.yaml`

Defines the `workloads` AppProject and its declarative configuration.

### `gitops/shared/kustomization.yaml`

Defines the `kustomization` Kustomization and its declarative configuration.

## `scripts`

### `scripts/backstage/bootstrap-custom-app.sh`

Automates custom Backstage generation, runtime credential configuration, migration, or rollback.

### `scripts/backstage/configure-argocd-readonly.sh`

Automates custom Backstage generation, runtime credential configuration, migration, or rollback.

### `scripts/backstage/configure-github-oauth-secret.sh`

Automates custom Backstage generation, runtime credential configuration, migration, or rollback.

### `scripts/backstage/rollback-to-stock-values.sh`

Automates custom Backstage generation, runtime credential configuration, migration, or rollback.

### `scripts/backstage/switch-to-idp-values.sh`

Automates custom Backstage generation, runtime credential configuration, migration, or rollback.

### `scripts/demo/introduce-drift.sh`

Automates demo readiness checks, status display, or controlled drift.

### `scripts/demo/preflight.sh`

Automates demo readiness checks, status display, or controlled drift.

### `scripts/demo/status.sh`

Automates demo readiness checks, status display, or controlled drift.

### `scripts/platform-verification/README.md`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/developer-platform/verify-backstage.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/argocd-api.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/bootstrap.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/checks/argocd.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/checks/kubernetes.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/common.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/constants.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/executor.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/kubernetes-api.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/output.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/report.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/runtime.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/state.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/lib/verifiers.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/networking/verify-traefik.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/observability/verify-grafana.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/observability/verify-loki.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/observability/verify-prometheus.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/profiles/audit.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/profiles/e2e.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/profiles/platform.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/profiles/post-upgrade.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/profiles/pre-upgrade.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/profiles/regression.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/profiles/smoke.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/security/verify-cert-manager.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/security/verify-doppler.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/security/verify-external-secrets.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/security/verify-kyverno.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/tests/cert-manager.md`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/tests/test-backstage.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/tests/test-doppler.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/tests/test-external-secrets.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/tests/test-grafana.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/tests/test-kyverno.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/tests/test-loki.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/tests/test-prometheus.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/tests/test-workloads.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/platform-verification/verify.sh`

Performs platform verification, security checks, or operational automation.

### `scripts/validate_idp.py`

Validates YAML duplicate keys, catalog targets, secret hygiene, Kustomize references, and required IDP assets.

## `infrastructure`

### `infrastructure/ansible/ansible.cfg`

Supports Ansible-based infrastructure and platform bootstrap.

### `infrastructure/ansible/collections/requirements.yml`

Defines the `requirements` YAML configuration and its declarative configuration.

### `infrastructure/ansible/docs/deployment-topology.md`

Supports Ansible-based infrastructure and platform bootstrap.

### `infrastructure/ansible/inventories/dev/group_vars/all.yml`

Defines the `all` YAML configuration and its declarative configuration.

### `infrastructure/ansible/inventories/dev/host_vars/vps8.yml`

Defines the `vps8` YAML configuration and its declarative configuration.

### `infrastructure/ansible/inventories/dev/hosts.yml`

Defines the `hosts` YAML configuration and its declarative configuration.

### `infrastructure/ansible/playbooks/argocd.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/playbooks/bootstrap.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/playbooks/common.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/playbooks/k3s.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/playbooks/kernel.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/playbooks/kubectl.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/playbooks/kubernetes.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/playbooks/observability.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/playbooks/platform.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/playbooks/security.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/playbooks/site.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/playbooks/timesync.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/playbooks/validate.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/defaults/main.yml`

Defines the `main` YAML configuration and its declarative configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/files/values.yaml`

Defines the `values` YAML configuration and its declarative configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/handlers/main.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/meta/main.yml`

Defines the `main` YAML configuration and its declarative configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/tasks/download.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/tasks/install.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/tasks/main.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/tasks/namespace.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/tasks/prerequisites.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/tasks/repository.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/tasks/root_application.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/tasks/validation.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/tasks/verify.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/tasks/wait.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/argocd_bootstrap/templates/.gitkeep`

Supports Ansible-based infrastructure and platform bootstrap.

### `infrastructure/ansible/roles/argocd_bootstrap/templates/values.yaml.j2`

Supports Ansible-based infrastructure and platform bootstrap.

### `infrastructure/ansible/roles/common/README.md`

Supports Ansible-based infrastructure and platform bootstrap.

### `infrastructure/ansible/roles/common/defaults/main.yml`

Defines the `main` YAML configuration and its declarative configuration.

### `infrastructure/ansible/roles/common/handlers/main.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/common/meta/main.yml`

Defines the `main` YAML configuration and its declarative configuration.

### `infrastructure/ansible/roles/common/tasks/main.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/k3s/defaults/main.yml`

Defines the `main` YAML configuration and its declarative configuration.

### `infrastructure/ansible/roles/k3s/meta/main.yml`

Defines the `main` YAML configuration and its declarative configuration.

### `infrastructure/ansible/roles/k3s/tasks/main.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/kernel/meta/main.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/kernel/tasks/main.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/kubectl/meta/main.yml`

Defines the `main` YAML configuration and its declarative configuration.

### `infrastructure/ansible/roles/kubectl/tasks/main.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/ssh/tasks/main.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/timesync/meta/main.yml`

Defines the `main` YAML configuration and its declarative configuration.

### `infrastructure/ansible/roles/timesync/tasks/main.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/users/README.md`

Supports Ansible-based infrastructure and platform bootstrap.

### `infrastructure/ansible/roles/users/defaults/main.yml`

Defines the `main` YAML configuration and its declarative configuration.

### `infrastructure/ansible/roles/users/handlers/main.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/ansible/roles/users/meta/main.yml`

Defines the `main` YAML configuration and its declarative configuration.

### `infrastructure/ansible/roles/users/tasks/main.yml`

Defines Ansible automation for platform bootstrap and configuration.

### `infrastructure/bootstrap/bootstrap.sh`

Provides executable shell automation.

### `infrastructure/terraform/providers.tf`

Defines or documents Terraform-managed infrastructure and validation.

### `infrastructure/terraform/versions.tf`

Defines or documents Terraform-managed infrastructure and validation.

### `infrastructure/validation/validate.sh`

Provides executable shell automation.

## `docs`

### `docs/COPILOT-INSTRUCTIONS.md`

Learning and operating documentation: TuskerBlueprint AI Implementation Instructions.

### `docs/ENGINEERING-STANDARDS.md`

Learning and operating documentation: TuskerBlueprint Engineering Standards.

### `docs/GITOPS-STANDARDS.md`

Learning and operating documentation: TuskerBlueprint GitOps Standards.

### `docs/IDP-CHANGE-MANIFEST.md`

Learning and operating documentation: IDP change manifest.

### `docs/IDP-MIGRATION-RUNBOOK.md`

Learning and operating documentation: Backstage IDP migration runbook.

### `docs/IDP-VALIDATION-REPORT.md`

Learning and operating documentation: IDP validation report.

### `docs/IMPLEMENTATION-GUIDE.md`

Learning and operating documentation: TuskerBlueprint Implementation Guide.

### `docs/IMPLEMENTATION-WORKFLOW.md`

Learning and operating documentation: TuskerBlueprint Implementation Workflow.

### `docs/PLATFORM-STANDARDS.md`

Learning and operating documentation: TuskerBlueprint Platform Standards.

### `docs/REPOSITORY-STANDARDS.md`

Learning and operating documentation: TuskerBlueprint Repository Standards.

### `docs/SECURITY-STANDARDS.md`

Learning and operating documentation: TuskerBlueprint Security Standards.

### `docs/TUSKERBLUEPRINT_REPOSITORY_FILE_GUIDE.md`

Provides a learning-oriented explanation of every file in the repository.

### `docs/VALIDATION-STANDARDS.md`

Learning and operating documentation: TuskerBlueprint Validation Standards.

### `docs/architecture-decisions/ADR-0001-gitops-ownership.md`

Learning and operating documentation: ADR-0001 – Platform Ownership Model.

### `docs/architecture-decisions/ADR-0002-bootstrap-strategy.md`

Learning and operating documentation: ADR-0002 – Platform Bootstrap Strategy.

### `docs/architecture-decisions/ADR-0003-platform-service-layout.md`

Learning and operating documentation: ADR-0003 – Platform Service Repository Layout.

### `docs/architecture-decisions/ADR-0004-argocd-native-helm.md`

Learning and operating documentation: ADR-0004 – Argo CD Native Helm.

### `docs/architecture-decisions/ADR-0005-environment-strategy.md`

Learning and operating documentation: ADR-0005 – Environment Strategy.

### `docs/architecture-decisions/README.md`

Learning and operating documentation: Architecture Decision Records (ADRs).

### `docs/architecture.md`

Learning and operating documentation: Architecture.

### `docs/backstage.md`

Learning and operating documentation: Backstage implementation.

### `docs/demo-runbook.md`

Learning and operating documentation: Customer demo runbook.

### `docs/developer-journey.md`

Learning and operating documentation: Developer journey.

### `docs/gitops.md`

Learning and operating documentation: GitOps operating model.

### `docs/index.md`

Learning and operating documentation: TuskerBlueprint Internal Developer Platform.

### `docs/operations.md`

Learning and operating documentation: Operations.

### `docs/platform-roadmap.md`

Learning and operating documentation: TuskerBlueprint Platform Roadmap.

### `docs/platform-versions.md`

Learning and operating documentation: TuskerBlueprint Platform Compatibility Matrix.

### `docs/security.md`

Learning and operating documentation: Security.

### `docs/service-onboarding.md`

Learning and operating documentation: Service onboarding.

### `docs/service-standards.md`

Learning and operating documentation: Service standards.


## 2026-07-30: Browser application and service access model

- Added a responsive browser UI to the maintained Customer Notification demo.
- Added the same lightweight UI pattern to newly generated golden-path services.
- Added service status and notification-list APIs with tests and OpenAPI updates.
- Added workload namespace labels and NetworkPolicy rules for approved service-to-service access.
- Documented Argo CD deployment destinations, repository boundaries, Kubernetes DNS and port-forward access.
- Added `scripts/demo/open-demo-ui.sh` for repeatable browser access.
# IDP enhancement changelog


## 1.2.0

- Added the canonical `docs/SETUP-FROM-SCRATCH.md` installation guide.
- Documented the current Terraform and Ansible automation boundary.
- Added the Backstage-to-Argo CD authentication, TLS trust, certificate rotation, verification, and troubleshooting runbook.
- Added `scripts/backstage/update-argocd-ca-configmap.sh` to regenerate the public CA ConfigMap from the live Argo CD certificate.
- Corrected documentation to show `development-idp.yaml` as the active development values file and `development.yaml` as the rollback path.
- Documented the required sync order: `backstage-platform-resources` before `backstage`.
- Added exact port-forward URLs and UI navigation for Backstage and Argo CD.
- Updated TechDocs navigation, operations guidance, demo preparation, and repository path references.
- Restored the root `.gitignore` and GitHub workflow metadata omitted from the uploaded archive, allowing the full demo validator to pass.

## 1.1.0

- Added a structured Backstage catalog under `catalog/`.
- Added platform TechDocs and demo-service TechDocs.
- Added OpenAPI discovery.
- Added a secure FastAPI golden-path Software Template.
- Added a GitOps onboarding pull-request flow for generated services.
- Added a recursive generated-workloads Argo CD controller.
- Added a hardened demo workload with overlays.
- Added read-only Kubernetes RBAC for Backstage.
- Added read-only Argo CD runtime configuration scripts.
- Added GitHub OAuth Secret creation script.
- Added custom Backstage app bootstrap overlay and image workflow.
- Added safe stock-to-IDP migration and rollback values.
- Added IDP validation workflow and repository validation script.
- Corrected duplicate development Kustomize composition.
- Replaced the directly rendered reference workload with a proper Argo CD Application.
- Updated AppProject source repositories and workload restrictions.

## Delivery platform buyer-demo milestone

- Replaced the static demo workload with a tested FastAPI reference API.
- Added quality, security, image, SBOM, and immutable GitOps release automation.
- Added TechDocs, OpenAPI, metrics, correlation IDs, and failure-mode controls.
- Added a Grafana delivery dashboard and optional Alloy log collector.
- Enhanced the Tusker Service golden path with immutable release promotion.
- Added offline validation, preflight, reset, traffic, failure, and recovery scripts.

## 1.3.0

- Added the Backstage User entity for the GitHub identity `subeeshlearn` and a non-administrator `developers` Group.
- Expanded the Tusker Service golden path to provision the repository with the Backstage platform credential and grant the selected developer push access.
- Added complete generated service assets: README, contribution and security guidance, pull-request template, Dependabot, local verification, TechDocs architecture/development/delivery/operations/observability/security pages, OpenAPI, and hardened Kubernetes overlays.
- Added separate generated-service CI/release and metadata/GitOps validation workflows.
- Added the complete `docs/DEVELOPER-DEMO-WORKFLOW.md` runbook covering first login, scaffolding, repository access, clone, pull request, CI/security evidence, immutable image publication, GitOps onboarding, Argo CD deployment, and Backstage runtime views.
- Added `scripts/backstage/configure-github-platform-secret.sh` and aligned the ExternalSecret example to use the scaffolder-capable GitHub token.
- Strengthened repository validators to require the developer identity, workflows, generated documentation, provisioning actions, collaborator access, and GitOps target path.

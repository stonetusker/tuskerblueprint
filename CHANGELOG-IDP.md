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

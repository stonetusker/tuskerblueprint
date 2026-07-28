# IDP enhancement changelog

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

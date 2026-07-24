# Backstage IDP capability matrix

| Capability | Stock image mode | Custom IDP mode | Evidence |
| --- | --- | --- | --- |
| Private GitHub catalog | Implemented | Implemented | `catalog-info.yaml`, `development.yaml` |
| Structured ownership model | Implemented | Implemented | `catalog/` |
| TechDocs | Configuration present | Implemented in custom app | `mkdocs.yml`, `docs/` |
| API documentation | Catalog data present | Implemented in custom app | `catalog/apis/`, `apis/` |
| Search | Image-dependent | Implemented in custom app | `backstage-app/` |
| Software Templates | Image-dependent | Implemented in custom app | `software-templates/` |
| Kubernetes visibility | Not claimed | Implemented after custom image and RBAC | `platform-services/backstage/manifests/` |
| Argo CD cards | Not claimed | Implemented after custom image and token | `backstage-app/`, runtime script |
| GitHub OAuth | Guest mode | Implemented after OAuth Secret creation | `development-idp.yaml` |
| Permissions | Not claimed | Extension point included | `backstage-app/packages/backend/` |
| External Secrets | Examples only | Ready after store mapping | `platform-services/backstage/examples/` |

The repository intentionally keeps the active development values on the stock image until the custom image build is successful. This prevents a GitOps rollout from breaking the currently healthy portal.

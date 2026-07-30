# TuskerBlueprint IDP Reference

TuskerBlueprint is a customer-facing Internal Developer Platform reference implementation built with Backstage, Argo CD, Kubernetes, GitHub, policy controls, and observability.

## Demonstrated capabilities

- Structured Backstage Software Catalog with ownership, domains, systems, components, APIs, and resources
- Private GitHub repository ingestion
- TechDocs documentation-as-code
- OpenAPI discovery
- Secure golden-path service creation through Backstage Software Templates
- GitHub repository creation and GitOps onboarding pull requests
- Argo CD deployment visibility and reconciliation
- Read-only Kubernetes runtime visibility
- GitHub OAuth sign-in
- GitHub Actions visibility
- Least-privilege runtime access for Backstage
- A hardened demo workload for release and self-healing demonstrations

## Current development deployment

The development Argo CD Application uses the plugin-enabled custom Backstage values:

```text
platform-services/backstage/values/development-idp.yaml
```

The stock-image rollback values remain at:

```text
platform-services/backstage/values/development.yaml
```

Backstage trusts the Argo CD server certificate through:

```text
platform-services/backstage/manifests/argocd-ca-configmap.yaml
```

The public certificate is cluster-specific. Regenerate it when rebuilding or rotating Argo CD:

```bash
scripts/backstage/update-argocd-ca-configmap.sh
```

## Local access

Keep each port-forward in a separate terminal:

```bash
kubectl -n backstage port-forward svc/backstage 7007:7007
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Open:

```text
Backstage: http://localhost:7007
Argo CD:   https://localhost:8080
```

Backstage connects to Argo CD internally through `https://argocd-server.argocd.svc.cluster.local`; it does not use the laptop port-forward.

## Important paths

| Path | Purpose |
| --- | --- |
| `docs/SETUP-FROM-SCRATCH.md` | Canonical infrastructure and platform installation guide |
| `docs/BACKSTAGE-ARGOCD-INTEGRATION.md` | Authentication, TLS trust, verification, rotation, and troubleshooting |
| `docs/IDP-MIGRATION-RUNBOOK.md` | Backstage custom-image deployment and rollback |
| `catalog-info.yaml` | Root Backstage Location |
| `catalog/` | Users, groups, systems, components, APIs, and resources |
| `mkdocs.yml`, `docs/` | Platform TechDocs |
| `software-templates/tusker-service/` | Golden-path service template |
| `backstage-app/` | Custom Backstage app bootstrap overlay |
| `platform-services/backstage/values/development-idp.yaml` | Active custom IDP-image values |
| `platform-services/backstage/values/development.yaml` | Stock-image rollback values |
| `platform-services/backstage/manifests/` | Backstage RBAC, NetworkPolicy, and Argo CD CA trust |
| `workloads/demo-service/` | Hardened demonstration workload |
| `gitops/generated-workloads/` | Template-generated Argo CD Applications |
| `scripts/backstage/` | Runtime configuration, certificate, and migration scripts |
| `scripts/demo/` | Demo validation, preflight, drift, and recovery scripts |

## Validate the repository

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install 'PyYAML==6.0.2'
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py
```

## Documentation order

1. `docs/SETUP-FROM-SCRATCH.md`
2. `docs/architecture.md`
3. `docs/BACKSTAGE-ARGOCD-INTEGRATION.md`
4. `docs/IDP-MIGRATION-RUNBOOK.md`
5. `docs/demo-runbook.md`
6. `docs/TUSKERBLUEPRINT_REPOSITORY_FILE_GUIDE.md`

## Security

No secret values belong in this repository. Runtime Secrets must be created with the included scripts or synchronized from an approved external secret store. The Argo CD CA ConfigMap contains only a public certificate; never add `tls.key`.

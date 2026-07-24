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

## Safe migration design

The repository deliberately keeps the active Argo CD Application on:

```text
platform-services/backstage/values/development.yaml
```

That file uses the currently working stock Backstage image.

The plugin-enabled custom image is configured in:

```text
platform-services/backstage/values/development-idp.yaml
```

Switch only after the custom image workflow has published the image and the runtime Secrets exist. This prevents a failed image build or missing Secret from taking down the current portal.

## Important paths

| Path | Purpose |
| --- | --- |
| `catalog-info.yaml` | Root Backstage Location |
| `catalog/` | Users, groups, systems, components, APIs, and resources |
| `mkdocs.yml`, `docs/` | Platform TechDocs |
| `software-templates/tusker-service/` | Golden-path service template |
| `backstage-app/` | Custom Backstage app bootstrap overlay |
| `platform-services/backstage/values/development.yaml` | Working stock-image values |
| `platform-services/backstage/values/development-idp.yaml` | Custom IDP-image values |
| `platform-services/backstage/manifests/` | Read-only Kubernetes RBAC and NetworkPolicy |
| `workloads/demo-service/` | Hardened demonstration workload |
| `gitops/generated-workloads/` | Template-generated Argo CD Applications |
| `scripts/backstage/` | Runtime configuration and migration scripts |
| `scripts/demo/` | Demo preflight and drift scripts |

## Validate the repository

```bash
python -m venv .venv
source .venv/bin/activate
pip install PyYAML==6.0.2
python scripts/validate_idp.py
```

## Documentation

Start with:

- `docs/IDP-MIGRATION-RUNBOOK.md`
- `docs/demo-runbook.md`
- `docs/architecture.md`
- `platform-services/backstage/CAPABILITY-MATRIX.md`

## Security

No secret values belong in this repository. Runtime Secrets must be created with the included scripts or synchronized from an approved external secret store.

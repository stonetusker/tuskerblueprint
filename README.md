# TuskerBlueprint IDP Reference

TuskerBlueprint is a customer-facing Internal Developer Platform reference implementation built with Backstage, Argo CD, Kubernetes, GitHub, policy controls, and observability.

## Demonstrated capabilities

- Structured Backstage Software Catalog with ownership, domains, systems, components, APIs, and resources
- Private GitHub repository ingestion
- TechDocs documentation-as-code
- OpenAPI discovery
- Secure golden-path service creation through Backstage Software Templates
- End-to-end developer onboarding for the GitHub user `subeeshlearn`
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
| `docs/DEVELOPER-DEMO-WORKFLOW.md` | End-to-end `subeeshlearn` golden-path, repository, CI/CD, GitOps, and runtime demo |
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
python -m pip install -r workloads/demo-service/requirements-dev.txt
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py
PYTHONDONTWRITEBYTECODE=1 python3 scripts/demo/validate-demo-source.py
```

## Documentation order

1. `docs/SETUP-FROM-SCRATCH.md`
2. `docs/DEVELOPER-DEMO-WORKFLOW.md`
3. `docs/architecture.md`
4. `docs/BACKSTAGE-ARGOCD-INTEGRATION.md`
5. `docs/IDP-MIGRATION-RUNBOOK.md`
6. `docs/demo-runbook.md`
7. `docs/TUSKERBLUEPRINT_REPOSITORY_FILE_GUIDE.md`

## Security

No secret values belong in this repository. Runtime Secrets must be created with the included scripts or synchronized from an approved external secret store. The Argo CD CA ConfigMap contains only a public certificate; never add `tls.key`.


## Service deployment and access

See [`docs/SERVICE-DEPLOYMENT-AND-ACCESS.md`](docs/SERVICE-DEPLOYMENT-AND-ACCESS.md) for Argo CD destinations, repository cloning boundaries, Kubernetes DNS and browser access.

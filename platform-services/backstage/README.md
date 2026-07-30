# Backstage platform service

This directory contains the Kubernetes deployment configuration and runtime-access resources for the TuskerBlueprint developer portal.

## Deployment files

- `values/development-idp.yaml`: active plugin-enabled custom-image deployment for development.
- `values/development.yaml`: stock-image rollback values.
- `values/development-stock.yaml`: retained stock configuration copy.
- `manifests/`: ServiceAccount, read-only RBAC, NetworkPolicy, and Argo CD public CA ConfigMap.
- `examples/`: External Secret contracts that are intentionally not applied until a real secret store is selected.

The active values file is selected in:

```text
gitops/applications/platform/developer-platform/backstage/application-development.yaml
```

## Runtime dependencies

The custom deployment expects:

```text
backstage/backstage-github-credentials
backstage/backstage-auth-secrets
backstage/backstage-argocd-credentials
backstage/backstage-argocd-ca
```

The first three are Secrets and must never be committed. `backstage-argocd-ca` is a ConfigMap containing only the public Argo CD certificate.


## GitHub provisioning credential

The active integration reads `GITHUB_TOKEN` from `backstage-github-credentials`. For the golden-path demo, this must be a platform/scaffolder credential capable of creating repositories in `stonetusker`, adding `subeeshlearn` as a collaborator, writing workflow files, and opening the GitOps onboarding pull request.

Create or update it with:

```bash
scripts/backstage/configure-github-platform-secret.sh
```

GitHub OAuth remains separate and is used only for interactive user sign-in.

## Argo CD certificate trust

Backstage connects to:

```text
https://argocd-server.argocd.svc.cluster.local
```

The certificate is mounted at:

```text
/etc/backstage/argocd-ca/argocd-server.crt
```

Regenerate the GitOps ConfigMap after cluster creation, Argo CD reinstall, or certificate rotation:

```bash
scripts/backstage/update-argocd-ca-configmap.sh
```

Sync in this order:

```bash
argocd app sync backstage-platform-resources
argocd app wait backstage-platform-resources --sync --health --timeout 300
argocd app sync backstage
kubectl -n backstage rollout status deployment/backstage --timeout=300s
```

## Application source

The custom Backstage source overlay is kept at:

```text
backstage-app/
```

## Documentation

- `docs/SETUP-FROM-SCRATCH.md`
- `docs/DEVELOPER-DEMO-WORKFLOW.md`
- `docs/BACKSTAGE-ARGOCD-INTEGRATION.md`
- `docs/IDP-MIGRATION-RUNBOOK.md`
- `docs/demo-runbook.md`

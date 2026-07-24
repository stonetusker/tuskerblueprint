# Backstage platform service

This directory contains the Kubernetes deployment configuration and runtime-access resources for the TuskerBlueprint developer portal.

## Active deployment files

- `values/development.yaml`: current safe stock-image deployment.
- `values/development-idp.yaml`: plugin-enabled custom-image deployment.
- `values/development-stock.yaml`: rollback copy of the original working values.
- `manifests/`: read-only ServiceAccount, RBAC, and NetworkPolicy applied by Argo CD.
- `examples/`: External Secret contracts that are intentionally not applied until a real secret store is selected.

## Application source

The custom Backstage source overlay is kept at:

```text
backstage-app/
```

The image workflow is:

```text
.github/workflows/backstage-image.yml
```

## Migration

Follow:

```text
docs/IDP-MIGRATION-RUNBOOK.md
```

Do not change the active Argo CD value file to `development-idp.yaml` until the custom image and required Secrets exist.

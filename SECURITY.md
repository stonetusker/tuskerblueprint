# Security policy

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability or exposed credential. Contact StoneTusker Systems through a private company channel and include the affected component, reproduction information, impact, and any proposed mitigation.

## Supported scope

This repository is a reference implementation. The `main` branch is the supported portfolio baseline. Generated services and environment-specific deployments must define their own support and patching policies.

## Secret handling

Never commit passwords, tokens, private keys, Kubernetes Secret values, Terraform state, or live cluster exports. Use the runtime scripts or an approved External Secrets provider.

## Rotation

When a credential may have entered Git history, rotate it first, then remove it from every branch and tag. Deleting only the latest file is not sufficient.

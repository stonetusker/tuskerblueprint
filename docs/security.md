# Security

## Credential separation

Use separate credentials for:

- Backstage read access to the private GitHub repository
- GitHub OAuth login
- Software Template repository creation and pull requests
- Backstage read-only access to Argo CD
- Backstage read-only access to Kubernetes

Do not reuse the Argo CD repository deploy key in Backstage.

## Repository controls

The repository must not contain:

- Kubernetes Secret values
- GitHub tokens
- Argo CD tokens
- OAuth client secrets
- TLS private keys
- SSH private keys
- Terraform state
- Runtime cluster exports

## Runtime controls

- Backstage receives read-only Kubernetes RBAC.
- Argo CD uses a dedicated read-only Backstage account.
- The Backstage container runs as non-root where supported.
- NetworkPolicy restricts ingress to the Backstage service and allows required egress.
- Software Template write credentials should be scoped to the StoneTusker organization and audited.

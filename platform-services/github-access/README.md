# GitHub and GHCR access

This component keeps GitHub credentials out of Git while allowing TuskerBlueprint to operate with public or private GitHub repositories and public or private GHCR packages.

The runtime source Secret `platform-secrets/ghcr-pull-credentials` is created by `scripts/backstage/configure-github-platform-secret.sh`. The cluster-scoped Kubernetes provider `kubernetes-platform-secrets` allows approved `ExternalSecret` resources to copy only that named source credential into their own namespace as `ghcr-pull-secret`.

Application repositories and the Backstage runtime each declare an `ExternalSecret`. Their ServiceAccounts reference the generated `kubernetes.io/dockerconfigjson` Secret. Argo CD repository credentials are stored separately in `argocd/argocd-github-org-repo-creds`, and Backstage credentials remain in `backstage/backstage-github-credentials`.

No credential value or Kubernetes `Secret` manifest is committed to this repository.

## Security boundary

The source Secret is name-scoped through RBAC: `platform-secret-reader` can read only `platform-secrets/ghcr-pull-credentials`. Application repositories can declare an `ExternalSecret`, but they never contain the credential value. Use a GHCR PAT classic with only `read:packages`, enable Kubernetes encryption at rest for production, and rotate the source Secret without changing application manifests.

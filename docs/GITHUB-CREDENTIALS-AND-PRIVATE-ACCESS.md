# GitHub credentials and private access

TuskerBlueprint supports both public and private application repositories and both public and private GHCR packages without committing credentials.

## Credential separation

| Kubernetes Secret | Namespace | Purpose |
| --- | --- | --- |
| `backstage-github-credentials` | `backstage` | Backstage GitHub integration, repository creation, collaborator management and pull requests |
| `argocd-github-org-repo-creds` | `argocd` | Argo CD HTTPS access to private repositories under `https://github.com/stonetusker` |
| `ghcr-pull-credentials` | `platform-secrets` | Central source Docker config used to pull private GHCR images |
| `ghcr-pull-secret` | workload namespaces and `backstage` | Namespace-local pull Secret created by External Secrets Operator |

Create or rotate the runtime credentials:

```bash
scripts/backstage/configure-github-platform-secret.sh
```

The script never writes credentials to Git. It uses restrictive temporary files (`umask 077`) only while creating Kubernetes Secrets and deletes them automatically. It prompts for:

- a Backstage/scaffolder GitHub credential with repository-provisioning permissions;
- an Argo CD repository-read credential, or explicit reuse of the platform credential;
- a separate **personal access token (classic)** for GHCR with `read:packages` and access to the private packages that the cluster must pull.

The GHCR credential is deliberately required separately because GitHub Container Registry package installation uses a PAT classic outside GitHub Actions. For non-interactive operation, set `GITHUB_USERNAME`, `GITHUB_EMAIL`, `GITHUB_PLATFORM_TOKEN`, `ARGOCD_GITHUB_TOKEN`, and `GHCR_PULL_TOKEN` in the invoking shell. Do not place them in repository files.

## Secret distribution

`platform-services/github-access/manifests/cluster-secret-store.yaml` exposes only the named source credential through a least-privilege Kubernetes provider. Its `conditions` allow use only from the approved Backstage namespaces or namespaces labelled `platform.stonetusker.com/workload=true`. Each generated application repository includes `deploy/base/external-secret.yaml`, and Backstage includes `platform-services/backstage/manifests/ghcr-pull-external-secret.yaml`.

Argo CD applies the `ExternalSecret` before the Deployment by sync wave. External Secrets Operator creates a namespace-local `ghcr-pull-secret`, and the workload or Backstage ServiceAccount references it. The `platform-secrets` namespace is dedicated to source credentials and must not be used for ordinary application Secrets.

## Visibility behavior

- **Public repository + public package:** credentials are still valid but not required by GitHub.
- **Public repository + private package:** Argo CD reads Git anonymously; Kubernetes authenticates to GHCR.
- **Private repository + public package:** Argo CD authenticates to Git; Kubernetes can still use the pull Secret.
- **Private repository + private package:** both Argo CD and Kubernetes authenticate.

## Verification

```bash
scripts/backstage/verify-github-platform-secrets.sh

kubectl -n demo-service-development get secret ghcr-pull-secret
kubectl -n demo-service-development get serviceaccount demo-service -o yaml
kubectl -n argocd get secret argocd-github-org-repo-creds
```

Do not print or decode credential values during a demo.

Kubernetes Secret values are base64-encoded API data, not automatically encrypted storage. For a production cluster, enable Kubernetes Secret encryption at rest, restrict namespace access with RBAC, rotate credentials regularly, and prefer separate machine identities for Backstage, Argo CD and GHCR.

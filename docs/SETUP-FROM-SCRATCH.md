# Setup from scratch

## 1. Prepare GitHub

Create the Stonetusker GitHub OAuth application used for sign-in. Prepare credentials with least privilege:

- Backstage/scaffolder token: create repositories, manage collaborators and open pull requests in `stonetusker`.
- Argo CD token: read repository contents for private service repositories. It may explicitly reuse the platform token for a small demo, but a separate read-only machine credential is preferred.
- GHCR pull token: a separate PAT classic with `read:packages` and access to every private package the cluster must pull.

Repositories and packages may remain private.

## 2. Install the platform

Bootstrap Kubernetes and Argo CD using the documented infrastructure path, then sync `platform-root`.

## 3. Create Kubernetes-only GitHub credentials

```bash
scripts/backstage/configure-github-oauth-secret.sh
scripts/backstage/configure-github-platform-secret.sh
scripts/backstage/configure-argocd-readonly.sh
```

The second command creates or rotates:

```text
backstage/backstage-github-credentials
argocd/argocd-github-org-repo-creds
platform-secrets/ghcr-pull-credentials
```

No Secret YAML is written to the repository. The script uses restrictive temporary files only during `kubectl` Secret creation and deletes them on exit.

## 4. Sync secret distribution and Backstage

```bash
argocd app sync external-secrets
argocd app sync github-access
argocd app sync backstage-platform-resources
argocd app sync backstage
```

Verify:

```bash
scripts/backstage/verify-github-platform-secrets.sh
```

## 5. Publish the first Backstage image

Push a Backstage source change, allow the workflow to build and publish the immutable image, then merge the generated one-file release PR. The Backstage ServiceAccount uses `ghcr-pull-secret`, so the package can remain private.

## 6. Create a service through Backstage

1. Sign in.
2. Open **Create → Tusker Service**.
3. Choose public or private repository visibility.
4. Enter the service, owner, system and developer username.
5. Run the template.

Backstage creates the repository, grants developer access, registers the catalog entity and opens the GitOps onboarding PR.

## 7. Complete the first service release

1. Confirm service CI publishes an immutable GHCR image.
2. Merge the one-file release PR in the service repository.
3. Merge the platform onboarding PR.
4. Confirm the workload namespace receives `ghcr-pull-secret`.
5. Wait for Argo CD to become `Synced` and `Healthy`.

No package visibility change is required.

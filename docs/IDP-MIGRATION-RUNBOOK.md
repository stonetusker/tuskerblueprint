# Backstage IDP migration runbook

This runbook moves the currently healthy stock Backstage deployment to the plugin-enabled TuskerBlueprint IDP without losing the rollback path.

## Current safe state

The Argo CD Application uses:

```text
platform-services/backstage/values/development.yaml
```

The custom image configuration is staged at:

```text
platform-services/backstage/values/development-idp.yaml
```

Do not switch the Argo CD Application until the custom image exists and all required Secrets are present.

## 1. Push the repository changes

Commit the repository on a feature branch and open a pull request. Confirm the following workflows pass:

- **GitHub UI → Actions → IDP Validation**
- **GitHub UI → Actions → Backstage IDP Image**

The image workflow publishes:

```text
ghcr.io/stonetusker/tuskerblueprint-backstage:main
```

## 2. Configure GitHub OAuth

### GitHub UI action

```text
GitHub
→ Settings
→ Developer settings
→ OAuth Apps
→ New OAuth App
```

Use:

```text
Application name: TuskerBlueprint Backstage
Homepage URL: http://localhost:7007
Authorization callback URL: http://localhost:7007/api/auth/github/handler/frame
```

Then run from the repository root:

```bash
scripts/backstage/configure-github-oauth-secret.sh
```

This creates or updates:

```text
Kubernetes Secret: backstage/backstage-auth-secrets
```

The user entity used by the sign-in resolver is:

```text
catalog/users/subeesh.yaml
```

Change `metadata.name` in that file if your GitHub username is not `subeesh`.

## 3. Configure the read-only Argo CD account

Keep this port-forward running:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Run:

```bash
scripts/backstage/configure-argocd-readonly.sh
```

This updates:

```text
Kubernetes ConfigMap: argocd/argocd-cm
Kubernetes ConfigMap: argocd/argocd-rbac-cm
Kubernetes Secret: backstage/backstage-argocd-credentials
```

The repository contains no token value.

## 4. Confirm the private GitHub catalog Secret

The existing Secret must contain:

```text
Kubernetes Secret: backstage/backstage-github-credentials
Key: GITHUB_TOKEN
```

Verify without printing the value:

```bash
kubectl get secret backstage-github-credentials -n backstage
```

## 5. Deploy Backstage runtime access resources

The root Application will create:

```text
Argo CD Application: backstage-platform-resources
```

It applies:

```text
platform-services/backstage/manifests/
```

Verify:

```bash
kubectl get application backstage-platform-resources -n argocd
kubectl get serviceaccount backstage -n backstage
kubectl get clusterrole backstage-kubernetes-reader
```

## 6. Switch to the custom IDP values

Run:

```bash
scripts/backstage/switch-to-idp-values.sh
```

This changes only:

```text
gitops/applications/platform/developer-platform/backstage/application-development.yaml
```

Review:

```bash
git diff -- gitops/applications/platform/developer-platform/backstage/application-development.yaml
```

Commit and push the change.

## 7. Watch the rollout

### Argo CD UI action

```text
Argo CD UI
→ Applications
→ backstage
→ Refresh
→ Hard Refresh
→ Resource Tree
```

Terminal checks:

```bash
kubectl get application backstage -n argocd -w
kubectl get pods -n backstage -w
kubectl logs -n backstage deployment/backstage --tail=300
```

Expected state:

```text
backstage  Synced  Healthy
```

## 8. Verify Backstage IDP features

Keep the Backstage port-forward running:

```bash
kubectl port-forward -n backstage svc/backstage 7007:7007
```

### Backstage UI actions

```text
Backstage → Sign in with GitHub
Backstage → Catalog
Backstage → Docs
Backstage → APIs
Backstage → Create → Tusker Service
Backstage → Catalog → TuskerBlueprint Demo Service → Kubernetes
Backstage → Catalog → TuskerBlueprint Demo Service → Overview → Argo CD
```

## 9. Deploy the demo service

The repository adds:

```text
Argo CD Application: demo-service-development
```

Verify:

```bash
kubectl get application demo-service-development -n argocd
kubectl get pods -n demo-service-development
```

## 10. Run the customer demo

```bash
scripts/demo/preflight.sh
scripts/demo/status.sh
```

Follow:

```text
docs/demo-runbook.md
```

## Rollback

Run:

```bash
scripts/backstage/rollback-to-stock-values.sh
```

Commit and push the resulting change. Argo CD will return to:

```text
platform-services/backstage/values/development.yaml
```

## Production follow-up

Before calling the portal production-ready:

- Commit a reviewed generated Backstage application and lockfile instead of bootstrapping on every build.
- Replace local TechDocs publishing with object storage.
- Use an external PostgreSQL database with tested backups.
- Replace broad platform-administrator permissions with a reviewed Backstage permission policy.
- Use HTTPS hostnames instead of localhost links.
- Store all runtime credentials in External Secrets or another approved secret manager.
- Pin the custom image by immutable digest for staging and production.

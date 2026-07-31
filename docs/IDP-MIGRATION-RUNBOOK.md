# Backstage IDP deployment and rollback runbook

This runbook deploys the plugin-enabled TuskerBlueprint Backstage image and preserves the stock-image rollback path.

## Current development state

The development Argo CD Application currently uses:

```text
platform-services/backstage/values/development-idp.yaml
```

The custom image includes GitHub authentication, catalog, TechDocs, Kubernetes, Argo CD, API, and GitHub Actions integrations.

The rollback values file remains:

```text
platform-services/backstage/values/development.yaml
```

The platform-resource Application reconciles:

```text
platform-services/backstage/manifests/
```

This includes the ServiceAccount, read-only RBAC, NetworkPolicy, and Argo CD public CA ConfigMap.

## Preconditions

Confirm:

- the custom image tag in `platform-services/backstage/values/development-idp.yaml` exists in GHCR;
- `backstage-github-credentials` exists;
- `backstage-auth-secrets` exists;
- `backstage-argocd-credentials` exists;
- `backstage-argocd-ca` matches the live Argo CD certificate;
- the repository validator passes.

```bash
kubectl -n backstage get secret \
  backstage-github-credentials \
  backstage-auth-secrets \
  backstage-argocd-credentials

kubectl -n backstage get configmap backstage-argocd-ca

PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py
```

For a completely new environment, follow [TuskerBlueprint setup from scratch](SETUP-FROM-SCRATCH.md) first.

## Configure GitHub OAuth

### GitHub UI steps

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

Then run:

```bash
scripts/backstage/configure-github-oauth-secret.sh
```

The sign-in resolver expects the GitHub username to match the Backstage User entity name. Review:

```text
catalog/users/subeesh.yaml
```

## Configure read-only Argo CD access

Start the Argo CD port-forward:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Log in with the CLI and run:

```bash
scripts/backstage/configure-argocd-readonly.sh
```

This creates or updates:

```text
argocd/argocd-cm
argocd/argocd-rbac-cm
backstage/backstage-argocd-credentials
```

## Configure Argo CD certificate trust

Generate the CA ConfigMap from the active Argo CD server certificate:

```bash
scripts/backstage/update-argocd-ca-configmap.sh
```

Validate, commit, and push:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py

git add platform-services/backstage/manifests/argocd-ca-configmap.yaml
git commit -m 'fix(backstage): trust Argo CD server certificate'
git push origin main
```

See [Backstage and Argo CD integration](BACKSTAGE-ARGOCD-INTEGRATION.md) for certificate rotation and troubleshooting.

## Validate Helm rendering

```bash
helm template backstage backstage/backstage \
  --version 1.10.0 \
  --namespace backstage \
  --values platform-services/backstage/values/development-idp.yaml \
  >/tmp/backstage-rendered.yaml

grep -A12 -B5 \
  -E 'NODE_EXTRA_CA_CERTS|backstage-argocd-ca|/etc/backstage/argocd-ca' \
  /tmp/backstage-rendered.yaml
```

The rendered Deployment must include:

- `NODE_EXTRA_CA_CERTS`;
- the `backstage-argocd-ca` ConfigMap volume;
- the `/etc/backstage/argocd-ca` volume mount.

## Reconcile in dependency order

```bash
argocd app get platform-root --refresh

argocd app sync backstage-platform-resources
argocd app wait backstage-platform-resources \
  --sync --health --timeout 300

argocd app get backstage --hard-refresh
argocd app sync backstage
kubectl -n backstage rollout status deployment/backstage --timeout=300s
```

Expected:

```text
backstage-platform-resources   Synced   Healthy
backstage                      Synced   Healthy
```

## Verify the running deployment

```bash
kubectl -n backstage exec deployment/backstage -- sh -lc '
  echo "NODE_EXTRA_CA_CERTS=${NODE_EXTRA_CA_CERTS}"
  ls -l /etc/backstage/argocd-ca/
  test -s /etc/backstage/argocd-ca/argocd-server.crt
'
```

Test Node.js TLS validation:

```bash
kubectl -n backstage exec deployment/backstage -- node -e '
const https = require("https");
const request = https.get(
  "https://argocd-server.argocd.svc.cluster.local/api/v1/applications/demo-service-development",
  response => {
    console.log(`HTTP status: ${response.statusCode}`);
    response.resume();
  },
);
request.on("error", error => {
  console.error(error);
  process.exit(1);
});
'
```

Expected without a token:

```text
HTTP status: 401
```

## Verify Backstage features

Start the Backstage port-forward:

```bash
kubectl -n backstage port-forward svc/backstage 7007:7007
```

Open:

```text
http://localhost:7007
```

### Backstage UI steps

```text
Backstage
→ Sign in with GitHub
→ Catalog
→ Stonetusker Customer Notification API
```

Verify:

- Overview;
- Docs;
- APIs;
- Kubernetes;
- Argo CD;
- Create → Tusker Service.

Check the Argo CD plugin logs:

```bash
kubectl -n backstage logs deployment/backstage --since=3m \
  | grep -Ei 'argocd|certificate|self-signed|altname|unauthorized|forbidden|error|failed' \
  || true
```

Successful Argo CD requests return `200` or cache response `304`.

## Roll back to the stock image

Run:

```bash
scripts/backstage/rollback-to-stock-values.sh
```

This updates:

```text
gitops/applications/platform/developer-platform/backstage/application-development.yaml
```

Review and commit:

```bash
git diff -- gitops/applications/platform/developer-platform/backstage/application-development.yaml
git add gitops/applications/platform/developer-platform/backstage/application-development.yaml
git commit -m 'rollback(backstage): use stock image values'
git push origin main
```

Then:

```bash
argocd app get backstage --hard-refresh
argocd app sync backstage
kubectl -n backstage rollout status deployment/backstage --timeout=300s
```

The platform-resource Application can remain active because its RBAC and NetworkPolicy are safe, read-only runtime resources.

## Production follow-up

Before calling the portal production-ready:

- use an HTTPS hostname instead of localhost;
- issue the Argo CD server certificate through cert-manager or a managed PKI;
- use external PostgreSQL with tested backups;
- publish TechDocs to object storage;
- source Secrets from an approved external secret store;
- pin images by immutable digest or reviewed immutable tag;
- implement reviewed Backstage permission policies;
- monitor certificate and token expiry;
- test both Git rollback and certificate rotation.

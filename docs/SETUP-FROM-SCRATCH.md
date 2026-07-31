# TuskerBlueprint setup from scratch

This is the canonical installation guide for rebuilding the TuskerBlueprint development platform on a new Kubernetes host. All paths are relative to the repository root.

## 1. What this guide builds

The development environment contains:

- a single-node k3s cluster on Ubuntu 24.04;
- Argo CD as the GitOps control plane;
- Traefik, cert-manager, External Secrets, Doppler integration, and Kyverno;
- Prometheus, Grafana, Loki, and optional Alloy components;
- the custom Backstage developer portal;
- the `demo-service-development` reference workload;
- read-only Backstage access to Kubernetes and Argo CD.

Local browser access uses port-forwarding:

| Service | Command | Browser URL |
| --- | --- | --- |
| Backstage | `kubectl -n backstage port-forward svc/backstage 7007:7007` | `http://localhost:7007` |
| Argo CD | `kubectl -n argocd port-forward svc/argocd-server 8080:443` | `https://localhost:8080` |
| Demo service | `kubectl -n demo-service-development port-forward svc/demo-service 8081:80` | `http://localhost:8081` |

Backstage does not use the laptop's Argo CD port-forward. The Backstage pod connects internally to `https://argocd-server.argocd.svc.cluster.local`.

## 2. Current automation boundary

Read this before provisioning:

- `infrastructure/terraform/` currently pins providers but does not provision a cloud VM. Create the Ubuntu 24.04 host with your cloud provider, or extend Terraform before using it as a provisioning layer.
- `infrastructure/ansible/playbooks/site.yml` does not currently install k3s because `infrastructure/ansible/playbooks/kubernetes.yml` is a placeholder.
- Use the dedicated playbooks in this guide: `validate.yml`, `bootstrap.yml`, `k3s.yml`, and `argocd.yml`.
- The development inventory contains an example host address. Replace it before running Ansible.
- The Backstage image and demo-service image are pulled from GHCR. A fork must publish its own images and update the corresponding repository and immutable tags.

## 3. Prerequisites

### Control machine

Install:

- Git;
- Python 3.11 or newer;
- Ansible Core;
- `kubectl`;
- Helm;
- the Argo CD CLI;
- OpenSSL;
- SSH client tools.

On macOS with Homebrew:

```bash
brew install git python ansible kubectl helm argocd openssl
```

Create a Python environment and install the modules used by repository validation and the Ansible Kubernetes collection:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install 'PyYAML==6.0.2' kubernetes
```

Install the pinned Ansible collections:

```bash
ansible-galaxy collection install \
  -r infrastructure/ansible/collections/requirements.yml
```

### Kubernetes host

Prepare one Ubuntu 24.04 host with:

- SSH access from the control machine;
- a user that can run passwordless `sudo`, or root SSH for initial bootstrap;
- inbound TCP 22 for administration;
- sufficient CPU, memory, and storage for the selected platform services;
- outbound HTTPS access for packages, Helm charts, GitHub, and container images.

Do not expose the Kubernetes API, Backstage, Grafana, or Argo CD broadly without firewall, TLS, identity, and access-control review.

## 4. Clone and validate the source

```bash
git clone git@github.com:stonetusker/tuskerblueprint.git
cd tuskerblueprint
export TUSKER_REPO_ROOT="$(pwd)"
```

Validate the repository before touching infrastructure:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py
find scripts -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
git diff --check
```

Expected final line:

```text
TuskerBlueprint IDP validation passed
```

The `commonLabels` deprecation warning is non-blocking. Convert remaining Kustomizations to `labels` during normal cleanup.

## 5. Configure the Ansible inventory

Edit:

```text
infrastructure/ansible/inventories/dev/hosts.yml
```

Replace the example address and add the SSH user appropriate for the new host. Example:

```yaml
all:
  children:
    k3s_servers:
      hosts:
        vps8:
          ansible_host: 203.0.113.10
          ansible_user: ubuntu
    platform:
      children:
        k3s_servers:
```

Never commit private keys or passwords. Supply the SSH key on the command line or through your SSH agent.

Check connectivity:

```bash
cd infrastructure/ansible
ansible all -m ping --private-key ~/.ssh/tuskerblueprint-host
```

## 6. Validate and bootstrap the host

The validation playbook requires Ubuntu 24.04:

```bash
ansible-playbook playbooks/validate.yml \
  --private-key ~/.ssh/tuskerblueprint-host
```

Apply common packages and the platform user:

```bash
ansible-playbook playbooks/bootstrap.yml \
  --private-key ~/.ssh/tuskerblueprint-host
```

Install k3s with the dedicated playbook:

```bash
ansible-playbook playbooks/k3s.yml \
  --private-key ~/.ssh/tuskerblueprint-host
```

The current role installs the version pinned in:

```text
infrastructure/ansible/roles/k3s/defaults/main.yml
```

It disables the bundled Traefik and ServiceLB because the GitOps layer manages the platform ingress controller.

## 7. Copy the kubeconfig to the control machine

Set the host and SSH user locally:

```bash
export TUSKER_HOST='203.0.113.10'
export TUSKER_SSH_USER='ubuntu'
```

Copy the k3s kubeconfig without exposing it in Git:

```bash
mkdir -p ~/.kube
ssh -i ~/.ssh/tuskerblueprint-host \
  "${TUSKER_SSH_USER}@${TUSKER_HOST}" \
  'sudo cat /etc/rancher/k3s/k3s.yaml' \
  > ~/.kube/tuskerblueprint.yaml

chmod 600 ~/.kube/tuskerblueprint.yaml
```

Replace the loopback Kubernetes API address with the host address:

```bash
python3 - <<'PY2'
from pathlib import Path
import os

path = Path.home() / '.kube' / 'tuskerblueprint.yaml'
host = os.environ['TUSKER_HOST']
text = path.read_text().replace('https://127.0.0.1:6443', f'https://{host}:6443')
path.write_text(text)
PY2
```

Use this kubeconfig for the remaining steps:

```bash
export KUBECONFIG="$HOME/.kube/tuskerblueprint.yaml"
kubectl get nodes -o wide
```

A production deployment should use a private network or secure tunnel for the Kubernetes API rather than exposing port 6443 to the public internet.

## 8. Create the Argo CD repository deploy key

The Argo CD bootstrap role expects the private key at:

```text
~/.ssh/tuskerblueprint-argocd
```

Generate a dedicated read-only deploy key:

```bash
ssh-keygen -t ed25519 \
  -C 'argocd@tuskerblueprint' \
  -f ~/.ssh/tuskerblueprint-argocd
```

### GitHub UI steps

```text
GitHub repository
→ Settings
→ Deploy keys
→ Add deploy key
```

Use the contents of:

```text
~/.ssh/tuskerblueprint-argocd.pub
```

Do not enable write access. The private key remains only on the control machine and is copied into a Kubernetes Secret by the Ansible role without being written to the repository.

## 9. Bootstrap Argo CD and the root Application

From `infrastructure/ansible`:

```bash
ansible-playbook playbooks/argocd.yml \
  --private-key ~/.ssh/tuskerblueprint-host \
  -e "kubeconfig=${KUBECONFIG}"
```

This playbook:

1. installs the pinned Argo CD Helm chart;
2. registers `git@github.com:stonetusker/tuskerblueprint.git` using the deploy key;
3. applies the `platform-root` Application;
4. points it at `gitops/environments/development`.

Verify:

```bash
kubectl -n argocd get pods
kubectl -n argocd get applications.argoproj.io
kubectl -n argocd get application platform-root \
  -o custom-columns='NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status'
```

Expected root state:

```text
platform-root   Synced   Healthy
```

Some child Applications may remain unhealthy until image-pull credentials and Backstage runtime Secrets are created.

Return to the repository root for all remaining commands:

```bash
cd "${TUSKER_REPO_ROOT}"
```

## 10. Access Argo CD and log in

Start a dedicated terminal session:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Open:

```text
https://localhost:8080
```

Retrieve the initial administrator password without writing it to disk:

```bash
ARGOCD_ADMIN_PASSWORD="$(
  kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath='{.data.password}' | base64 --decode
)"
```

Log in with the CLI:

```bash
argocd login localhost:8080 \
  --username admin \
  --password "${ARGOCD_ADMIN_PASSWORD}" \
  --insecure \
  --grpc-web

unset ARGOCD_ADMIN_PASSWORD
```

Rotate or remove the initial administrator credential after normal identity and break-glass access are configured.

## 11. Configure Backstage runtime Secrets

Create the namespace first:

```bash
kubectl create namespace backstage --dry-run=client -o yaml | kubectl apply -f -
```

### 11.1 GitHub platform and scaffolder token

Create a dedicated GitHub platform credential for Backstage. The current integration reads it from `GITHUB_TOKEN` and uses it for catalog access and golden-path provisioning.

For the complete developer demo, the platform identity must be able to:

- read the TuskerBlueprint repository;
- create public repositories under the `stonetusker` organization;
- add the organization member `subeeshlearn` as a collaborator;
- write GitHub Actions workflow files;
- create branches and pull requests in `stonetusker/tuskerblueprint`.

Create or update the Secret interactively:

```bash
scripts/backstage/configure-github-platform-secret.sh
```

The script creates `backstage/backstage-github-credentials` with `GITHUB_TOKEN` and `GITHUB_SCAFFOLDER_TOKEN` without printing either value.

Do not reuse the Argo CD deploy key or OAuth client secret.

### 11.2 GitHub OAuth

#### GitHub UI steps

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

Create the Kubernetes Secret:

```bash
cd "${TUSKER_REPO_ROOT}"
scripts/backstage/configure-github-oauth-secret.sh
```

The script creates `backstage/backstage-auth-secrets` with:

- `AUTH_GITHUB_CLIENT_ID`;
- `AUTH_GITHUB_CLIENT_SECRET`;
- `BACKEND_SECRET`.

The configured sign-in resolver expects the GitHub username to match the Backstage User entity name. Review:

```text
catalog/users/subeesh.yaml
catalog/users/subeeshlearn.yaml
```

### 11.3 Read-only Argo CD account

Keep the Argo CD port-forward running and confirm the CLI is logged in. Then run:

```bash
scripts/backstage/configure-argocd-readonly.sh
```

The script creates a dedicated `backstage` Argo CD account, applies read-only RBAC, generates a token, and stores it in:

```text
backstage/backstage-argocd-credentials
```

Verify Secret names without printing values:

```bash
kubectl -n backstage get secret \
  backstage-github-credentials \
  backstage-auth-secrets \
  backstage-argocd-credentials
```

## 12. Trust the Argo CD server certificate

Each new Argo CD installation creates its own server certificate. The public certificate committed in `platform-services/backstage/manifests/argocd-ca-configmap.yaml` is cluster-specific and must be regenerated for a new cluster or after certificate rotation.

Run:

```bash
scripts/backstage/update-argocd-ca-configmap.sh
```

The script:

- finds the active Argo CD TLS Secret;
- extracts only `tls.crt`, never `tls.key`;
- validates the certificate;
- confirms the internal DNS SAN `argocd-server.argocd.svc.cluster.local`;
- rewrites `platform-services/backstage/manifests/argocd-ca-configmap.yaml`.

Review and validate:

```bash
git diff -- platform-services/backstage/manifests/argocd-ca-configmap.yaml
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py
kubectl kustomize platform-services/backstage/manifests >/tmp/backstage-platform-resources.yaml
```

Commit and push the public certificate update so Argo CD can reconcile it:

```bash
git add platform-services/backstage/manifests/argocd-ca-configmap.yaml
git commit -m 'fix(backstage): trust development Argo CD certificate'
git push origin main
```

Never use `NODE_TLS_REJECT_UNAUTHORIZED=0`. It disables TLS verification globally for the Backstage Node.js process.

See [Backstage and Argo CD integration](BACKSTAGE-ARGOCD-INTEGRATION.md) for the full trust model and rotation procedure.

## 13. Confirm the custom Backstage image

The development Application uses:

```text
platform-services/backstage/values/development-idp.yaml
```

The image is pinned under:

```yaml
backstage:
  image:
    registry: ghcr.io
    repository: stonetusker/tuskerblueprint-backstage
    tag: '<immutable-git-sha>'
```

For a fork:

1. build and publish the custom image from `backstage-app/` using your CI process;
2. update `repository` and `tag` in `platform-services/backstage/values/development-idp.yaml`;
3. keep the tag immutable;
4. commit and push before syncing Backstage.

## 14. Configure private GHCR pulls

The demo workload references `ghcr-pull-secret`. Create it for a private package:

```bash
export GHCR_USERNAME='<github-user>'
export GHCR_TOKEN='<token-with-read-packages>'
export GHCR_EMAIL='<email>'

scripts/demo/configure-ghcr-pull-secret.sh

unset GHCR_TOKEN
```

Verify:

```bash
kubectl -n demo-service-development get secret ghcr-pull-secret
```

## 15. Reconcile platform resources before Backstage

Refresh the root Application:

```bash
argocd app get platform-root --refresh
```

Sync and wait for the Backstage platform resources first:

```bash
argocd app sync backstage-platform-resources
argocd app wait backstage-platform-resources \
  --sync --health --timeout 300
```

Verify the CA ConfigMap and read-only ServiceAccount:

```bash
kubectl -n backstage get configmap backstage-argocd-ca
kubectl -n backstage get serviceaccount backstage
kubectl get clusterrole backstage-kubernetes-reader
```

Then refresh and sync the Backstage Helm Application:

```bash
argocd app get backstage --hard-refresh
argocd app sync backstage
kubectl -n backstage rollout status deployment/backstage --timeout=300s
```

## 16. Verify Backstage certificate trust

Confirm the live Deployment contains the environment variable:

```bash
kubectl -n backstage get deployment backstage \
  -o jsonpath='{range .spec.template.spec.containers[*].env[*]}{.name}={.value}{"\n"}{end}' \
  | grep NODE_EXTRA_CA_CERTS
```

Expected:

```text
NODE_EXTRA_CA_CERTS=/etc/backstage/argocd-ca/argocd-server.crt
```

Confirm the volume and mount:

```bash
kubectl -n backstage get deployment backstage \
  -o jsonpath='{range .spec.template.spec.volumes[*]}{.name}{" => "}{.configMap.name}{"\n"}{end}' \
  | grep argocd-ca

kubectl -n backstage get deployment backstage \
  -o jsonpath='{range .spec.template.spec.containers[*].volumeMounts[*]}{.name}{" => "}{.mountPath}{"\n"}{end}' \
  | grep argocd-ca
```

Expected:

```text
argocd-ca => backstage-argocd-ca
argocd-ca => /etc/backstage/argocd-ca
```

Verify inside the pod:

```bash
kubectl -n backstage exec deployment/backstage -- sh -lc '
  echo "NODE_EXTRA_CA_CERTS=${NODE_EXTRA_CA_CERTS}"
  ls -l /etc/backstage/argocd-ca/
  test -s /etc/backstage/argocd-ca/argocd-server.crt
'
```

Test Node.js TLS validation without an Authorization header:

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

Expected:

```text
HTTP status: 401
```

The `401` is correct because this direct test intentionally omits the token. It proves DNS, networking, hostname validation, and certificate trust are working.

## 17. Access and verify the portal

Start a separate Backstage port-forward:

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

Verify these tabs:

- Overview;
- Docs;
- APIs;
- Kubernetes;
- Argo CD.

The Argo CD tab should show `demo-service-development` as `Synced` and `Healthy`.

Check fresh plugin logs:

```bash
kubectl -n backstage logs deployment/backstage --since=3m \
  | grep -Ei 'argocd|certificate|self-signed|altname|unauthorized|forbidden|error|failed' \
  || true
```

Successful plugin requests return HTTP `200` or cache response `304`. There should be no self-signed-certificate or hostname-mismatch error.

## 18. Verify the complete platform

```bash
kubectl -n argocd get applications.argoproj.io \
  -o custom-columns='NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status'

scripts/demo/status.sh
scripts/demo/preflight.sh
```

Check the demo API:

```bash
kubectl -n demo-service-development port-forward svc/demo-service 8081:80
```

From another terminal:

```bash
curl -i http://127.0.0.1:8081/
curl -i http://127.0.0.1:8081/healthz
curl -i http://127.0.0.1:8081/readyz
curl -sS http://127.0.0.1:8081/metrics | head
```

## 19. Common failures

### Backstage pod reports a missing ConfigMap

Cause: Backstage was synced before `backstage-platform-resources`.

Fix:

```bash
argocd app sync backstage-platform-resources
argocd app sync backstage
```

### `NODE_EXTRA_CA_CERTS` is empty

Cause: `extraEnvVars`, `extraVolumes`, or `extraVolumeMounts` were placed under the top-level `resources:` block instead of under `backstage:`.

Correct structure:

```yaml
backstage:
  extraEnvVars: []
  extraVolumes: []
  extraVolumeMounts: []

resources:
  requests: {}
  limits: {}
```

Render before committing:

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

### Backstage reports `self-signed certificate`

Regenerate the CA ConfigMap from the live Argo CD certificate, commit it, sync `backstage-platform-resources`, and then restart Backstage.

### Backstage reports hostname mismatch

The certificate must include:

```text
DNS:argocd-server.argocd.svc.cluster.local
```

Reissue the Argo CD server certificate with these SANs:

```text
argocd-server
argocd-server.argocd
argocd-server.argocd.svc
argocd-server.argocd.svc.cluster.local
```

### Direct curl returns `404` for `/api/v1/version`

That endpoint is not a reliable health test for this installation. Test the same application endpoint used by Backstage. A no-token request should return `401`.

### Argo CD Application is healthy but UI link shows `argocd.example.com`

That URL is the Argo CD configured external URL. For the local demonstration, use the port-forward URL `https://localhost:8080`.

## 20. Teardown and rollback

GitOps changes should be rolled back through Git:

```bash
git revert <commit>
git push origin main
```

To return Backstage to the stock values file:

```bash
scripts/backstage/rollback-to-stock-values.sh
git diff -- gitops/applications/platform/developer-platform/backstage/application-development.yaml
```

Commit and push the rollback. Do not make manual cluster changes the new source of truth.

# TuskerBlueprint Remote K3s Host Migration Runbook

This runbook explains how to replace the remote machine that hosts the
TuskerBlueprint Kubernetes environment while retaining the Mac laptop as the
administration and demonstration workstation.

The process rebuilds the Kubernetes platform from GitOps. It does not copy the
old K3s database or container runtime directory to the new machine.

## Current migration values

| Setting | Value |
| --- | --- |
| Administration workstation | Mac laptop |
| Remote operating system | Ubuntu Server 24.04 |
| Remote login user | `subeesh` |
| Remote machine IP address | `192.168.0.3` |
| Remote SSH target | `subeesh@192.168.0.3` |
| Local Kubernetes API tunnel | `127.0.0.1:16443` |
| Argo CD URL on the Mac | `https://localhost:8080` |
| Backstage URL on the Mac | `http://localhost:7007` |
| Grafana URL on the Mac | `http://localhost:3000` |
| Demo service URL on the Mac | `http://localhost:8081` |

For a later migration, replace `192.168.0.3` and `subeesh` throughout this
document with the address and account for the next machine.

## Architecture after the migration

| Location | Responsibilities |
| --- | --- |
| Mac laptop | Git repository, `kubectl`, Helm, Argo CD CLI, setup scripts, port-forwards and browser access |
| Remote Ubuntu machine | K3s, containerd and all Kubernetes workloads |
| GitHub | GitOps source, application repositories, Actions workflows and GHCR images |

The Kubernetes API is carried through an SSH tunnel. Port `6443` does not need
to be exposed on the local network or internet.

## What is recreated and what is not

The following state is recreated from Git:

- Argo CD Applications and projects;
- Backstage, Prometheus, Loki, Alloy and Grafana;
- External Secrets, Kyverno, cert-manager and Traefik;
- the maintained demo service;
- services registered under `gitops/generated-workloads/`.

The following state is not recreated automatically:

- Kubernetes Secret values;
- the Argo CD administrator password;
- the Argo CD server certificate;
- Prometheus history;
- Loki log history;
- uncommitted Git changes;
- data stored only in persistent volumes on the old machine.

If historical logs, metrics or application volume data are required, back up
and restore those volumes separately. For the sales demonstration, a clean
observability environment with newly generated traffic is normally preferable.

## Prerequisites

Before starting, confirm:

- the Mac can reach `192.168.0.3` on TCP port 22;
- `subeesh` can log in using an SSH key;
- `subeesh` has passwordless or interactive `sudo` permission;
- the intended TuskerBlueprint changes are committed and pushed to GitHub;
- the old machine remains available until final verification passes;
- the remote machine has at least 8 vCPUs, 16 GB RAM and 100 GB disk;
- 24 GB RAM is preferred for a stable recorded demonstration.

## Phase 1: Protect the existing desired state

### Mac terminal

Open the existing TuskerBlueprint repository:

```bash
cd /path/to/tuskerblueprint
```

Check and publish the current branch:

```bash
git status --short
git branch --show-current
git log -1 --oneline
git push
```

Do not continue if required changes exist only on the Mac.

Review services that will be recreated automatically:

```bash
find gitops/generated-workloads \
  -mindepth 2 \
  -maxdepth 2 \
  -name application.yaml \
  -print
```

If a test service is no longer required, remove its registration from
`gitops/generated-workloads/<service-name>/` through a pull request before
bootstrapping the new cluster. Deleting only its old Kubernetes namespace will
not prevent Argo CD from recreating it.

Run repository validation:

```bash
make validate
```

## Phase 2: Check connectivity to the new machine

### Mac terminal

```bash
ping -c 3 192.168.0.3
nc -vz 192.168.0.3 22
```

Connect using SSH:

```bash
ssh subeesh@192.168.0.3
```

If the IP address is private, the Mac must be on the same LAN, connected VLAN,
or VPN. If SSH cannot reach the machine, correct its bridge, VLAN, routing or
VPN configuration before continuing.

## Phase 3: Prepare Ubuntu on the remote machine

### Remote machine terminal

Confirm the operating system and resources:

```bash
cat /etc/os-release
uname -m
nproc
free -h
df -h /
```

The commands below assume Ubuntu Server 24.04 on `x86_64`.

Set the hostname and timezone:

```bash
sudo hostnamectl set-hostname tuskerblueprint
sudo timedatectl set-timezone UTC
```

Upgrade the operating system and install the small set of host dependencies:

```bash
sudo apt update
sudo apt full-upgrade -y

sudo apt install -y \
  ca-certificates \
  curl \
  jq \
  openssl \
  python3 \
  rsync \
  tmux
```

Reboot after the operating-system upgrade:

```bash
sudo reboot
```

The SSH connection will close. Reconnect from the Mac:

```bash
ssh subeesh@192.168.0.3
```

Disable swap and make the change persistent:

```bash
sudo swapoff -a
sudo cp /etc/fstab /etc/fstab.pre-tusker
sudo sed -Ei '/^[^#].*[[:space:]]swap[[:space:]]/s/^/# /' /etc/fstab
swapon --show
```

`swapon --show` should return no entries.

For this single-node environment, use the network firewall around the machine
and disable UFW on the Kubernetes host. If the machine also has a public
interface, restrict inbound SSH before disabling UFW.

```bash
sudo ufw status
sudo ufw disable
```

Do not expose ports `6443`, `3000`, `7007` or `8080`. Access is provided from
the Mac through SSH and Kubernetes port-forwarding.

## Phase 4: Install K3s on the remote machine

### Remote machine terminal

The repository currently pins K3s `v1.33.2+k3s1`. The following installation
also enables Kubernetes Secret encryption at rest and leaves the repository's
Traefik installation responsible for ingress.

```bash
curl -fsSL https://get.k3s.io -o /tmp/install-k3s.sh

sudo env \
  INSTALL_K3S_VERSION='v1.33.2+k3s1' \
  INSTALL_K3S_EXEC='server --write-kubeconfig-mode=600 --disable=servicelb --disable=traefik --secrets-encryption' \
  sh /tmp/install-k3s.sh
```

Verify K3s:

```bash
sudo systemctl is-active k3s
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl cluster-info
```

The node must report `Ready`.

Create a protected kubeconfig for the `subeesh` account:

```bash
mkdir -p "$HOME/.kube"
chmod 700 "$HOME/.kube"

sudo install \
  -m 600 \
  -o "$USER" \
  -g "$(id -gn)" \
  /etc/rancher/k3s/k3s.yaml \
  "$HOME/.kube/config"
```

Verify its ownership without printing its credentials:

```bash
ls -l "$HOME/.kube/config"
```

The TuskerBlueprint repository, Helm and Argo CD CLI do not need to be
installed on the remote machine. They remain on the Mac.

## Phase 5: Copy the new kubeconfig to the Mac

### Mac terminal

Use a separate kubeconfig file so that other Mac Kubernetes contexts are not
overwritten:

```bash
mkdir -p "$HOME/.kube"

scp \
  subeesh@192.168.0.3:.kube/config \
  "$HOME/.kube/tuskerblueprint-vps8.yaml"

chmod 600 "$HOME/.kube/tuskerblueprint-vps8.yaml"
```

Change the API endpoint in this kubeconfig to the local SSH tunnel:

```bash
kubectl \
  --kubeconfig "$HOME/.kube/tuskerblueprint-vps8.yaml" \
  config set-cluster default \
  --server=https://127.0.0.1:16443
```

Give the context a recognisable name:

```bash
kubectl \
  --kubeconfig "$HOME/.kube/tuskerblueprint-vps8.yaml" \
  config rename-context default tuskerblueprint-vps8
```

Never commit `tuskerblueprint-vps8.yaml`. It contains cluster-administrator
credentials.

## Phase 6: Start the Kubernetes API SSH tunnel

### Mac terminal 1

Keep this terminal running whenever the Mac accesses the remote cluster:

```bash
ssh -N \
  -o ExitOnForwardFailure=yes \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=3 \
  -L 16443:127.0.0.1:6443 \
  subeesh@192.168.0.3
```

This maps `127.0.0.1:16443` on the Mac to the K3s API on the remote machine.

### Mac terminal 2

Select the new kubeconfig:

```bash
export KUBECONFIG="$HOME/.kube/tuskerblueprint-vps8.yaml"
```

Verify the connection:

```bash
kubectl config current-context
kubectl get nodes -o wide
kubectl cluster-info
```

Expected context:

```text
tuskerblueprint-vps8
```

Export `KUBECONFIG` in every new Mac terminal that runs `kubectl`, Helm,
`argocd`, or a repository setup script. Do not add this export globally if the
Mac administers other Kubernetes clusters.

## Phase 7: Verify the Mac tools and repository

### Mac terminal 2

```bash
for command_name in kubectl helm argocd jq python3; do
  command -v "${command_name}" || echo "Missing: ${command_name}"
done
```

Install missing commands through Homebrew when required:

```bash
brew install kubectl helm argocd jq
```

From the TuskerBlueprint repository root:

```bash
git switch main
git pull --ff-only
make validate
```

If the validation dependencies are not already installed on the Mac, create a
repository-local virtual environment and retry:

```bash
python3 -m venv .venv
source .venv/bin/activate

python -m pip install --upgrade pip
python -m pip install 'PyYAML==6.0.3'
python -m pip install \
  -r software-templates/tusker-service/skeleton/service/requirements-dev.txt

make validate
```

Do not continue if repository validation fails.

## Phase 8: Install Argo CD from the Mac

### Mac terminal 2

Confirm the new cluster is selected:

```bash
export KUBECONFIG="$HOME/.kube/tuskerblueprint-vps8.yaml"
kubectl config current-context
```

Install the repository-pinned Argo CD chart:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --version 8.3.2 \
  --values infrastructure/ansible/roles/argocd_bootstrap/files/values.yaml \
  --wait \
  --timeout 10m
```

Verify the installation:

```bash
kubectl -n argocd get pods

kubectl -n argocd rollout status \
  deployment/argocd-server \
  --timeout=600s
```

## Phase 9: Log in to Argo CD from the Mac

### Mac terminal 3

Keep this port-forward running:

```bash
export KUBECONFIG="$HOME/.kube/tuskerblueprint-vps8.yaml"

kubectl port-forward \
  svc/argocd-server \
  -n argocd \
  8080:443
```

### Mac browser

Open:

```text
https://localhost:8080
```

The browser may show a warning for the initial self-signed certificate.

### Mac terminal 2

Retrieve the initial password:

```bash
argocd admin initial-password -n argocd
```

Log in without putting the password in shell history:

```bash
argocd login localhost:8080 \
  --username admin \
  --insecure \
  --grpc-web
```

Change the administrator password:

```bash
argocd account update-password
```

After confirming that the new password works, delete the initial-password
Secret:

```bash
kubectl -n argocd delete secret argocd-initial-admin-secret
```

## Phase 10: Commit the new Argo CD public certificate

A fresh Argo CD installation creates a new server certificate. Backstage must
trust that certificate. This is the main mandatory Git change caused by the
machine replacement.

### Mac terminal 2

From the TuskerBlueprint repository root:

```bash
git switch main
git pull --ff-only
git switch -c chore/argocd-ca-192-168-0-3

./scripts/backstage/update-argocd-ca-configmap.sh
```

Review the only expected file change:

```bash
git diff -- \
  platform-services/backstage/manifests/argocd-ca-configmap.yaml
```

Only the public certificate may be committed. Never commit a TLS private key.

```bash
git add platform-services/backstage/manifests/argocd-ca-configmap.yaml

git commit -m "chore(backstage): trust Argo CD certificate on new host"

git push -u origin chore/argocd-ca-192-168-0-3
```

### GitHub UI: TuskerBlueprint repository > Pull requests

1. Create a pull request from `chore/argocd-ca-192-168-0-3` to `main`.
2. Confirm that only the public certificate ConfigMap changed.
3. Merge the pull request.

Return the Mac repository to the updated `main` branch:

```bash
git switch main
git pull --ff-only
```

## Phase 11: Give Argo CD read access to TuskerBlueprint

Create a new deploy key on the Mac. Do not copy the old cluster's private key
unless continued reuse is an explicit security decision.

### Mac terminal 2

```bash
ssh-keygen \
  -t ed25519 \
  -C "argocd-tuskerblueprint-192.168.0.3" \
  -f "$HOME/.ssh/tuskerblueprint-argocd-192-168-0-3" \
  -N ''

cat "$HOME/.ssh/tuskerblueprint-argocd-192-168-0-3.pub"
```

### GitHub UI: TuskerBlueprint repository > Settings > Deploy keys

1. Select **Add deploy key**.
2. Set the title to `TuskerBlueprint Argo CD 192.168.0.3`.
3. Paste the public key.
4. Leave **Allow write access** disabled.
5. Add the key.

### Mac terminal 2

Create the Argo CD repository Secret:

```bash
kubectl -n argocd create secret generic \
  argocd-repository-tuskerblueprint \
  --from-literal=type=git \
  --from-literal=url=git@github.com:stonetusker/tuskerblueprint.git \
  --from-file=sshPrivateKey="$HOME/.ssh/tuskerblueprint-argocd-192-168-0-3" \
  --dry-run=client \
  -o yaml | kubectl apply -f -

kubectl -n argocd label secret \
  argocd-repository-tuskerblueprint \
  argocd.argoproj.io/secret-type=repository \
  --overwrite
```

Verify only the repository connection status, without printing the private
key:

```bash
argocd repo list
```

## Phase 12: Recreate GitHub, GHCR and Backstage Secrets

The OAuth URLs do not change because the browser still accesses Backstage from
the Mac:

```text
Homepage URL: http://localhost:7007
Authorization callback URL: http://localhost:7007/api/auth/github/handler/frame
```

The existing GitHub OAuth application can be reused. Its client ID and client
secret must be written into the new Kubernetes cluster again.

Prepare the following credentials privately:

- GitHub OAuth client ID and secret;
- Backstage/scaffolder GitHub token;
- Argo CD private-repository read token;
- GHCR PAT classic with `read:packages`;
- GitHub username and account email.

### Mac terminal 2

From the repository root:

```bash
./scripts/backstage/configure-github-oauth-secret.sh
./scripts/backstage/configure-github-platform-secret.sh
```

Keep the Argo CD port-forward at `localhost:8080` running and configure the
Backstage read-only Argo CD account:

```bash
./scripts/backstage/configure-argocd-readonly.sh
```

These scripts create or update:

```text
backstage/backstage-auth-secrets
backstage/backstage-github-credentials
backstage/backstage-argocd-credentials
argocd/argocd-github-org-repo-creds
platform-secrets/ghcr-pull-credentials
```

Do not print, export, commit or record the values of these Secrets.

## Phase 13: Bootstrap the GitOps platform

### Mac terminal 2

Apply the root Application:

```bash
kubectl apply -k gitops/bootstrap/root-application
```

Wait for Applications to appear:

```bash
kubectl get applications -n argocd
```

Refresh and synchronize the root Application:

```bash
argocd app get platform-root --hard-refresh
argocd app sync platform-root
```

Synchronize Secret distribution before Backstage:

```bash
argocd app sync external-secrets
argocd app wait external-secrets \
  --sync \
  --health \
  --timeout 600

argocd app sync github-access
argocd app wait github-access \
  --sync \
  --health \
  --timeout 600

argocd app sync backstage-platform-resources
argocd app wait backstage-platform-resources \
  --sync \
  --health \
  --timeout 600

argocd app sync backstage
argocd app wait backstage \
  --sync \
  --health \
  --timeout 900
```

Synchronize observability:

```bash
argocd app sync prometheus
argocd app sync loki
argocd app sync alloy
argocd app sync grafana
```

The automated sync policies reconcile the remaining platform and workload
Applications. Monitor them with:

```bash
kubectl get applications -n argocd --watch
```

Exit the watch with `Ctrl+C`.

## Phase 14: Validate the platform

### Mac terminal 2

Check Kubernetes and Argo CD:

```bash
kubectl get nodes -o wide
kubectl get applications -n argocd
kubectl get pods -A
```

Run the repository acceptance scripts:

```bash
./scripts/backstage/verify-github-platform-secrets.sh
./scripts/demo/developer-workflow-preflight.sh
./scripts/demo/preflight.sh
```

Do not continue to the recorded demonstration if any of these scripts fails.

If troubleshooting information is required, collect:

```bash
kubectl get applications -n argocd
kubectl get pods -A
kubectl -n monitoring get daemonset alloy
kubectl -n monitoring logs daemonset/alloy -c alloy --tail=200
```

Then collect the K3s service log on the remote machine:

```bash
ssh subeesh@192.168.0.3 \
  'sudo journalctl -u k3s -n 200 --no-pager'
```

## Phase 15: Access Backstage from the Mac

### Mac terminal 4

```bash
export KUBECONFIG="$HOME/.kube/tuskerblueprint-vps8.yaml"

kubectl port-forward \
  -n backstage \
  svc/backstage \
  7007:7007
```

### Mac browser

Open:

```text
http://localhost:7007
```

### Backstage UI: Create > Tusker Service

1. Sign in through GitHub.
2. Open **Create**.
3. Confirm that **Tusker Service** is displayed.
4. Do not create a test service until the preflight scripts pass.

## Phase 16: Access Grafana from the Mac

### Mac terminal 5

```bash
export KUBECONFIG="$HOME/.kube/tuskerblueprint-vps8.yaml"

kubectl port-forward \
  -n grafana \
  svc/grafana \
  3000:80
```

Retrieve the new Grafana administrator password privately:

```bash
kubectl -n grafana get secret grafana \
  -o jsonpath='{.data.admin-password}' | base64 --decode

echo
```

Do not show this command or its output in a recording.

### Mac browser

Open:

```text
http://localhost:3000
```

### Grafana UI: Dashboards > Stonetusker Demo

Open:

```text
Stonetusker Demo Service | Golden Path
```

## Phase 17: Generate fresh metrics and logs

Prometheus and Loki on the new machine do not contain history from the old
machine. Empty panels are expected until new requests have been generated and
scraped.

### Mac terminal 6

Open the demo service locally:

```bash
export KUBECONFIG="$HOME/.kube/tuskerblueprint-vps8.yaml"
./scripts/demo/open-demo-ui.sh
```

This exposes:

```text
Application: http://localhost:8081
API documentation: http://localhost:8081/docs
```

### Mac terminal 7

Generate one traffic round:

```bash
./scripts/demo/generate-traffic.sh
```

Then run continuous traffic while validating the dashboard:

```bash
DEMO_CONTINUOUS=1 \
./scripts/demo/generate-traffic.sh
```

Wait approximately 60 to 90 seconds for metrics scraping and log ingestion.

### Mac terminal 2

Run the exact runtime observability verification:

```bash
./scripts/demo/verify-observability.sh
```

It must confirm:

- application release metrics;
- HTTP request metrics;
- product activity metrics;
- Kubernetes deployment state;
- a correlation ID searchable in Loki.

If this command does not pass, do not assume that a Grafana panel problem is
only cosmetic. Correct the collection or query failure before recording.

## Phase 18: Test the Backstage golden path

### Backstage UI: Create > Tusker Service

After all preflight checks pass:

1. Select **Tusker Service**.
2. Enter a unique service name.
3. Choose the owner and system.
4. Choose public or private repository visibility.
5. Enter the developer GitHub username.
6. Run the template.

### GitHub UI: New service repository > Actions

1. Confirm that CI starts.
2. Confirm tests and validation pass.
3. Confirm that an immutable GHCR image is published.
4. Review and merge the generated release pull request.

### GitHub UI: TuskerBlueprint repository > Pull requests

1. Review the generated workload-onboarding pull request.
2. Confirm the new file is under `gitops/generated-workloads/<service-name>/`.
3. Merge the pull request.

### Argo CD UI: Applications

1. Confirm that the new Application appears.
2. Confirm that it becomes `Synced` and `Healthy`.

## Phase 19: Final acceptance gate

### Mac terminal 2

```bash
kubectl get nodes -o wide
kubectl get applications -n argocd
kubectl get pods -A

./scripts/backstage/verify-github-platform-secrets.sh
./scripts/demo/developer-workflow-preflight.sh
./scripts/demo/preflight.sh
./scripts/demo/verify-observability.sh
```

The migration is complete only when:

- the remote K3s node is `Ready`;
- critical Argo CD Applications are `Synced` and `Healthy`;
- Backstage GitHub sign-in works;
- **Create > Tusker Service** shows the template;
- the maintained demo service responds;
- Prometheus panels contain current data;
- the Loki request panel contains correlated application logs;
- a newly scaffolded test service can complete its golden path.

## Phase 20: Retire the old machine

Keep the old machine until the final acceptance gate passes and a complete demo
rehearsal succeeds.

### GitHub UI: TuskerBlueprint repository > Settings > Deploy keys

1. Identify the old machine's Argo CD deploy key.
2. Confirm that the new key is working.
3. Remove the old key.

Also complete the following cleanup:

- revoke GitHub tokens that are no longer required;
- remove obsolete firewall rules;
- remove obsolete kubeconfig files from the Mac;
- archive or delete obsolete SSH host entries only after confirming the target;
- take a final snapshot if rollback retention is required;
- destroy the old machine only after verification.

## Public internet exposure

This runbook deliberately keeps Argo CD, Backstage, Grafana and the Kubernetes
API private. The development Traefik Service is currently configured as
`ClusterIP`, so opening firewall ports alone will not publish a user-created
service.

Public service exposure requires a separate reviewed GitOps change covering:

- an approved ingress entry point;
- DNS;
- TLS certificates;
- authentication where applicable;
- restricted administrative interfaces;
- the service's hostname and environment policy.

Do not expose Argo CD, Grafana or the Kubernetes API merely to simplify a demo.

## Troubleshooting

### SSH connection fails

From the Mac:

```bash
ping -c 3 192.168.0.3
nc -vz 192.168.0.3 22
ssh -vv subeesh@192.168.0.3
```

Check the VM network adapter, IP address, route, VLAN and SSH service.

### Kubernetes commands return connection refused

Confirm Mac terminal 1 is still running the SSH API tunnel:

```bash
ssh -N \
  -o ExitOnForwardFailure=yes \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=3 \
  -L 16443:127.0.0.1:6443 \
  subeesh@192.168.0.3
```

Confirm the Mac kubeconfig endpoint:

```bash
kubectl \
  --kubeconfig "$HOME/.kube/tuskerblueprint-vps8.yaml" \
  config view --minify
```

It should use:

```text
https://127.0.0.1:16443
```

### K3s is not ready

Run on the remote machine:

```bash
sudo systemctl status k3s --no-pager
sudo journalctl -u k3s -n 200 --no-pager
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl get pods -A
```

### An Argo CD Application cannot read GitHub

Run on the Mac:

```bash
argocd repo list
kubectl -n argocd get secret argocd-repository-tuskerblueprint
kubectl -n argocd get secret argocd-github-org-repo-creds
```

Do not print the Secret data.

### Backstage cannot display Argo CD data

Confirm the certificate and token resources:

```bash
kubectl -n backstage get configmap backstage-argocd-ca
kubectl -n backstage get secret backstage-argocd-credentials
kubectl -n backstage rollout status deployment/backstage --timeout=300s
```

Recheck the exact repository file:

```text
platform-services/backstage/manifests/argocd-ca-configmap.yaml
```

### Grafana contains no data

Run:

```bash
./scripts/demo/generate-traffic.sh
./scripts/demo/verify-observability.sh
```

If verification fails, inspect:

```bash
kubectl -n monitoring get pods
kubectl -n monitoring get daemonset alloy
kubectl -n monitoring logs daemonset/alloy -c alloy --tail=200
```

## Current infrastructure automation warning

Do not run the existing full Ansible site playbook for a new host until the
following repository paths have been corrected:

```text
infrastructure/ansible/inventories/dev/hosts.yml
infrastructure/ansible/inventories/dev/group_vars/all.yml
infrastructure/ansible/roles/kubectl/tasks/main.yml
infrastructure/ansible/playbooks/kubernetes.yml
```

At the time this runbook was written:

- the inventory contains the old host address;
- the group variables assume a different login user and key;
- the kubectl role hardcodes the old user home and host address;
- `infrastructure/ansible/playbooks/kubernetes.yml` is a placeholder.

The manual Mac-to-remote-host process in this document avoids those stale
assumptions.

## Values to change for the next migration

Before reusing this document for another machine, update:

1. `192.168.0.3` to the new address.
2. `subeesh` to the new SSH account, if different.
3. The SSH deploy-key filename and GitHub title.
4. The certificate-update branch name.
5. The kubeconfig filename if multiple environments must coexist.
6. Any public DNS records managed outside this private demo workflow.

Do not reuse the previous machine's Argo CD certificate manifest without
regenerating it from the new cluster.

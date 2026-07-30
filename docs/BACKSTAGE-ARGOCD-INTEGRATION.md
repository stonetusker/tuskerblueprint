# Backstage and Argo CD integration runbook

This runbook documents the working Backstage-to-Argo CD integration, including read-only authentication, internal networking, TLS trust, verification, certificate rotation, and troubleshooting.

## Architecture

Browser access and pod-to-service access are different paths:

```text
Browser → http://localhost:7007 → Backstage port-forward
Browser → https://localhost:8080 → Argo CD port-forward

Backstage pod
  → https://argocd-server.argocd.svc.cluster.local
  → Argo CD API
```

The Backstage Argo CD plugin must never use `localhost:8080`. Inside the Backstage container, `localhost` refers to the Backstage container itself.

## Repository files

| Path | Purpose |
| --- | --- |
| `platform-services/backstage/values/development-idp.yaml` | Argo CD plugin configuration, token Secret, CA environment variable, volume, and mount |
| `platform-services/backstage/manifests/argocd-ca-configmap.yaml` | Public Argo CD server certificate trusted by Backstage |
| `platform-services/backstage/manifests/kustomization.yaml` | Includes the CA ConfigMap in `backstage-platform-resources` |
| `scripts/backstage/configure-argocd-readonly.sh` | Creates the read-only Argo CD account and token Secret |
| `scripts/backstage/update-argocd-ca-configmap.sh` | Regenerates the committed public CA ConfigMap from the live cluster |
| `gitops/applications/platform/developer-platform/backstage/application-resources-development.yaml` | Reconciles the ConfigMap, ServiceAccount, RBAC, and NetworkPolicy |
| `gitops/applications/platform/developer-platform/backstage/application-development.yaml` | Reconciles the Backstage Helm release |

## Authentication model

The script `scripts/backstage/configure-argocd-readonly.sh` creates:

- Argo CD local account `backstage`;
- role `backstage-readonly`;
- permission to get Applications, projects, and clusters;
- Kubernetes Secret `backstage/backstage-argocd-credentials`;
- Secret key `ARGOCD_AUTH_TOKEN`.

The token is consumed by:

```yaml
argocd:
  appLocatorMethods:
    - type: config
      instances:
        - name: development
          url: https://argocd-server.argocd.svc.cluster.local
          token: ${ARGOCD_AUTH_TOKEN}
```

Do not store the token in Git.

## TLS trust model

Argo CD presents a self-signed or privately issued server certificate. Backstage trusts only the public certificate mounted from `backstage-argocd-ca`.

The Helm values must place these keys directly under `backstage:`:

```yaml
backstage:
  extraEnvVars:
    - name: NODE_EXTRA_CA_CERTS
      value: /etc/backstage/argocd-ca/argocd-server.crt

  extraVolumes:
    - name: argocd-ca
      configMap:
        name: backstage-argocd-ca

  extraVolumeMounts:
    - name: argocd-ca
      mountPath: /etc/backstage/argocd-ca
      readOnly: true
```

The top-level `resources:` key is only for CPU and memory requests and limits. Placing CA settings under `resources:` produces valid YAML but the Helm chart ignores them.

Do not use:

```text
NODE_TLS_REJECT_UNAUTHORIZED=0
```

That disables TLS verification globally for all HTTPS requests made by the Backstage Node.js process.

The proxy configuration `secure: false` only affects the configured proxy endpoint. It does not disable certificate validation for the Backstage Argo CD backend plugin's direct instance request.

## Initial configuration

### 1. Start the Argo CD port-forward

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

### 2. Log in with the Argo CD CLI

```bash
argocd login localhost:8080 --insecure --grpc-web
```

### 3. Configure the read-only account

```bash
scripts/backstage/configure-argocd-readonly.sh
```

Verify the Secret exists without printing it:

```bash
kubectl -n backstage get secret backstage-argocd-credentials
```

### 4. Generate the CA ConfigMap

```bash
scripts/backstage/update-argocd-ca-configmap.sh
```

Review:

```bash
git diff -- platform-services/backstage/manifests/argocd-ca-configmap.yaml
```

Commit and push the public certificate. Never commit `tls.key`.

### 5. Validate rendering

```bash
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py

helm template backstage backstage/backstage \
  --version 1.10.0 \
  --namespace backstage \
  --values platform-services/backstage/values/development-idp.yaml \
  >/tmp/backstage-rendered.yaml

grep -A12 -B5 \
  -E 'NODE_EXTRA_CA_CERTS|backstage-argocd-ca|/etc/backstage/argocd-ca' \
  /tmp/backstage-rendered.yaml
```

The rendered Deployment must contain the environment variable, ConfigMap volume, and volume mount.

### 6. Sync in dependency order

```bash
argocd app get platform-root --refresh

argocd app sync backstage-platform-resources
argocd app wait backstage-platform-resources \
  --sync --health --timeout 300

kubectl -n backstage get configmap backstage-argocd-ca

argocd app get backstage --hard-refresh
argocd app sync backstage
kubectl -n backstage rollout status deployment/backstage --timeout=300s
```

## Verification

### Network and API reachability

Run a temporary curl pod from the Backstage namespace:

```bash
kubectl -n backstage run argocd-api-check \
  --image=curlimages/curl:8.11.1 \
  --restart=Never \
  --rm --stdin --tty -- \
  curl -sk -o /dev/null \
  -w 'HTTP status: %{http_code}\n' \
  https://argocd-server.argocd.svc.cluster.local/api/v1/applications/demo-service-development
```

Expected without a token:

```text
HTTP status: 401
```

### Live Deployment

```bash
kubectl -n backstage get deployment backstage \
  -o jsonpath='{range .spec.template.spec.containers[*].env[*]}{.name}={.value}{"\n"}{end}' \
  | grep NODE_EXTRA_CA_CERTS

kubectl -n backstage get deployment backstage \
  -o jsonpath='{range .spec.template.spec.volumes[*]}{.name}{" => "}{.configMap.name}{"\n"}{end}' \
  | grep argocd-ca

kubectl -n backstage get deployment backstage \
  -o jsonpath='{range .spec.template.spec.containers[*].volumeMounts[*]}{.name}{" => "}{.mountPath}{"\n"}{end}' \
  | grep argocd-ca
```

Expected:

```text
NODE_EXTRA_CA_CERTS=/etc/backstage/argocd-ca/argocd-server.crt
argocd-ca => backstage-argocd-ca
argocd-ca => /etc/backstage/argocd-ca
```

### Node.js certificate validation

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

This direct test omits the token. The response proves the certificate is trusted and the API is reachable.

### Backstage plugin

#### Backstage UI steps

```text
Backstage
→ Catalog
→ StoneTusker Customer Notification API
→ Argo CD
→ Refresh
```

Inspect fresh logs:

```bash
kubectl -n backstage logs deployment/backstage --since=3m \
  | grep -Ei 'argocd|certificate|self-signed|altname|unauthorized|forbidden|error|failed' \
  || true
```

Successful requests include:

```text
GET /api/argocd/find/name/demo-service-development ... 200
GET /api/argocd/argoInstance/development/applications/name/demo-service-development ... 200
```

A later `304` is a normal browser cache response.

## Certificate rotation

Rotate whenever:

- Argo CD is reinstalled;
- the Argo CD server TLS Secret changes;
- the certificate approaches expiry;
- the cluster or service DNS name changes.

Run:

```bash
scripts/backstage/update-argocd-ca-configmap.sh
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py

git add platform-services/backstage/manifests/argocd-ca-configmap.yaml
git commit -m 'chore(backstage): rotate Argo CD CA certificate'
git push origin main

argocd app sync backstage-platform-resources
argocd app sync backstage
kubectl -n backstage rollout status deployment/backstage --timeout=300s
```

`NODE_EXTRA_CA_CERTS` is read when Node.js starts, so Backstage must roll after the ConfigMap changes.

## Troubleshooting matrix

| Symptom | Likely cause | Corrective action |
| --- | --- | --- |
| `self-signed certificate` | CA not mounted or stale | Regenerate ConfigMap, sync resources, roll Backstage |
| `Hostname/IP does not match certificate's altnames` | Missing internal service SAN | Reissue certificate with Kubernetes service DNS SANs |
| `NODE_EXTRA_CA_CERTS=` | Helm values placed under wrong key or old revision running | Move keys under `backstage:`, render, commit, hard refresh, sync |
| Mount path missing | `extraVolumes` or `extraVolumeMounts` not rendered | Inspect `helm template` and `argocd app manifests backstage` |
| HTTP `401` in direct no-token test | Expected | Certificate and networking work; test intentionally omits auth |
| HTTP `403` from plugin | Token is valid but RBAC is insufficient | Re-run/read the read-only account policy |
| Plugin cannot find the app | Catalog annotation or Application name mismatch | Verify `argocd/app-name: demo-service-development` |
| `404` from `/api/v1/version` | Endpoint is not valid for this server | Test the application endpoint used by Backstage |
| `secure: false` has no effect | It only affects the proxy route | Configure `NODE_EXTRA_CA_CERTS` for the plugin instance |

## Security rules

- Commit only the public certificate.
- Never commit Argo CD tokens, OAuth secrets, GitHub tokens, SSH keys, or TLS private keys.
- Keep the Argo CD account read-only.
- Use the internal Kubernetes service URL for pod-to-service traffic.
- Use a managed or cert-manager-issued certificate for production.
- Monitor certificate expiry and test rotation before it becomes urgent.

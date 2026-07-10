# cert-manager Manual Validation

## Prerequisites

Run the commands from a workstation with `kubectl` configured for the target
cluster. The checks are read-only and do not modify cluster resources.

## Argo CD Application

```bash
kubectl get application cert-manager -n argocd \
  -o jsonpath='{.status.sync.status}{" "}{.status.health.status}{"\n"}'
```

Expected output:

```text
Synced Healthy
```

## Workloads and Services

```bash
kubectl get deployments,services,pods -n cert-manager
```

Expected output includes the following ready deployments and services:

```text
deployment.apps/cert-manager
deployment.apps/cert-manager-webhook
deployment.apps/cert-manager-cainjector
service/cert-manager
service/cert-manager-webhook
service/cert-manager-cainjector
```

All cert-manager pods must be `Running` and ready.

```bash
kubectl rollout status deployment/cert-manager -n cert-manager --timeout=30s
kubectl rollout status deployment/cert-manager-webhook -n cert-manager --timeout=30s
kubectl rollout status deployment/cert-manager-cainjector -n cert-manager --timeout=30s
```

Expected output for each deployment:

```text
deployment "<deployment-name>" successfully rolled out
```

## CRDs and API Readiness

```bash
kubectl get crd \
  certificaterequests.cert-manager.io \
  certificates.cert-manager.io \
  clusterissuers.cert-manager.io \
  issuers.cert-manager.io \
  challenges.acme.cert-manager.io \
  orders.acme.cert-manager.io

kubectl get --raw /apis/cert-manager.io/v1 | jq -r '.groupVersion'
kubectl get --raw /apis/acme.cert-manager.io/v1 | jq -r '.groupVersion'
```

Expected output includes all six CRDs and:

```text
cert-manager.io/v1
acme.cert-manager.io/v1
```

## TPVF Command

```bash
./scripts/platform-verification/verify.sh cert-manager
```

Expected result:

```text
Passed            : 22
Failed            : 0
```

## Troubleshooting

If the Argo CD application is not `Synced` and `Healthy`, inspect its status
and recent reconciliation events:

```bash
kubectl describe application cert-manager -n argocd
kubectl get events -n argocd --sort-by=.metadata.creationTimestamp
```

If a deployment is unavailable, inspect the relevant pods and logs:

```bash
kubectl get pods -n cert-manager
kubectl describe deployment cert-manager-webhook -n cert-manager
kubectl logs deployment/cert-manager -n cert-manager --tail=100
kubectl logs deployment/cert-manager-webhook -n cert-manager --tail=100
kubectl logs deployment/cert-manager-cainjector -n cert-manager --tail=100
```

If CRDs or API discovery are unavailable, verify the Argo CD application is
healthy before inspecting the cert-manager webhook logs. Do not apply CRDs or
modify live resources manually; correct the GitOps source and allow Argo CD to
reconcile it.

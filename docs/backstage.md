# Backstage implementation

## Capabilities

The repository includes configuration and source scaffolding for:

- GitHub authentication;
- Software Catalog and catalog import;
- TechDocs and Search;
- Software Templates;
- Kubernetes visibility;
- Argo CD visibility;
- API documentation;
- GitHub Actions visibility;
- permission-policy extension points.

## Active development mode

The development Argo CD Application uses:

```text
platform-services/backstage/values/development-idp.yaml
```

The rollback values file is:

```text
platform-services/backstage/values/development.yaml
```

The custom values consume three runtime Secrets:

```text
backstage-github-credentials
backstage-auth-secrets
backstage-argocd-credentials
```

No secret values are committed.

## Argo CD integration

The Backstage pod connects internally to:

```text
https://argocd-server.argocd.svc.cluster.local
```

It trusts the Argo CD server certificate through:

```text
platform-services/backstage/manifests/argocd-ca-configmap.yaml
```

The certificate is mounted at:

```text
/etc/backstage/argocd-ca/argocd-server.crt
```

Node.js loads it through:

```text
NODE_EXTRA_CA_CERTS=/etc/backstage/argocd-ca/argocd-server.crt
```

Regenerate the ConfigMap after a new cluster, Argo CD reinstall, or certificate rotation:

```bash
scripts/backstage/update-argocd-ca-configmap.sh
```

Full runbook: [Backstage and Argo CD integration](BACKSTAGE-ARGOCD-INTEGRATION.md).

## Local access

Backstage:

```bash
kubectl -n backstage port-forward svc/backstage 7007:7007
```

Open `http://localhost:7007`.

Argo CD:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Open `https://localhost:8080`.

These are browser access paths. The Backstage pod does not use `localhost:8080`.

## Deployment order

The platform-resource Application must reconcile before Backstage because it creates the CA ConfigMap, ServiceAccount, RBAC, and NetworkPolicy:

```bash
argocd app sync backstage-platform-resources
argocd app wait backstage-platform-resources --sync --health --timeout 300
argocd app sync backstage
kubectl -n backstage rollout status deployment/backstage --timeout=300s
```

## Further guidance

- [Setup from scratch](SETUP-FROM-SCRATCH.md)
- [Backstage IDP deployment and rollback](IDP-MIGRATION-RUNBOOK.md)
- [Customer demo](demo-runbook.md)

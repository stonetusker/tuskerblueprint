# Customer demo runbook

## Before the meeting

1. Run repository and platform validation:

   ```bash
   PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py
   scripts/demo/preflight.sh
   scripts/demo/status.sh
   ```

2. Keep these port-forward sessions running in separate terminals:

   ```bash
   kubectl -n backstage port-forward svc/backstage 7007:7007
   kubectl -n argocd port-forward svc/argocd-server 8080:443
   kubectl -n demo-service-development port-forward svc/demo-service 8081:80
   ```

3. Open:

   ```text
   Backstage:    http://localhost:7007
   Argo CD:      https://localhost:8080
   Demo application: http://localhost:8081/
   ```

4. Confirm `backstage`, `backstage-platform-resources`, and `demo-service-development` are `Synced` and `Healthy`.
5. Confirm the Backstage Catalog, Docs, APIs, Kubernetes, and Argo CD tabs load.
6. Confirm the Argo CD tab shows `demo-service-development` without a certificate error.
7. Keep a prepared Git change ready for the release demonstration.
8. Confirm `subeeshlearn` is an accepted StoneTusker organization member and can sign in through GitHub OAuth.
9. Confirm the Backstage platform GitHub credential can create repositories and open the onboarding pull request.

## Demo flow

### 1. Platform catalog

### Backstage UI steps

```text
Backstage
→ Catalog
```

Show systems, components, APIs, resources, ownership, and lifecycle.

### 2. Golden path

### Backstage UI steps

```text
Backstage
→ Create
→ Tusker Service
```

Use the second GitHub identity `subeeshlearn` and follow [End-to-end developer demo](DEVELOPER-DEMO-WORKFLOW.md). Show the generated source repository, developer collaborator access, Component/API registration, complete TechDocs, GitHub Actions, and the GitOps onboarding pull request.

### 3. Demo application

Open `http://localhost:8081/`. Submit one fictional notification and retain the returned correlation ID. Explain that the UI, API, structured log and Prometheus metric are produced by the same immutable workload reconciled by Argo CD.

### 4. Documentation and API

Open `StoneTusker Customer Notification API`, then show **Docs** and **APIs**.

### 5. Runtime and deployment

Show the **Kubernetes** and **Argo CD** tabs. Explain:

- Backstage is the developer-experience layer;
- Argo CD remains the reconciliation control plane;
- Backstage uses a read-only Argo CD account;
- Backstage validates the internal Argo CD certificate through a mounted public CA.

### 6. Git-driven release

Change a safe demo-service source or deployment value, commit, and push. Show Argo CD reconcile the new immutable revision.

Useful commands:

```bash
argocd app get demo-service-development --refresh
argocd app wait demo-service-development --sync --health --timeout 300
kubectl -n demo-service-development rollout status deployment/demo-service --timeout=300s
```

### 7. Self-healing

Run:

```bash
scripts/demo/introduce-drift.sh
```

Show Argo CD restoring the Git-declared state.

Verify recovery:

```bash
scripts/demo/verify-recovery.sh
```

### 8. Close

Summarize the value: standardized creation, visible ownership, governed delivery, runtime transparency, certificate-aware internal integration, and reduced developer cognitive load.

## Troubleshooting before the call

Argo CD plugin logs:

```bash
kubectl -n backstage logs deployment/backstage --since=3m \
  | grep -Ei 'argocd|certificate|self-signed|altname|unauthorized|forbidden|error|failed' \
  || true
```

Expected successful requests include HTTP `200`; HTTP `304` is a normal cache response.

Full troubleshooting: [Backstage and Argo CD integration](BACKSTAGE-ARGOCD-INTEGRATION.md).

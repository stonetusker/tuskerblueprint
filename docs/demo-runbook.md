# Customer demo runbook

## Before the meeting

1. Keep both port-forward sessions running.
2. Confirm Backstage and demo-service are `Synced` and `Healthy`.
3. Confirm the catalog, Docs, API, Kubernetes, and Argo CD tabs load.
4. Keep a prepared Git change ready for the release demonstration.

## Demo flow

### 1. Platform catalog

Open **Backstage → Catalog** and show systems, components, APIs, resources, ownership, and lifecycle.

### 2. Golden path

Open **Backstage → Create → Tusker Service**. Explain the inputs and generated assets. Use a test repository during a full demonstration.

### 3. Documentation and API

Open the demo-service entity, then show **Docs** and **APIs**.

### 4. Runtime and deployment

Show the Kubernetes tab and the Argo CD card or link. Explain that Backstage is the developer experience layer while Argo CD remains the reconciliation control plane.

### 5. Git-driven release

Change `workloads/demo-service/base/content/index.html`, commit, and push. Show Argo CD reconcile the new revision.

### 6. Self-healing

Run `scripts/demo/introduce-drift.sh`, then show Argo CD restoring the desired replica count.

### 7. Close

Summarize the value: standardized creation, visible ownership, governed delivery, runtime transparency, and reduced developer cognitive load.

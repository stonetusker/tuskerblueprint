# Buyer demo readiness checklist

## Delivery

- [ ] Application pull request passes.
- [ ] Gitleaks blocks a prepared fake-secret branch.
- [ ] Semgrep produces SARIF.
- [ ] Trivy filesystem scan passes policy.
- [ ] Trivy image scan passes policy.
- [ ] SPDX SBOM is attached to the workflow.
- [ ] SHA image exists in GHCR.
- [ ] Development release PR changes only the overlay.
- [ ] Development Deployment uses the full SHA.

## Runtime

- [ ] Argo CD is Synced and Healthy.
- [ ] Two development replicas are ready.
- [ ] `/healthz` returns 200.
- [ ] `/readyz` returns 200 in normal mode.
- [ ] `/metrics` contains application and request metrics.
- [ ] Correlation ID is returned and logged.
- [ ] Grafana dashboard contains live data.
- [ ] Loki contains demo-service logs, or kubectl logs are used with an explicit limitation.

## Failure and recovery

- [ ] Readiness failure PR is prepared.
- [ ] Error-mode PR is prepared.
- [ ] Latency-mode PR is prepared.
- [ ] Healthy recovery PR is prepared.
- [ ] Recovery is performed through Git.
- [ ] Last-known-good SHA is recorded.
- [ ] Reset script has been rehearsed.

## Developer identity and provisioning

- [ ] `subeeshlearn` accepted the Stonetusker organization invitation.
- [ ] `catalog/users/subeeshlearn.yaml` resolves in Backstage.
- [ ] `group:default/developers` is visible and owns the generated service.
- [ ] The platform GitHub credential creates the selected public or private organization repository.
- [ ] The template grants `subeeshlearn` push access.
- [ ] The catalog Component and API are registered automatically.
- [ ] The GitOps onboarding pull request is created automatically.
- [ ] The generated repository includes both CI/release and metadata/GitOps validation workflows.
- [ ] The initial image exists before the onboarding pull request is merged.
- [ ] `argocd-github-org-repo-creds` exists for private Git access.
- [ ] `ghcr-pull-secret` is present in the workload namespace.

## Developer experience

- [ ] Backstage sign-in works.
- [ ] Catalog page works.
- [ ] API Docs renders.
- [ ] TechDocs renders.
- [ ] CI/CD view works.
- [ ] Kubernetes view works.
- [ ] Argo CD view works.
- [ ] Grafana link works.
- [ ] Tusker Service template completes using a disposable service.

## Presenter

- [ ] `scripts/demo/preflight.sh` passes.
- [ ] Browser tabs are pre-opened.
- [ ] Tokens and secrets are hidden.
- [ ] Buyer-safe fictional data is loaded.
- [ ] Evidence artifacts are downloaded.
- [ ] Backup screenshots are available.
- [ ] A fallback recording is available.
- [ ] Discovery and pilot offers are ready.

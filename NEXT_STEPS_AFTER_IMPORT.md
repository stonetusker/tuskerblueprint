# Next steps after importing the enhanced demo source

This file is the execution order for the next demo milestone. Keep the existing
Git repository and `.git` directory. Copy the enhanced files into a new branch;
do not replace the repository with a fresh untracked directory.

## 1. Create a working branch

```bash
git switch main
git pull --ff-only origin main
git switch -c feat/delivery-platform-demo
```

Copy the archive contents over the repository, preserving existing files that are
not present in the archive. Then remove the obsolete static NGINX demo content
and local validation artifacts:

```bash
./scripts/demo/cleanup-demo-source.sh
```

Then inspect:

```bash
git status --short
git diff --stat
git diff --check
```

## 2. Run the offline source validation

The validator parses maintained YAML with duplicate-key protection, ignores
`.generated` and dependency folders, checks Kustomize references, compiles
Python without writing bytecode, runs the real demo API tests, renders both
public and private Backstage service templates, and runs the generated-service
tests. It works even when `pytest-cov` is not installed, although the complete
coverage gate requires `requirements-dev.txt`.

```bash
python3 scripts/demo/validate-demo-source.py
find scripts -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
```

Expected result:

```text
Validation passed
```

## 3. Run the demo application locally

```bash
cd workloads/demo-service
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
ruff format --check app tests
ruff check app tests
mypy app
pytest --cov=app --cov-branch --cov-report=term-missing --cov-report=xml --cov-fail-under=85
uvicorn app.main:app --reload --port 8000
```

From another terminal:

```bash
curl -sS http://127.0.0.1:8000/ | python3 -m json.tool
curl -sS http://127.0.0.1:8000/readyz | python3 -m json.tool
curl -sS http://127.0.0.1:8000/metrics | head
```

## 4. Build and smoke-test the container locally

From `workloads/demo-service`:

```bash
docker build \
  --build-arg VCS_REF=local-validation \
  --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  -t tuskerblueprint-demo-service:local \
  .

docker run --rm --name tusker-demo-local -p 8000:8000 \
  tuskerblueprint-demo-service:local
```

Verify from another terminal:

```bash
curl -fsS http://127.0.0.1:8000/healthz
curl -fsS http://127.0.0.1:8000/readyz
curl -fsS http://127.0.0.1:8000/
```

## 5. Prepare GitHub Actions permissions

GitHub UI:

```text
Repository
→ Settings
→ Actions
→ General
→ Workflow permissions
```

Enable:

- Read and write permissions
- Allow GitHub Actions to create and approve pull requests

The workflow needs these capabilities to publish GHCR images and open the
immutable development release pull request.

## 6. Configure GHCR image-pull credentials

The Kubernetes Deployment references `ghcr-pull-secret`. Configure it before the
first API rollout if the package or repository is private.

Use a token with `read:packages`; do not commit it:

```bash
export GHCR_USERNAME='<github-user>'
export GHCR_TOKEN='<token-with-read-packages>'
export GHCR_EMAIL='<email>'
./scripts/demo/configure-ghcr-pull-secret.sh
unset GHCR_TOKEN
```

Alternative: make the GHCR package public after the first image is published and
remove `imagePullSecrets` through a reviewed change. The private-image path is the
better demonstration of a controlled environment.

## 7. Commit and push the source milestone

```bash
git add \
  .github/workflows/demo-service-ci.yml \
  workloads/demo-service \
  apis/demo-service/openapi.yaml \
  catalog/components/demo-service.yaml \
  catalog/apis/demo-service-api.yaml \
  gitops/applications/workloads/demo-service \
  platform-services/grafana/values/development.yaml \
  platform-services/alloy \
  gitops/applications/platform/observability/alloy \
  scripts/demo \
  software-templates/tusker-service \
  docs/demo \
  NEXT_STEPS_AFTER_IMPORT.md \
  Makefile \
  CHANGELOG-IDP.md \
  .gitignore \
  scripts/validate_idp.py

git diff --cached --check
git diff --cached --stat
git commit -m "feat(demo): add buyer-facing delivery platform workload"
git push -u origin feat/delivery-platform-demo
```

Open a pull request to `main`. The demo-service workflow runs on the application
changes. Review test, scan, container, and SBOM results before merging.

## 8. Merge the source pull request and wait for image publication

After merging to `main`, open:

```text
GitHub
→ Actions
→ Demo Service CI and Release
```

Required green steps:

- Format, lint, and type-check
- Unit tests and coverage
- Gitleaks
- Semgrep
- Trivy filesystem scan
- Docker build
- Trivy image scan
- SPDX SBOM
- GHCR push
- Immutable release PR creation

The workflow publishes:

```text
ghcr.io/stonetusker/tuskerblueprint-demo-service:<full-source-sha>
ghcr.io/stonetusker/tuskerblueprint-demo-service:main
```

The `main` tag bootstraps the first rolling update only. Do not use it as the
finished demo release.

## 9. Review and merge the generated immutable release pull request

The workflow opens a PR similar to:

```text
release(demo-service): deploy <sha> to development
```

Confirm that only this file changes:

```text
workloads/demo-service/overlays/development/kustomization.yaml
```

Confirm both values use the same full SHA:

```yaml
newTag: <full-sha>
tuskerblueprint.io/release-sha: <full-sha>
```

Merge the release PR.

## 10. Verify Argo CD and Kubernetes

```bash
argocd app get demo-service-development --refresh
argocd app wait demo-service-development --sync --health --timeout 300
kubectl -n demo-service-development rollout status deployment/demo-service --timeout=300s
./scripts/demo/status.sh
./scripts/demo/preflight.sh
```

Verify the immutable image:

```bash
kubectl -n demo-service-development get deployment demo-service \
  -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

It must end in the full Git SHA, not `:main`.

## 11. Verify the running API

```bash
kubectl -n demo-service-development port-forward service/demo-service 8081:80
```

In another terminal:

```bash
curl -i http://127.0.0.1:8081/
curl -i http://127.0.0.1:8081/readyz
curl -sS http://127.0.0.1:8081/metrics | grep -E 'application_info|http_requests_total'
DEMO_BASE_URL=http://127.0.0.1:8081 ./scripts/demo/generate-traffic.sh
```

## 12. Verify TechDocs

Backstage UI:

```text
Catalog
→ StoneTusker Customer Notification API
→ Docs
```

If generation fails, check:

```bash
kubectl -n backstage exec deployment/backstage -- sh -lc '
python3 --version
python3 -m pip --version
mkdocs --version
python3 -c "import techdocs_core; print(\"techdocs-core available\")"
'

kubectl -n backstage logs deployment/backstage --since=15m \
  | grep -Ei 'techdocs|mkdocs|generator|publisher|error|failed'
```

The Backstage image must contain MkDocs and `mkdocs-techdocs-core` when using the
local generator.

## 13. Verify Grafana metrics

```bash
kubectl -n grafana port-forward service/grafana 3000:80
```

Open:

```text
http://localhost:3000/d/stonetusker-demo-service
```

The dashboard should show request rate, error rate, p95 latency, ready replicas,
release SHA, and restarts. Generate traffic before deciding that a panel is empty.

## 14. Activate log collection only after metrics are healthy

The Alloy source is included but intentionally not activated automatically.
First confirm that the image is available for the cluster architecture:

```bash
docker pull grafana/alloy:v1.7.5
```

Then add `alloy` to:

```text
gitops/applications/platform/observability/kustomization.yaml
```

Commit, push, and verify:

```bash
argocd app get alloy --refresh
argocd app wait alloy --sync --health --timeout 300
kubectl -n monitoring rollout status daemonset/alloy --timeout=300s
kubectl -n monitoring logs daemonset/alloy --tail=200
```

After logs arrive in Loki, use the Grafana dashboard log panel or Explore.

## 15. Rehearse the failure and recovery flow

Create a demo branch:

```bash
git switch -c demo/readiness-failure
./scripts/demo/deploy-broken-release.sh readiness
```

Review, commit, push, and merge the failure-mode change. Watch Argo CD and the
readiness behavior. Then prepare the recovery:

```bash
git switch -c demo/recover-readiness main
./scripts/demo/deploy-healthy-release.sh
```

After the recovery change is merged:

```bash
./scripts/demo/verify-recovery.sh
```

For the buyer demo, use prepared PRs rather than typing changes live.

## 16. Test the Backstage golden path

Backstage UI:

```text
Create
→ Tusker Service
```

The template now defaults to Public because private GHCR and private Argo CD
repository access require additional credentials. Use a disposable repository
such as `buyer-demo-api`. Confirm that
it creates the repository, registers the entity, opens a service-specific GitOps
PR, runs CI, publishes an immutable image, and opens its development release PR.

Private generated repositories require `ghcr-pull-secret` in their namespace.
Automate this through External Secrets before presenting private-service creation.

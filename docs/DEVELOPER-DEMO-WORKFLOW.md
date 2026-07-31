# End-to-end developer demo with `subeeshlearn`

This runbook demonstrates the TuskerBlueprint developer experience using the GitHub identity `subeeshlearn`. The user signs in to Backstage, creates a service from a golden path, receives access to the generated GitHub repository, clones the source, raises a pull request, runs CI/security gates, publishes an immutable image, and deploys through Argo CD.

## What is automated

The **Tusker Service** template performs these actions:

1. Generates FastAPI source, tests, a Dockerfile, local verification, TechDocs, OpenAPI, and Kubernetes overlays.
2. Creates a public repository under the `stonetusker` GitHub organization with the Backstage platform credential.
3. Grants `subeeshlearn` push access to the generated repository.
4. Registers the Component and API entities in the Backstage catalog.
5. Opens a pull request against `stonetusker/tuskerblueprint` containing the Argo CD Application.
6. Runs generated repository CI/CD on the initial commit and future pull requests.
7. Publishes an immutable GHCR image after a merge to `main`.
8. Opens a development release pull request in the generated service repository.
9. Allows Argo CD to deploy the release after the onboarding and release pull requests are approved and merged.

The public-repository path is intentional for the live demo. It lets Argo CD read a newly created repository without provisioning another private-repository credential during the presentation.

## One-time GitHub preparation

Using the Stonetusker organization owner account:

1. Invite `subeeshlearn` to the organization.
2. Ask the user to accept the invitation.
3. Keep the organization role at **Member**.
4. Confirm organization members are allowed to receive repository collaborator access.
5. Under **Organization settings → Actions → General**, allow GitHub Actions and allow workflows to create pull requests when organization policy permits it.
6. Ensure the Backstage platform token belongs to a service or platform identity that can:
   - create repositories under `stonetusker`;
   - add organization members as collaborators;
   - write workflow files;
   - open branches and pull requests in `stonetusker/tuskerblueprint`.

Create or update the Backstage GitHub credential without printing the token:

```bash
scripts/backstage/configure-github-platform-secret.sh
```

Then reconcile Backstage:

```bash
argocd app get backstage --hard-refresh
argocd app sync backstage
kubectl -n backstage rollout status deployment/backstage --timeout=300s
```

## Backstage identity

The repository contains:

```text
catalog/users/subeeshlearn.yaml
catalog/groups/developers.yaml
```

The GitHub sign-in resolver uses `usernameMatchingUserEntityName`, so this value must remain exact:

```yaml
metadata:
  name: subeeshlearn
```

Validate and publish the catalog changes before the demo:

```bash
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py
git add catalog catalog-info.yaml
git commit -m 'feat(catalog): register demo developer'
git push origin main
```

## Run the developer-workflow preflight

From the repository root:

```bash
scripts/demo/developer-workflow-preflight.sh
```

This checks the maintained identity and template files, Backstage and generated-workloads Argo CD health, the Backstage rollout, and the presence of GitHub credential keys without printing secret values.

## Start local access

Run each command in a separate terminal:

```bash
kubectl -n backstage port-forward service/backstage 7007:7007
kubectl -n argocd port-forward service/argocd-server 8080:443
```

Open:

```text
Backstage: http://localhost:7007
Argo CD:   https://localhost:8080
```

Use a clean browser profile and sign in to Backstage with the GitHub user `subeeshlearn`.

## Create the service

In Backstage:

```text
Create → Tusker Service
```

Recommended demo values:

```text
Service name: customer-orders-api
Description: Customer order processing API
Owning team: group:default/developers
System: system:default/tuskerblueprint
GitHub developer username: subeeshlearn
Application port: 8000
Repository: github.com?owner=stonetusker&repo=customer-orders-api
```

The completed task must provide links to:

- the generated service repository;
- the new Backstage catalog entity;
- the TuskerBlueprint GitOps onboarding pull request.

## Review the generated repository

The repository should include:

```text
.github/workflows/ci.yml
.github/workflows/platform-validation.yml
.github/dependabot.yml
README.md
CONTRIBUTING.md
SECURITY.md
catalog-info.yaml
openapi.yaml
mkdocs.yml
docs/
src/
tests/
Dockerfile
deploy/base/
deploy/overlays/development/
deploy/overlays/staging/
deploy/overlays/production/
scripts/verify.sh
```

The initial repository commit triggers **Service CI and Release**. The workflow publishes the `main` bootstrap image and uses the repository-scoped GitHub token to make the public demo package anonymously pullable. Wait for this step to pass before merging the GitOps onboarding pull request.

If organization policy blocks public packages, do not merge the onboarding pull request. Either allow the package to become public for the demo or provision `ghcr-pull-secret` in the generated namespace through an approved secret-management workflow.

## Clone as the developer

Configure GitHub SSH or use GitHub CLI authentication for `subeeshlearn`, then run:

```bash
git clone git@github.com:stonetusker/customer-orders-api.git
cd customer-orders-api
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-dev.txt
scripts/verify.sh
```

## Make a normal application change

```bash
git checkout -b feature/improve-example-response
```

Change `src/main.py`, update tests and documentation, then run:

```bash
scripts/verify.sh
git add .
git commit -m 'feat: improve example response'
git push -u origin feature/improve-example-response
```

Open a pull request in GitHub. Show the automatically applied quality and security checks, then approve and merge it with a maintainer identity.

## Release and deployment

A successful `main` workflow publishes:

```text
ghcr.io/stonetusker/customer-orders-api:<full-git-sha>
```

It also opens a release pull request that updates only:

```text
deploy/overlays/development/kustomization.yaml
```

Review and merge the release pull request. Separately review and merge the TuskerBlueprint onboarding pull request if it has not already been merged.

The `generated-workloads` Argo CD controller then creates:

```text
customer-orders-api-development
```

Argo CD first reads the generated Application manifest from the TuskerBlueprint repository. That Application then reads only the generated service repository and its `deploy/overlays/development` path. It does not clone unrelated services.

Verify:

```bash
kubectl -n argocd get application customer-orders-api-development
kubectl -n customer-orders-api-development get deployment,pod,service
```

Open the generated application UI:

```bash
kubectl -n customer-orders-api-development port-forward \
  service/customer-orders-api 8082:80
```

Then open `http://localhost:8082/`. The UI, `/docs`, health endpoints, metrics and product API are served by the same immutable container image.

## Show the result through Backstage

Open:

```text
Catalog → customer-orders-api
```

Demonstrate:

- ownership and system relationships;
- source repository and GitHub Actions;
- API definition;
- TechDocs;
- Kubernetes resources;
- Argo CD sync and health.

## Acceptance checklist

- [ ] `subeeshlearn` signs in through GitHub OAuth.
- [ ] Backstage resolves `user:default/subeeshlearn`.
- [ ] The Tusker Service template is visible.
- [ ] The generated repository is under `stonetusker`.
- [ ] `subeeshlearn` has push access.
- [ ] Initial CI passes and publishes the bootstrap image.
- [ ] Component and API entities appear in Backstage.
- [ ] TechDocs builds and every navigation page opens.
- [ ] The GitOps onboarding pull request is created.
- [ ] The generated repository release pull request is created.
- [ ] Argo CD creates the development Application.
- [ ] The Application becomes `Synced` and `Healthy`.
- [ ] The Kubernetes and Argo CD tabs work from the catalog entity.
- [ ] The generated browser UI opens through port-forwarding.
- [ ] The UI example request returns a correlation ID.

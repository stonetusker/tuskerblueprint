# Developer demo workflow

## Precondition

Run `scripts/backstage/configure-github-platform-secret.sh` and verify `github-access` is healthy. This enables public and private repositories/packages through Kubernetes-managed credentials.

## Demo

1. Sign in to Backstage as `subeeshlearn`.
2. Open **Create → Tusker Service**.
3. Enter a disposable service name and choose **Private** to demonstrate enterprise behavior, or **Public** for an open-source case.
4. Confirm Backstage creates the repository, grants access, registers the component/API and opens the platform onboarding PR.
5. Open the generated repository Actions page and show quality, security and SBOM gates.
6. Merge the immutable release PR after confirming only the development overlay changed.
7. Merge the TuskerBlueprint onboarding PR.
8. Show the namespace label, replicated `ghcr-pull-secret`, Argo CD health, Kubernetes resources, TechDocs and API Docs.

The same manifests work for both visibility modes. There is no manual GHCR visibility conversion step.

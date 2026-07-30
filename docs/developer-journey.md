# Developer journey

## Sign in

A developer signs in to Backstage with GitHub. The GitHub username must match a Backstage User entity. The live demo identity is `user:default/subeeshlearn`, which belongs to `group:default/developers`.

## Discover

The developer searches for a service, owner, system, API, or TechDocs page. Runtime and deployment status are presented from the service entity instead of requiring broad administrative access.

## Create

The developer selects **Create → Tusker Service** and supplies the service name, owner, system, runtime port, GitHub username, and repository location.

The template:

1. Generates application source, tests, local verification, a hardened container build, documentation, OpenAPI, and Kubernetes manifests.
2. Creates a public GitHub repository with the Backstage platform credential.
3. Grants the selected GitHub developer push access.
4. Registers the Component and API entities in Backstage.
5. Opens a pull request against the TuskerBlueprint GitOps repository to add the Argo CD Application.

## Develop

The developer clones the generated repository, creates a feature branch, runs `scripts/verify.sh`, and opens a normal GitHub pull request. Platform standards are already encoded in the repository rather than left as manual setup work.

## Deliver

Pull requests run quality, test, coverage, secret, SAST, dependency, image, and SBOM checks. A successful merge to `main` publishes an immutable GHCR image and opens a development release pull request.

After the onboarding and release pull requests are approved and merged, Argo CD discovers the desired state and deploys the service.

## Operate

The developer uses Backstage to inspect ownership, API documentation, TechDocs, GitHub Actions, Kubernetes resources, and Argo CD health. Prometheus metrics and structured correlation-ID logs support troubleshooting. Manual cluster drift is corrected by Argo CD.

See [End-to-end developer demo](DEVELOPER-DEMO-WORKFLOW.md) for the complete `subeeshlearn` walkthrough.

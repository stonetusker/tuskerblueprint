# Developer journey

## Discover

A developer opens Backstage and searches for a service, owner, system, API, or document.

## Create

The developer selects **Create → Tusker Service** and supplies the service name, owner, system, runtime port, and repository visibility.

The template:

1. Generates application source, tests, container build files, documentation, OpenAPI, and Kubernetes manifests.
2. Creates a GitHub repository.
3. Registers the service in the Backstage catalog.
4. Opens a pull request against the TuskerBlueprint GitOps repository to add the Argo CD Application.

## Deliver

After review and merge, Argo CD discovers the desired state and deploys the service. The developer observes sync status, health, Kubernetes resources, and documentation from the service entity page.

## Operate

The developer uses Backstage links and embedded views to inspect deployments, pods, logs, dashboards, APIs, and runbooks. Manual drift is corrected by Argo CD.

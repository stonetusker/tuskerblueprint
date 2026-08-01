# Architecture

## Repository model

`stonetusker/tuskerblueprint` owns the IDP control plane: Backstage, Argo CD bootstrap and registrations, shared platform services, catalog identities and software templates.

`stonetusker/tusker-demo-notification-service` owns the maintained demonstration application: source, UI, tests, OpenAPI, TechDocs, CI/CD and Kustomize overlays.

New services created through Backstage receive their own repository with the same application-side structure.

## Control flow

Backstage creates and registers the service repository. The initial push runs application CI. CI publishes an immutable GHCR image and opens a release PR in the service repository. Backstage also opens an onboarding PR in the platform repository. After both PRs are reviewed and merged, Argo CD follows the application repository overlay and deploys the workload.

# Service onboarding

TuskerBlueprint supports public and private service repositories. Before onboarding, the platform owner configures Kubernetes-only GitHub credentials and confirms `github-access` is healthy.

The generated Argo CD Application:

- points to `deploy/overlays/development` in the service repository;
- uses the `workloads` AppProject;
- applies the generated GHCR `ExternalSecret`;
- creates the namespace through Argo CD;
- deploys only after the immutable service release PR is merged.

Argo CD uses `argocd-github-org-repo-creds` when the repository is private. Kubernetes uses `ghcr-pull-secret` when the package is private. Public resources continue to work through the same configuration.

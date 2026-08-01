# GitOps

The platform repository stores Argo CD `Application` objects. Each Application points to `deploy/overlays/<environment>` in its service repository.

The service repository owns the image tag. CI never calls `kubectl` or `argocd`; it opens a release PR that updates the development overlay to the full Git commit SHA. Argo CD deploys only after the release PR and onboarding PR are merged.

The `workloads` AppProject allows StoneTusker GitHub repositories and namespaces ending in `-development`, `-staging` or `-production`.

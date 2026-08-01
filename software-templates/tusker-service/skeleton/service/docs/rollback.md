# Rollback

Rollback is a Git operation. Revert the release PR or update `deploy/overlays/development/kustomization.yaml` to a previously published full SHA, open a pull request, and merge it. Argo CD reconciles the old immutable image.

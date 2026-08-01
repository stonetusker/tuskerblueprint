# Migration runbook: embedded workload to split repositories

## Safety conditions

- Rotate any credential previously committed to the old repository.
- Take a live cluster and Argo CD Application snapshot.
- Keep the existing demo Deployment healthy until the external repository image is proven.

## Migration

1. Create `stonetusker/tusker-demo-notification-service` from the application ZIP as a clean public or private repository.
2. Enable Actions read/write permissions and workflow-created pull requests.
3. Configure Kubernetes GitHub credentials with `scripts/backstage/configure-github-platform-secret.sh`.
4. Sync `external-secrets` and `github-access`; verify the ClusterSecretStore.
5. Push application `main` and confirm tests, scans and immutable GHCR publication pass.
6. Merge the application release PR so the development overlay references the immutable SHA.
7. Replace the platform repository contents with the platform ZIP and run `make validate`.
8. Confirm the demo Argo CD Application points to the external repository and deploys an `ExternalSecret` for GHCR credential materialization.
9. Push the platform repository and hard-refresh `platform-root`.
10. Wait for `demo-service-development/ghcr-pull-secret`, then sync the application.
11. Verify the browser UI, health, readiness, metrics, logs and Backstage tabs.

## Rollback

Revert the platform Application source or the application release SHA. Do not delete the previous image or Git revision during the migration window.

# GitOps operating model

## Principles

- Changes enter the cluster through reviewed Git commits.
- Argo CD continuously compares desired and live state.
- Automated synchronization may be enabled for development.
- Production promotion should use immutable image references and an approval gate.
- Manual cluster changes are treated as drift, not as the source of truth.

## Demonstration

1. Change the demo-service HTML content in Git.
2. Commit and push.
3. Observe Argo CD move to `OutOfSync` and then `Synced`.
4. Refresh the service page and verify the new version.
5. Manually change the replica count.
6. Observe Argo CD restore the Git-declared replica count.

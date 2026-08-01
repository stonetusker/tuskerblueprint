# Git history secret remediation

The source archive used to prepare these repositories contained historical files that matched secret-scanning rules. Creating these clean repository snapshots prevents those deleted files from entering a new repository, but copying the new files over an existing Git repository does not remove old commits.

## Required response

1. Rotate every credential that was ever committed, including Argo CD administrator credentials, repository credentials, webhook secrets, and backend secrets.
2. Create the split repositories from these clean ZIP snapshots, or rewrite the existing repository history with `git filter-repo` and coordinate a force-push.
3. Revoke old tokens and keys before enabling the demo for another user.
4. Run a full-history Gitleaks scan as a separate security operation.
5. Keep application CI scoped to current source so an application release is not blocked by unrelated platform history.

Do not treat Base64-encoded Kubernetes Secret values as encrypted values.

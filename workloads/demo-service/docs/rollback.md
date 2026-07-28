# Rollback

Rollback is performed through Git, not through a permanent manual cluster edit.

## Procedure

1. Identify the last known good Git SHA.
2. Update the development overlay with `scripts/demo/set-demo-release.py`.
3. Open and review a rollback pull request.
4. Merge the pull request.
5. Wait for Argo CD synchronization and deployment health.
6. Verify the root response, readiness, metrics, and logs.

Example:

```bash
python3 scripts/demo/set-demo-release.py \
  --environment development \
  --release <40-character-good-sha>
```

The rollback commit and Argo CD history provide the evidence trail.

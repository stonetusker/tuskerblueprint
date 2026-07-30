## Summary

Describe the change and the user or platform outcome.

## Repository paths changed

List the exact paths changed from the repository root.

## Risk and security

- [ ] No secret values, private keys, tokens, kubeconfigs, or Terraform state are included.
- [ ] Runtime permissions remain least privilege.
- [ ] Image and dependency changes are pinned and reviewed.

## Validation

- [ ] `PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_idp.py`
- [ ] `find scripts -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n`
- [ ] Relevant Helm or Kustomize rendering completed.
- [ ] Relevant workload tests completed.

## Rollout

Describe the GitOps reconciliation order and operational checks.

## Rollback

Describe the Git revert or values-file rollback procedure.

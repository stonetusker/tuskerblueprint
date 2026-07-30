# Security

The default workload uses:

- a non-root UID and GID;
- a read-only root filesystem;
- dropped Linux capabilities;
- `RuntimeDefault` seccomp;
- disabled service-account token mounting;
- resource requests and limits;
- liveness, readiness, and startup probes;
- a default-deny NetworkPolicy with explicit HTTP ingress;
- a PodDisruptionBudget.

No secrets are included in the generated repository. Add runtime secrets through an approved Kubernetes secret-management path.

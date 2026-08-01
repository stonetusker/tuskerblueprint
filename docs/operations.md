# Operations

The platform repository contains read-only preflight, status, traffic, drift and recovery scripts under `scripts/demo/`. Application source changes and release-tag changes are made in the application repository.

For the maintained demo:

```bash
scripts/demo/preflight.sh
scripts/demo/open-demo-ui.sh
scripts/demo/generate-traffic.sh
scripts/demo/introduce-drift.sh
scripts/demo/verify-recovery.sh
```

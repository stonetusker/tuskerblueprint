# External Secrets Operator

External Secrets Operator synchronizes approved runtime credentials into workload namespaces. TuskerBlueprint uses its Kubernetes provider to read the central `platform-secrets/ghcr-pull-credentials` Secret and create namespace-local `ghcr-pull-secret` resources for Backstage and generated workloads.

The source Secret is created interactively by `scripts/backstage/configure-github-platform-secret.sh`; it is never committed. The store ServiceAccount has access only to that named source Secret plus the SelfSubjectRulesReview permission required by the provider.

The operator remains available for future external backends, but private GitHub/GHCR support does not depend on Doppler or another external SaaS.

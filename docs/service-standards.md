# Service standards

A service is considered platform-ready when it satisfies the following checks.

| Area | Requirement |
| --- | --- |
| Ownership | Valid Backstage Group owns the component |
| Catalog | Component, System, and API relationships resolve |
| Documentation | TechDocs and operational runbook render |
| Source | Repository link and metadata are present |
| CI | Tests, linting, image build, and security scan run |
| Supply chain | Image tag is immutable for promoted environments |
| Kubernetes | Requests, limits, probes, and restricted security context exist |
| Availability | Rolling update and PodDisruptionBudget are defined |
| Network | NetworkPolicy exists |
| GitOps | Argo CD Application is healthy and synced |
| Runtime | Kubernetes resources are visible in Backstage |
| API | OpenAPI is registered when applicable |
| Security | Secrets are externalized and least privilege is applied |
| Operations | Dashboard, alerts, and runbook are linked |

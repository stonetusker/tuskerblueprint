# TuskerBlueprint IDP changelog

## 2026-07-31: Split-repository developer workflow

- Moved the maintained demo application into `stonetusker/tusker-demo-notification-service`.
- Updated Argo CD Applications to read service-owned Kustomize overlays.
- Updated the Backstage golden path to create one repository per service.
- Added GitHub Free-compatible CI/CD, security evidence and immutable release PRs.
- Added external catalog registration for the maintained demo service.
- Removed embedded demo source and obsolete monorepo scripts and reports.
- Updated setup, migration, operations and developer-demo documentation.

# Backstage

Backstage uses GitHub OAuth for user sign-in and a separate platform credential for repository operations. Both values are stored in Kubernetes Secrets, not Git.

The Tusker Service template asks for repository visibility and supports `private` or `public`. The scaffolder creates the repository, grants the selected developer push access, registers the catalog entity and opens a platform onboarding PR.

The Backstage container itself uses `backstage/ghcr-pull-secret`, so its GHCR package may also remain private.

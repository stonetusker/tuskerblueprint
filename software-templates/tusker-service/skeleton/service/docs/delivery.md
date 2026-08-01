# Delivery and GitOps

The application repository owns code, testing, image publication and environment overlays. The platform repository owns the Argo CD Application object and shared cluster services.

1. A developer opens a pull request.
2. CI runs quality and security gates.
3. A merge to `main` publishes `ghcr.io/${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}:<full-sha>`.
4. CI opens a release pull request in this repository.
5. A maintainer reviews and merges the immutable image update.
6. Argo CD detects the overlay change and reconciles `${{ values.name }}-development`.

The workflow intentionally uses normal artifacts instead of GitHub Code Scanning uploads so it works on GitHub Free private repositories.

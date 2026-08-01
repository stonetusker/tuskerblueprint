# Deployment

The service repository owns Kustomize overlays under `deploy/overlays/`. CI publishes:

```text
ghcr.io/${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}:<full-git-sha>
ghcr.io/${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}:main
```

The immutable SHA is promoted by a release pull request. The platform repository stores the Argo CD Application:

```text
Repository: https://github.com/${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}.git
Path:       deploy/overlays/development
Namespace:  ${{ values.name }}-development
```

The generated `ExternalSecret` creates `ghcr-pull-secret`; the workload ServiceAccount references it. The same manifest supports public and private packages.

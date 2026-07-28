# Demo service Argo CD applications

`application-development.yaml` is active through this directory's
`kustomization.yaml` and retains automated sync for the live demo environment.

Staging and production Application manifests are intentionally present but not
included yet. Activate them only after the development release, image pull
credentials, observability, and rollback have been proven:

```yaml
resources:
  - application-development.yaml
  - application-staging.yaml
  - application-production.yaml
```

Staging and production do not enable automated sync. Promotion is therefore a
reviewed Git change followed by an explicit Argo CD sync.

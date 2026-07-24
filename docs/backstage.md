# Backstage implementation

## Capabilities

The repository includes configuration and source scaffolding for:

- GitHub authentication
- Software Catalog
- Catalog import
- TechDocs
- Search
- Software Templates
- Kubernetes visibility
- Argo CD visibility
- API documentation
- GitHub Actions visibility
- Permission-policy extension points

## Deployment modes

- `platform-services/backstage/values/development.yaml` preserves the currently working stock Backstage image.
- `platform-services/backstage/values/development-idp.yaml` switches to the custom IDP image after the image workflow succeeds.

This staged design prevents an image-build problem from breaking the existing portal.

## Local access

Backstage is accessed through a local port-forward:

```bash
kubectl port-forward -n backstage svc/backstage 7007:7007
```

Argo CD is accessed through:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

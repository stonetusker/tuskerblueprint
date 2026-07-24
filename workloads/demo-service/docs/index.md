# TuskerBlueprint Demo Service

The demo service is a deliberately small HTTP workload used to show Git-driven
release, Argo CD reconciliation, Kubernetes health, drift correction, Backstage
ownership, and security controls.

## Ownership

- Owner: Stonetusker Platform Engineering
- System: TuskerBlueprint
- Lifecycle: Experimental reference workload

## Release

Edit `base/content/index.html` in a branch, open a pull request, pass validation,
and merge. Argo CD detects the new Git revision and rolls the Deployment.

## Runtime

```bash
kubectl -n demo-service-development get deployment,pod,service \
  -l app.kubernetes.io/name=demo-service
kubectl -n demo-service-development port-forward service/demo-service 8080:80
```

## Rollback

Revert the release commit in Git. Do not make the rollback permanent through a
manual `kubectl` image change.

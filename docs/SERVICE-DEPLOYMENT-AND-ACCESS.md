# Service deployment and access model

This document explains where Argo CD deploys the maintained demo service and
services created through the **Tusker Service** Backstage golden path, which Git
repositories Argo CD reads, and how users and workloads access each application.

## Maintained demo service

The Application manifest is maintained at:

```text
gitops/applications/workloads/demo-service/application-development.yaml
```

Argo CD reads this path from the TuskerBlueprint repository:

```text
workloads/demo-service/overlays/development
```

It deploys the workload into:

```text
Namespace:   demo-service-development
Deployment:  demo-service
Service:     demo-service
Argo app:    demo-service-development
```

The Kubernetes Service is `ClusterIP`. It is intentionally not exposed directly
to the public internet.

### Browser access from the operator laptop

Run:

```bash
scripts/demo/open-demo-ui.sh
```

Then open:

```text
http://localhost:8081/
```

The script performs this port-forward:

```bash
kubectl -n demo-service-development port-forward service/demo-service 8081:80
```

Other endpoints remain available through the same port-forward:

```text
Application UI: http://localhost:8081/
OpenAPI UI:     http://localhost:8081/docs
Health:         http://localhost:8081/healthz
Readiness:      http://localhost:8081/readyz
Metrics:        http://localhost:8081/metrics
```

## Services created by Backstage

The generic namespace convention is:

```text
<service-name>-development
```

When a developer creates `customer-orders-api`, the Backstage task performs two
separate Git operations:

1. It creates `stonetusker/customer-orders-api` with source, tests, CI/CD,
   TechDocs, OpenAPI and Kubernetes overlays.
2. It opens a pull request in `stonetusker/tuskerblueprint` that adds:

   ```text
   gitops/generated-workloads/customer-orders-api/application.yaml
   ```

The `generated-workloads` Argo CD Application reads only the generated
Application manifests from TuskerBlueprint. After the onboarding pull request is
merged, the generated `customer-orders-api-development` Application reads only:

```text
Repository: stonetusker/customer-orders-api
Path:       deploy/overlays/development
Revision:   main
```

Argo CD does not clone arbitrary or unrelated service repositories. It reads only
the repositories explicitly declared in Argo CD Application resources.

The generated service is deployed into:

```text
Namespace:   customer-orders-api-development
Deployment:  customer-orders-api
Service:     customer-orders-api
Argo app:    customer-orders-api-development
```

Every generated namespace receives these labels from Argo CD:

```yaml
platform.stonetusker.com/workload: "true"
app.kubernetes.io/environment: development
```

Those labels are used by NetworkPolicies to permit approved workload-to-workload
communication without opening services to every namespace. The generated service
policy also permits DNS resolution through `kube-system` and egress only to other
approved workload namespaces. Arbitrary internet egress remains denied.

## In-cluster access

A Pod in the same namespace can call the maintained demo service with:

```text
http://demo-service
```

A Pod in another approved workload namespace can call it with:

```text
http://demo-service.demo-service-development.svc.cluster.local
```

A generated service can be called in the same way:

```text
http://customer-orders-api.customer-orders-api-development.svc.cluster.local
```

Example from an approved workload Pod:

```bash
curl http://demo-service.demo-service-development.svc.cluster.local/healthz
```

The caller namespace must carry:

```yaml
platform.stonetusker.com/workload: "true"
```

## External access choices

The reference environment defaults to `ClusterIP` and port-forwarding. This is
appropriate for a controlled laptop demonstration because it avoids exposing
unfinished example services publicly.

A customer implementation can add one of these through GitOps:

1. A Traefik `Ingress` or `IngressRoute` with DNS and TLS.
2. An API gateway route with authentication and rate limiting.
3. A private load balancer reachable only from the corporate network.

Do not change the Service to `NodePort` merely for the demo. Port-forwarding is
safer and makes the access boundary explicit.

## Private repository note

The generated demo path uses a public GitHub repository so Argo CD can read the
new service repository without creating another credential during the live demo.
For private generated repositories, configure an Argo CD GitHub App or
repository credential template that has read-only access to the intended
organization repositories.

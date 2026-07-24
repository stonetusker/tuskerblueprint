# Architecture

## Control flow

```text
Developer
  |
  v
Backstage IDP
  |-- Catalog and ownership
  |-- TechDocs and API documentation
  |-- Software Templates
  |-- Kubernetes runtime view
  `-- Argo CD deployment view
        |
        v
Private GitHub repositories
        |
        v
Argo CD reconciliation
        |
        v
Kubernetes workloads
        |
        v
Prometheus, Grafana, and Loki
```

## Trust boundaries

- Backstage receives a dedicated read credential for catalog and documentation access.
- Software Templates use a separate GitHub credential with only the write permissions required for repository creation and pull requests.
- Backstage receives a dedicated read-only Argo CD API token.
- Kubernetes access is provided through a read-only ServiceAccount and ClusterRole.
- Secret values are not committed to Git. Kubernetes Secrets are created at runtime or synchronized through External Secrets.

## Source-of-truth model

- Git is the desired-state source for platform and workload configuration.
- Argo CD is the reconciliation control plane.
- Backstage is the developer experience and metadata layer.
- Kubernetes is the runtime control plane.
- Observability systems provide evidence about runtime behavior.

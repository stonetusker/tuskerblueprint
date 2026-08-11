# Grafana

## Purpose

Grafana provides dashboards and visualization for the TuskerBlueprint platform.

It is intended to be deployed through Argo CD using a pinned Helm chart and environment-specific values stored in Git.

## Ownership

| Component | Owner |
| --------- | ----- |
| Deployment | Git → Argo CD |
| Configuration | Git |
| Helm chart | Upstream Grafana |

## Notes

- Grafana should be deployed after Prometheus and Loki are available.
- It should provide dashboards for cluster and workload visibility.
- Authentication and ingress should be handled through the platform security and networking stacks.

## Development service dashboard

values/development.yaml provisions **Stonetusker Demo / Tusker Service
Overview** from Git. The environment and service variables make one dashboard
work for the hand-built demo and every service produced by the golden path.

The service must expose these Prometheus series and labels:

- application_info with service, environment and version labels
- http_requests_total with service, environment, method, route and status labels
- http_request_duration_seconds_bucket with service, environment, route and le labels
- notification_requests_total with service, environment and channel labels

For local demo access:

```bash
kubectl -n grafana port-forward service/grafana 3000:80
```

Then open **Grafana → Dashboards → Stonetusker Demo → Tusker Service Overview**.
The logs panel additionally requires Loki and a validated log collector such as Alloy.

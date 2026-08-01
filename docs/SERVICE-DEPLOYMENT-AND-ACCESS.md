# Service deployment and access

`demo-service-development` is declared by the platform repository and sourced from `https://github.com/stonetusker/tusker-demo-notification-service.git`, path `deploy/overlays/development`.

Laptop access:

```bash
kubectl -n demo-service-development port-forward service/demo-service 8081:80
```

In-cluster access:

```text
http://demo-service.demo-service-development.svc.cluster.local
```

Newly generated services follow the same convention: `<name>-development`, service `<name>`, source path `deploy/overlays/development` in the generated application repository.

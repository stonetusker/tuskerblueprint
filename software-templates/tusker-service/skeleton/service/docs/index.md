# ${{ values.name }}

${{ values.description }}

This service was created through the TuskerBlueprint golden path and includes a
small browser UI at `/`, a FastAPI backend, CI/CD, GitOps, OpenAPI, TechDocs,
metrics, structured logs and Kubernetes runtime controls.

## Local experience

```bash
uvicorn src.main:app --reload --port ${{ values.port }}
```

Open:

```text
Application UI: http://localhost:${{ values.port }}/
API docs:       http://localhost:${{ values.port }}/docs
```

## Deployed experience

```bash
kubectl -n ${{ values.name }}-development port-forward \
  service/${{ values.name }} 8082:80
```

Open `http://localhost:8082/`.

#!/usr/bin/env bash
set -euo pipefail

kubectl scale deployment demo-service \
  --namespace demo-service-development \
  --replicas=1

echo "Introduced replica drift. Watch Argo CD restore the Git-declared count."
kubectl get deployment demo-service -n demo-service-development -w

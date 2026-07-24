#!/usr/bin/env bash
set -euo pipefail

printf '\nArgo CD applications\n'
kubectl get applications -n argocd

printf '\nBackstage\n'
kubectl get deployment,pod,service -n backstage

printf '\nDemo service\n'
kubectl get deployment,pod,service -n demo-service-development \
  -l app.kubernetes.io/name=demo-service

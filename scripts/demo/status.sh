#!/usr/bin/env bash
set -euo pipefail

printf '\nArgo CD applications\n'
kubectl get applications -n argocd

printf '\nBackstage\n'
kubectl get deployment,pod,service -n backstage

printf '\nDemo service\n'
kubectl get deployment,pod,service -n demo-service-development \
  -l app.kubernetes.io/name=demo-service

printf '\nRelease\n'
kubectl -n demo-service-development get deployment demo-service \
  -o jsonpath='image={.spec.template.spec.containers[0].image}{"\n"}release={.spec.template.metadata.annotations.tuskerblueprint\.io/release-sha}{"\n"}'

printf '\nFailure mode\n'
kubectl -n demo-service-development get configmap \
  -l app.kubernetes.io/name=demo-service \
  -o jsonpath='{range .items[*]}{.metadata.name}{" mode="}{.data.DEMO_FAILURE_MODE}{"\n"}{end}'

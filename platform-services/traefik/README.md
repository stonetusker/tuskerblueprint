# Traefik

## Purpose

Traefik is the platform ingress controller.

## Owner

Git → Argo CD

## Chart

Traefik Helm Chart

## Configuration

Environment-specific configuration is located in:

values/
    development.yaml
    staging.yaml
    production.yaml

## Validation

kubectl get pods -n traefik

kubectl get ingressclass

kubectl get svc -n traefik

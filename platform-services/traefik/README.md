# Traefik

## Purpose

Traefik is the platform ingress controller for TuskerBlueprint.

## Ownership

Git → Argo CD

## Deployment

Official Traefik Helm Chart

## Configuration

Environment values are stored under:

values/

## Validation

kubectl get pods -n traefik

kubectl get svc -n traefik

kubectl get ingressclass

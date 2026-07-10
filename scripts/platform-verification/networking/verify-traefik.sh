#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: verify-traefik.sh
#
# Purpose:
#     Verify the Traefik platform capability.
#
# Responsibilities:
#     - Verify Argo CD application
#     - Verify Kubernetes resources
#     - Verify networking capability readiness
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

################################################################################
# Traefik Verification
################################################################################

header "Traefik Verification"

section "Argo CD"

verify_application "${APP_TRAEFIK}"
verify_application_synced "${APP_TRAEFIK}"
verify_application_healthy "${APP_TRAEFIK}"

section "Kubernetes"

verify_namespace "${NS_TRAEFIK}"

verify_deployment \
    "${NS_TRAEFIK}" \
    "traefik"

verify_deployment_ready \
    "${NS_TRAEFIK}" \
    "traefik"

verify_service \
    "${NS_TRAEFIK}" \
    "traefik"

verify_pods \
    "${NS_TRAEFIK}"

section "Ingress"

verify_ingressclass "traefik"

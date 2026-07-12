#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: verify-cert-manager.sh
#
# Purpose:
#     Verify the cert-manager platform capability.
#
# Responsibilities:
#     - Verify Argo CD application
#     - Verify cert-manager Kubernetes resources
#     - Verify cert-manager CRDs and API discovery
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

################################################################################
# cert-manager Verification
################################################################################

header "cert-manager Verification"

section "Argo CD"

verify_application "${APP_CERT_MANAGER}"
verify_application_synced "${APP_CERT_MANAGER}"
verify_application_healthy "${APP_CERT_MANAGER}"

section "Kubernetes"

verify_namespace "${NS_CERT_MANAGER}"

verify_deployment \
    "${NS_CERT_MANAGER}" \
    "${DEP_CERT_MANAGER}"

verify_deployment_ready \
    "${NS_CERT_MANAGER}" \
    "${DEP_CERT_MANAGER}"

verify_service \
    "${NS_CERT_MANAGER}" \
    "${SVC_CERT_MANAGER}"

verify_deployment \
    "${NS_CERT_MANAGER}" \
    "${DEP_CERT_MANAGER_WEBHOOK}"

verify_deployment_ready \
    "${NS_CERT_MANAGER}" \
    "${DEP_CERT_MANAGER_WEBHOOK}"

verify_service \
    "${NS_CERT_MANAGER}" \
    "${SVC_CERT_MANAGER_WEBHOOK}"

verify_deployment \
    "${NS_CERT_MANAGER}" \
    "${DEP_CERT_MANAGER_CAINJECTOR}"

verify_deployment_ready \
    "${NS_CERT_MANAGER}" \
    "${DEP_CERT_MANAGER_CAINJECTOR}"

verify_service \
    "${NS_CERT_MANAGER}" \
    "${SVC_CERT_MANAGER_CAINJECTOR}"

verify_pods "${NS_CERT_MANAGER}"

section "CRDs"

for crd in "${CERT_MANAGER_CRDS[@]}"; do
    verify_crd "${crd}"
done

section "API Readiness"

verify_api_path \
    "cert-manager.io/v1" \
    "${CERT_MANAGER_API_PATH}"

verify_api_path \
    "acme.cert-manager.io/v1" \
    "${CERT_MANAGER_ACME_API_PATH}"

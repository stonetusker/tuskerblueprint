#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: verify-external-secrets.sh
#
# Purpose:
#     Verify the External Secrets Operator capability.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

header "External Secrets Operator Verification"

section "Argo CD"

verify_application "${APP_EXTERNAL_SECRETS}"
verify_application_synced "${APP_EXTERNAL_SECRETS}"
verify_application_healthy "${APP_EXTERNAL_SECRETS}"

section "Kubernetes"

verify_namespace "${NS_EXTERNAL_SECRETS}"
verify_pods "${NS_EXTERNAL_SECRETS}"

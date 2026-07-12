#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: verify-doppler.sh
#
# Purpose:
#     Verify the Doppler capability.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

header "Doppler Verification"

section "Argo CD"

verify_application "${APP_DOPPLER}"
verify_application_synced "${APP_DOPPLER}"
verify_application_healthy "${APP_DOPPLER}"

section "Kubernetes"

verify_namespace "doppler"
verify_pods "doppler"

#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: verify-loki.sh
#
# Purpose:
#     Verify the Loki capability.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

header "Loki Verification"

section "Argo CD"

verify_application "loki"
verify_application_synced "loki"
verify_application_healthy "loki"

section "Kubernetes"

verify_namespace "monitoring"
verify_pods "monitoring"

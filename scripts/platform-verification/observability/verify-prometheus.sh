#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: verify-prometheus.sh
#
# Purpose:
#     Verify the Prometheus capability.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

header "Prometheus Verification"

section "Argo CD"

verify_application "prometheus"
verify_application_synced "prometheus"
verify_application_healthy "prometheus"

section "Kubernetes"

verify_namespace "monitoring"
verify_pods "monitoring"

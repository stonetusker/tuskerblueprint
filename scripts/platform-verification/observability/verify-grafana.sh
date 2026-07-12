#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: verify-grafana.sh
#
# Purpose:
#     Verify the Grafana capability.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

header "Grafana Verification"

section "Argo CD"

verify_application "grafana"
verify_application_synced "grafana"
verify_application_healthy "grafana"

section "Kubernetes"

verify_namespace "grafana"
verify_pods "grafana"

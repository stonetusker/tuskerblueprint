#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: verify-backstage.sh
#
# Purpose:
#     Verify the Backstage capability.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

header "Backstage Verification"

section "Argo CD"

verify_application "backstage"
verify_application_synced "backstage"
verify_application_healthy "backstage"

section "Kubernetes"

verify_namespace "backstage"
verify_pods "backstage"

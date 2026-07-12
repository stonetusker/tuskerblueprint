#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: verify-kyverno.sh
#
# Purpose:
#     Verify the Kyverno capability.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

header "Kyverno Verification"

section "Argo CD"

verify_application "kyverno"
verify_application_synced "kyverno"
verify_application_healthy "kyverno"

section "Kubernetes"

verify_namespace "kyverno"
verify_pods "kyverno"

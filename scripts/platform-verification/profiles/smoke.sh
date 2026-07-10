#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: smoke.sh
#
# Purpose:
#     Executes the smoke verification profile.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

header "Smoke Verification"

readonly PROFILE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

################################################################################
# Networking
################################################################################

source "${PROFILE_SCRIPT_DIR}/../networking/verify-traefik.sh"

################################################################################
# Future
################################################################################

#
# Security
#
# ../security/verify-cert-manager.sh
#
# ../security/verify-external-secrets.sh
#
# Observability
#
# ../observability/verify-prometheus.sh
#
# Developer Platform
#
# ../developer-platform/verify-backstage.sh
#

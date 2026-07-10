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

################################################################################
# Networking
################################################################################

"$(dirname "$0")"/../networking/verify-traefik.sh

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

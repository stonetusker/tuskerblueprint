#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: regression.sh
#
# Purpose:
#     Execute the complete platform verification suite.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

header "Regression Verification"

readonly PROFILE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################################################
# Networking
###############################################################################

source "${PROFILE_SCRIPT_DIR}/../networking/verify-traefik.sh"

###############################################################################
# Security
###############################################################################

source "${PROFILE_SCRIPT_DIR}/../security/verify-cert-manager.sh"
source "${PROFILE_SCRIPT_DIR}/../security/verify-external-secrets.sh"
#source "${PROFILE_SCRIPT_DIR}/../security/verify-doppler.sh"
source "${PROFILE_SCRIPT_DIR}/../security/verify-kyverno.sh"
# "$(dirname "$0")"/../security/verify-kyverno.sh

###############################################################################
# Observability
###############################################################################

# "$(dirname "$0")"/../observability/verify-prometheus.sh
# "$(dirname "$0")"/../observability/verify-grafana.sh
# "$(dirname "$0")"/../observability/verify-loki.sh

###############################################################################
# Developer Platform
###############################################################################

# "$(dirname "$0")"/../developer-platform/verify-backstage.sh

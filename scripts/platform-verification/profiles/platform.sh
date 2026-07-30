#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: platform.sh
#
# Purpose:
#     Execute verification for all implemented platform capabilities.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

header "Platform Verification"

readonly PROFILE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${PROFILE_SCRIPT_DIR}/../networking/verify-traefik.sh"
source "${PROFILE_SCRIPT_DIR}/../security/verify-cert-manager.sh"
source "${PROFILE_SCRIPT_DIR}/../security/verify-external-secrets.sh"
#source "${PROFILE_SCRIPT_DIR}/../security/verify-doppler.sh"
source "${PROFILE_SCRIPT_DIR}/../security/verify-kyverno.sh"

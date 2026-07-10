#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: pre-upgrade.sh
#
# Purpose:
#     Execute verification before platform upgrades.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

header "Pre-Upgrade Verification"

"$(dirname "$0")"/regression.sh

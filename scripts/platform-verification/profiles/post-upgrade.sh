#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: post-upgrade.sh
#
# Purpose:
#     Execute verification after platform upgrades.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

header "Post-Upgrade Verification"

"$(dirname "$0")"/regression.sh

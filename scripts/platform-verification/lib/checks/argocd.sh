#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: checks/argocd.sh
#
# Purpose:
#     Argo CD verification checks.
#
# Responsibilities:
#     - Evaluate Argo CD state
#     - Return success/failure only
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

################################################################################
# Application
################################################################################

check_application() {

    local application="$1"

    application_exists "${application}"
}

check_application_synced() {

    local application="$1"

    application_synced "${application}"
}

check_application_healthy() {

    local application="$1"

    application_healthy "${application}"
}

################################################################################
# Project
################################################################################

check_project() {

    local project="$1"

    project_exists "${project}"
}

################################################################################
# Repository
################################################################################

check_repository() {

    local repository_secret="$1"

    repository_registered "${repository_secret}"
}

#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: argocd-api.sh
#
# Purpose:
#     Thin wrapper around Kubernetes for Argo CD resources.
#
# Responsibilities:
#     - Query Argo CD Applications
#     - Query AppProjects
#     - Return normalized results
#
# This library never prints output and never exits.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

################################################################################
# Applications
################################################################################

application_exists() {

    local application="$1"

    kube get applications.argoproj.io \
        "${application}" \
        -n "${NS_ARGOCD}" \
        >/dev/null 2>&1
}

################################################################################
# Application Sync Status
################################################################################

application_synced() {

    local application="$1"

    [[ "$(
        kube get applications.argoproj.io \
            "${application}" \
            -n "${NS_ARGOCD}" \
            -o jsonpath='{.status.sync.status}' \
            2>/dev/null
    )" == "Synced" ]]
}

################################################################################
# Application Health
################################################################################

application_healthy() {

    local application="$1"

    [[ "$(
        kube get applications.argoproj.io \
            "${application}" \
            -n "${NS_ARGOCD}" \
            -o jsonpath='{.status.health.status}' \
            2>/dev/null
    )" == "Healthy" ]]
}

################################################################################
# Project
################################################################################

project_exists() {

    local project="$1"

    kube get appproject \
        "${project}" \
        -n "${NS_ARGOCD}" \
        >/dev/null 2>&1
}

################################################################################
# Repository Secret
################################################################################

repository_registered() {

    local secret="$1"

    kube get secret \
        "${secret}" \
        -n "${NS_ARGOCD}" \
        >/dev/null 2>&1
}

################################################################################
# End of File
################################################################################

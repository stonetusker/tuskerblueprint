#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: kubernetes-api.sh
#
# Purpose:
#     Thin wrapper around the Kubernetes API used by the verification framework.
#
# Responsibilities:
#     - Execute Kubernetes API queries
#     - Return normalized results
#     - Never print output
#     - Never exit the program
#
# Contract:
#     - Never print PASS/FAIL
#     - Never call exit
#     - Never perform verification logic
#     - Never format output
#     - Return command exit status only
#
# All Kubernetes interactions MUST use the kube() executor.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

################################################################################
# Cluster
################################################################################

cluster_available() {

    kube version \
        >/dev/null 2>&1

}

################################################################################
# Core Resources
################################################################################

namespace_exists() {

    local namespace="$1"

    kube get namespace \
        "${namespace}" \
        >/dev/null 2>&1

}

################################################################################
# Workloads
################################################################################

deployment_exists() {

    local namespace="$1"
    local deployment="$2"

    kube get deployment \
        "${deployment}" \
        -n "${namespace}" \
        >/dev/null 2>&1

}

deployment_ready() {

    local namespace="$1"
    local deployment="$2"

    kube rollout status \
        "deployment/${deployment}" \
        -n "${namespace}" \
        --timeout="${DEFAULT_REQUEST_TIMEOUT_SECONDS}s" \
        >/dev/null 2>&1

}

daemonset_exists() {

    local namespace="$1"
    local daemonset="$2"

    kube get daemonset \
        "${daemonset}" \
        -n "${namespace}" \
        >/dev/null 2>&1

}

statefulset_exists() {

    local namespace="$1"
    local statefulset="$2"

    kube get statefulset \
        "${statefulset}" \
        -n "${namespace}" \
        >/dev/null 2>&1

}

pods_exist() {

    local namespace="$1"

    [[ -n "$(
        kube get pods \
            -n "${namespace}" \
            -o name \
            2>/dev/null
    )" ]]

}

################################################################################
# Networking
################################################################################

service_exists() {

    local namespace="$1"
    local service="$2"

    kube get service \
        "${service}" \
        -n "${namespace}" \
        >/dev/null 2>&1

}

ingress_exists() {

    local namespace="$1"
    local ingress="$2"

    kube get ingress \
        "${ingress}" \
        -n "${namespace}" \
        >/dev/null 2>&1

}

ingressclass_exists() {

    local ingressclass="$1"

    kube get ingressclass \
        "${ingressclass}" \
        >/dev/null 2>&1

}

################################################################################
# Configuration
################################################################################

configmap_exists() {

    local namespace="$1"
    local configmap="$2"

    kube get configmap \
        "${configmap}" \
        -n "${namespace}" \
        >/dev/null 2>&1

}

################################################################################
# Security
################################################################################

secret_exists() {

    local namespace="$1"
    local secret="$2"

    kube get secret \
        "${secret}" \
        -n "${namespace}" \
        >/dev/null 2>&1

}

################################################################################
# Extensions
################################################################################

crd_exists() {

    local crd="$1"

    kube get crd \
        "${crd}" \
        >/dev/null 2>&1

}

################################################################################
# End of File
################################################################################

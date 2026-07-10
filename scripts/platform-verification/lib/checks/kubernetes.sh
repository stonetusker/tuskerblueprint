#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: checks/kubernetes.sh
#
# Purpose:
#     Kubernetes verification checks.
#
# Responsibilities:
#     - Evaluate Kubernetes resource state
#     - Return success/failure only
#
# No output.
# No colours.
# No exits.
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

################################################################################
# Namespace
################################################################################

check_namespace() {

    local namespace="$1"

    namespace_exists "${namespace}"

}

################################################################################
# Deployment
################################################################################

check_deployment() {

    local namespace="$1"
    local deployment="$2"

    deployment_exists "${namespace}" "${deployment}"

}

check_deployment_ready() {

    local namespace="$1"
    local deployment="$2"

    deployment_ready "${namespace}" "${deployment}"

}

################################################################################
# DaemonSet
################################################################################

check_daemonset() {

    local namespace="$1"
    local daemonset="$2"

    daemonset_exists "${namespace}" "${daemonset}"

}

################################################################################
# StatefulSet
################################################################################

check_statefulset() {

    local namespace="$1"
    local statefulset="$2"

    statefulset_exists "${namespace}" "${statefulset}"

}

################################################################################
# Service
################################################################################

check_service() {

    local namespace="$1"
    local service="$2"

    service_exists "${namespace}" "${service}"

}

################################################################################
# Pods
################################################################################

check_pods() {

    local namespace="$1"

    pods_exist "${namespace}"

}

################################################################################
# Ingress
################################################################################

check_ingress() {

    local namespace="$1"
    local ingress="$2"

    ingress_exists "${namespace}" "${ingress}"

}

################################################################################
# IngressClass
################################################################################

check_ingressclass() {

    local ingressclass="$1"

    ingressclass_exists "${ingressclass}"

}

################################################################################
# ConfigMap
################################################################################

check_configmap() {

    local namespace="$1"
    local configmap="$2"

    configmap_exists "${namespace}" "${configmap}"

}

################################################################################
# Secret
################################################################################

check_secret() {

    local namespace="$1"
    local secret="$2"

    secret_exists "${namespace}" "${secret}"

}

################################################################################
# CRD
################################################################################

check_crd() {

    local crd="$1"

    crd_exists "${crd}"

}

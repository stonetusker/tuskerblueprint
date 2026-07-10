#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
# File: runtime.sh
#
# Runtime dependency and environment validation.
#
# This library validates the execution environment before any verification
# begins.
#
# Responsibilities:
#   - Required binaries
#   - Environment variables
#   - Kubeconfig
#   - Kubernetes connectivity
#   - Tool versions
#
# Platform-specific verification does not belong here.
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

################################################################################
# Runtime Dependencies
################################################################################

readonly REQUIRED_COMMANDS=(
    kubectl
    jq
    yq
)

################################################################################
# Dependency Validation
################################################################################

validate_dependencies() {

    section "Validating Runtime Dependencies"

    local failed=0

    for cmd in "${REQUIRED_COMMANDS[@]}"; do

        if command_exists "${cmd}"; then
            success "Found ${cmd}"
        else
            error "Missing required command: ${cmd}"
            failed=1
        fi

    done

    [[ "${failed}" -eq 0 ]] || exit "${EXIT_MISSING_DEPENDENCY}"
}

################################################################################
# Kubeconfig
################################################################################

validate_kubeconfig() {

    section "Validating kubeconfig"

    if [[ ! -f "${DEFAULT_KUBECONFIG}" ]]; then
        error "Kubeconfig not found"

        error "Expected: ${DEFAULT_KUBECONFIG}"

        exit "${EXIT_KUBERNETES_UNAVAILABLE}"
    fi

    export KUBECONFIG="${DEFAULT_KUBECONFIG}"

    success "Using kubeconfig"

    info "${KUBECONFIG}"
}

################################################################################
# Kubernetes Connectivity
################################################################################

validate_cluster() {

    section "Validating Kubernetes Connectivity"

    if kubectl version --request-timeout=10s >/dev/null 2>&1; then

        success "Connected to Kubernetes cluster"

    else

        error "Unable to communicate with Kubernetes"

        exit "${EXIT_KUBERNETES_UNAVAILABLE}"

    fi
}

################################################################################
# Cluster Information
################################################################################

display_cluster_information() {

    section "Cluster Information"

    info "Current Context : $(kube config current-context)"

    local version

    version="$(
        kube version -o json 2>/dev/null \
        | jq -r '.serverVersion.gitVersion // "Unknown"'
    )"

    info "Server Version  : ${version}"

}

################################################################################
# Runtime Validation
################################################################################

validate_runtime() {

    header "Runtime Validation"

    validate_dependencies

    validate_kubeconfig

    validate_cluster

    display_cluster_information
}

################################################################################
# End of File
################################################################################

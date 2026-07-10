#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

################################################################################
# Framework Directories
################################################################################

#readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#readonly FRAMEWORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
#readonly LIB_DIR="${FRAMEWORK_DIR}/lib"

################################################################################
# Runtime Directories
################################################################################

readonly TMP_DIR="$(mktemp -d)"

cleanup() {

    [[ -d "${TMP_DIR}" ]] && rm -rf "${TMP_DIR}"

}

trap cleanup EXIT

################################################################################
# Foundation
################################################################################

source "${LIB_DIR}/constants.sh"
source "${LIB_DIR}/state.sh"
source "${LIB_DIR}/output.sh"
source "${LIB_DIR}/common.sh"

################################################################################
# Infrastructure
################################################################################

source "${LIB_DIR}/executor.sh"
source "${LIB_DIR}/runtime.sh"

################################################################################
# Technology
################################################################################

source "${LIB_DIR}/kubernetes-api.sh"
source "${LIB_DIR}/argocd-api.sh"

################################################################################
# Checks
################################################################################

source "${LIB_DIR}/checks/kubernetes.sh"
source "${LIB_DIR}/checks/argocd.sh"

################################################################################
# Framework
################################################################################

source "${LIB_DIR}/verifiers.sh"
source "${LIB_DIR}/report.sh"

################################################################################
# Bootstrap
################################################################################

bootstrap_framework() {

    START_TIME="$(date +%s)"

    debug "Initializing ${FRAMEWORK_NAME}"
    debug "Framework Version : ${FRAMEWORK_VERSION}"
    debug "Framework Home    : ${FRAMEWORK_DIR}"
    debug "Temporary Dir     : ${TMP_DIR}"

}

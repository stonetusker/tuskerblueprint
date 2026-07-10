#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: common.sh
#
# Purpose:
#     Generic Bash helper functions shared across the verification framework.
#
# Responsibilities:
#     - Command helpers
#     - File and directory helpers
#     - String helpers
#     - Retry helpers
#     - Timing helpers
#     - Generic error handling
#
# This library intentionally contains NO platform-specific logic.
#
# It MUST NOT reference:
#   - Kubernetes
#   - Argo CD
#   - Helm
#   - GitHub
#   - Verification logic
#   - Runtime validation
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

################################################################################
# Command Helpers
################################################################################

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

require_command() {

    local command="$1"

    if ! command_exists "${command}"; then
        error "Required command not found: ${command}"
        exit "${EXIT_MISSING_DEPENDENCY}"
    fi
}

################################################################################
# File Helpers
################################################################################

file_exists() {
    [[ -f "$1" ]]
}

directory_exists() {
    [[ -d "$1" ]]
}

require_file() {

    local file="$1"

    if ! file_exists "${file}"; then
        error "Required file not found: ${file}"
        exit "${EXIT_FAILURE}"
    fi
}

require_directory() {

    local directory="$1"

    if ! directory_exists "${directory}"; then
        error "Required directory not found: ${directory}"
        exit "${EXIT_FAILURE}"
    fi
}

################################################################################
# String Helpers
################################################################################

is_empty() {
    [[ -z "${1:-}" ]]
}

is_not_empty() {
    [[ -n "${1:-}" ]]
}

join_by() {

    local delimiter="$1"
    shift

    local first=true

    for item in "$@"; do

        if [[ "${first}" == true ]]; then
            printf "%s" "${item}"
            first=false
        else
            printf "%s%s" "${delimiter}" "${item}"
        fi

    done
}

################################################################################
# Retry Helpers
################################################################################

retry() {

    local retries="$1"
    local delay="$2"

    shift 2

    local attempt=1

    until "$@"; do

        if (( attempt >= retries )); then
            return 1
        fi

        sleep "${delay}"

        ((attempt++))

    done

    return 0
}

################################################################################
# Generic Error Handling
################################################################################

die() {

    local message="$1"

    error "${message}"

    exit "${EXIT_FAILURE}"
}

################################################################################
# Time Helpers
################################################################################

current_timestamp() {
    date +%s
}

elapsed_seconds() {

    local start="$1"
    local end

    end="$(current_timestamp)"

    printf '%s\n' "$(( end - start ))"
}

################################################################################
# End of File
################################################################################

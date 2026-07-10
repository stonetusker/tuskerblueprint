#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
#
# File: report.sh
#
# Purpose:
#     Reporting utilities for verification execution.
#
# Responsibilities:
#     - Verification summary
#     - Execution statistics
#     - Runtime information
#     - Final framework exit status
#
# This library:
#     - Never communicates with Kubernetes
#     - Never performs verification
#     - Never modifies runtime state
#
# shellcheck shell=bash
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

################################################################################
# Execution Summary
################################################################################

print_summary() {

    section "Verification Summary"

    info "Profile           : ${CURRENT_PROFILE:-platform}"
    info "Capability        : ${CURRENT_CAPABILITY:-all}"

    printf '\n'

    info    "Total Checks      : ${VERIFICATION_TOTAL}"
    success "Passed            : ${VERIFICATION_PASSED}"

    if (( VERIFICATION_FAILED > 0 )); then
        error "Failed            : ${VERIFICATION_FAILED}"
    else
        success "Failed            : 0"
    fi

    if (( VERIFICATION_WARNINGS > 0 )); then
        warning "Warnings          : ${VERIFICATION_WARNINGS}"
    else
        info "Warnings          : 0"
    fi

    if (( VERIFICATION_SKIPPED > 0 )); then
        warning "Skipped           : ${VERIFICATION_SKIPPED}"
    else
        info "Skipped           : 0"
    fi
}

################################################################################
# Execution Time
################################################################################

print_execution_time() {

    finish_execution

    printf '\n'

    section "Execution"

    info "Duration          : $(execution_duration)s"

}

################################################################################
# Final Report
################################################################################

print_final_report() {

    print_summary

    print_execution_time

}

################################################################################
# Framework Exit
################################################################################

framework_exit() {

    print_final_report

    if (( VERIFICATION_FAILED > 0 )); then
        exit "${EXIT_CAPABILITY_FAILED}"
    fi

    exit "${EXIT_SUCCESS}"

}

################################################################################
# End of File
################################################################################

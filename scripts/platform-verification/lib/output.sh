#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
# File: output.sh
#
# Console output helper functions.
#
# All framework output should be produced through this library.
#
# Do not call echo directly from verification scripts unless outputting raw data.
# ==============================================================================


set -Eeuo pipefail
IFS=$'\n\t'

################################################################################
# ANSI Colors
################################################################################

readonly COLOR_RESET="\033[0m"

readonly COLOR_RED="\033[0;31m"
readonly COLOR_GREEN="\033[0;32m"
readonly COLOR_YELLOW="\033[1;33m"
readonly COLOR_BLUE="\033[0;34m"
readonly COLOR_CYAN="\033[0;36m"
readonly COLOR_WHITE="\033[1;37m"
readonly COLOR_GRAY="\033[0;90m"

################################################################################
# Symbols
################################################################################

readonly ICON_INFO="[INFO]"
readonly ICON_SUCCESS="[PASS]"
readonly ICON_WARNING="[WARN]"
readonly ICON_ERROR="[FAIL]"
readonly ICON_DEBUG="[DEBUG]"

################################################################################
# Runtime Flags
################################################################################

VERBOSE="${VERBOSE:-false}"
DEBUG="${DEBUG:-false}"

################################################################################
# Internal Helpers
################################################################################

_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

_print() {
    local color="$1"
    local prefix="$2"
    local message="$3"

    printf "%b%s %-7s%b %s\n" \
        "${color}" \
        "$(_timestamp)" \
        "${prefix}" \
        "${COLOR_RESET}" \
        "${message}"
}

################################################################################
# Public Output Functions
################################################################################

info() {
    _print "${COLOR_BLUE}" "${ICON_INFO}" "$*"
}

success() {
    _print "${COLOR_GREEN}" "${ICON_SUCCESS}" "$*"
}

warning() {
    _print "${COLOR_YELLOW}" "${ICON_WARNING}" "$*"
}

error() {
    _print "${COLOR_RED}" "${ICON_ERROR}" "$*"
}

debug() {

    [[ "${DEBUG}" != "true" ]] && return 0

    _print "${COLOR_GRAY}" "${ICON_DEBUG}" "$*"
}

################################################################################
# Headings
################################################################################

header() {

    printf '\n'
    printf "%b============================================================%b\n" \
        "${COLOR_CYAN}" \
        "${COLOR_RESET}"

    printf "%b%s%b\n" \
        "${COLOR_WHITE}" \
        "$*" \
        "${COLOR_RESET}"

    printf "%b============================================================%b\n" \
        "${COLOR_CYAN}" \
        "${COLOR_RESET}"

    printf '\n'
}

section() {

    printf '\n'

    printf "%b---- %s ----%b\n" \
        "${COLOR_CYAN}" \
        "$*" \
        "${COLOR_RESET}"

    printf '\n'
}

step() {

    info "$*"
}

################################################################################
# Summary
################################################################################

summary() {

    printf '\n'

    printf "%b============================================================%b\n" \
        "${COLOR_CYAN}" \
        "${COLOR_RESET}"

    printf "%bVerification Summary%b\n" \
        "${COLOR_WHITE}" \
        "${COLOR_RESET}"

    printf "%b============================================================%b\n" \
        "${COLOR_CYAN}" \
        "${COLOR_RESET}"

    printf '\n'
}

################################################################################
# Banner
################################################################################

banner() {

cat <<EOF

============================================================
 TuskerBlueprint Platform Verification Framework (TPVF)
============================================================

EOF

}

################################################################################
# End of File
################################################################################

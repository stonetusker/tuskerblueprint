#!/usr/bin/env bash
#
# ==============================================================================
# TuskerBlueprint Platform Verification Framework (TPVF)
# File: constants.sh
#
# Shared constants used throughout the verification framework.
#
# This file intentionally contains immutable values only.
#
# Do not place runtime configuration in this file.
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

################################################################################
# Framework Metadata
################################################################################

readonly FRAMEWORK_NAME="TuskerBlueprint Platform Verification Framework"
readonly FRAMEWORK_SHORT_NAME="TPVF"

readonly FRAMEWORK_VERSION="1.0.0"

################################################################################
# Exit Codes
################################################################################

readonly EXIT_SUCCESS=0

readonly EXIT_FAILURE=1

readonly EXIT_INVALID_ARGUMENT=2

readonly EXIT_MISSING_DEPENDENCY=3

readonly EXIT_KUBERNETES_UNAVAILABLE=4

readonly EXIT_ARGOCD_UNAVAILABLE=5

readonly EXIT_CAPABILITY_FAILED=6

readonly EXIT_INTERNAL_ERROR=99


################################################################################
# Timeouts
################################################################################

readonly DEFAULT_REQUEST_TIMEOUT_SECONDS=30

readonly DEFAULT_RETRY_COUNT=5

readonly DEFAULT_RETRY_INTERVAL_SECONDS=5

################################################################################
# Kubernetes
################################################################################

readonly DEFAULT_KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

################################################################################
# Namespaces
################################################################################

readonly NS_ARGOCD="argocd"

readonly NS_TRAEFIK="traefik"

readonly NS_CERT_MANAGER="cert-manager"

readonly NS_EXTERNAL_SECRETS="external-secrets"

readonly NS_KYVERNO="kyverno"

readonly NS_MONITORING="monitoring"

readonly NS_GRAFANA="grafana"

readonly NS_LOKI="loki"

readonly NS_BACKSTAGE="backstage"

################################################################################
# Argo CD Applications
################################################################################

readonly APP_PLATFORM_ROOT="platform-root"

readonly APP_TRAEFIK="traefik-development"

readonly APP_CERT_MANAGER="cert-manager"

readonly APP_EXTERNAL_SECRETS="external-secrets"

readonly APP_DOPPLER="doppler"

readonly APP_KYVERNO="kyverno"

readonly APP_PROMETHEUS="prometheus"

readonly APP_GRAFANA="grafana"

readonly APP_LOKI="loki"

readonly APP_BACKSTAGE="backstage"

################################################################################
# Verification Profiles
################################################################################

readonly PROFILE_PLATFORM="platform"

readonly PROFILE_SMOKE="smoke"

readonly PROFILE_E2E="e2e"

readonly PROFILE_REGRESSION="regression"

readonly PROFILE_AUDIT="audit"

readonly PROFILE_PRE_UPGRADE="pre-upgrade"

readonly PROFILE_POST_UPGRADE="post-upgrade"

################################################################################
# Capability Domains
################################################################################

readonly DOMAIN_NETWORKING="networking"

readonly DOMAIN_SECURITY="security"

readonly DOMAIN_OBSERVABILITY="observability"

readonly DOMAIN_DEVELOPER_PLATFORM="developer-platform"

################################################################################
# Output Formatting
################################################################################

readonly LINE_WIDTH=80

################################################################################
# ShellCheck
################################################################################

# shellcheck disable=SC2034

################################################################################
# End of File
################################################################################


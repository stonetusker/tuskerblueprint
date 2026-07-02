#!/usr/bin/env bash
set -euo pipefail

echo "TuskerBlueprint bootstrap"

terraform version
ansible --version

echo "Bootstrap validation completed."

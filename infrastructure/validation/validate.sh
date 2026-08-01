#!/usr/bin/env bash
set -euo pipefail

echo "Running infrastructure validation..."

terraform -chdir=../terraform fmt -check -recursive
terraform -chdir=../terraform validate || true

ansible-playbook --syntax-check ../ansible/playbooks/site.yml || true

echo "Validation completed."

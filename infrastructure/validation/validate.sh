#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
infrastructure_root="$(cd -- "${script_dir}/.." && pwd)"

echo "Running infrastructure validation..."

terraform -chdir="${infrastructure_root}/terraform" fmt -check -recursive
terraform -chdir="${infrastructure_root}/terraform" init -backend=false
terraform -chdir="${infrastructure_root}/terraform" validate

(
  cd "${infrastructure_root}/ansible"
  ansible-playbook \
    -i inventories/dev/hosts.example.yml \
    --syntax-check \
    playbooks/site.yml
)

echo "Infrastructure validation passed."

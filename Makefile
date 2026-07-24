.PHONY: help validate idp-validate shell-check demo-preflight demo-status backstage-bootstrap

help:
	@echo "Available targets:"
	@echo "  idp-validate       Validate YAML, required IDP assets, secrets, and Kustomize when available"
	@echo "  shell-check        Run Bash syntax checks"
	@echo "  backstage-bootstrap Generate the custom Backstage application source"
	@echo "  demo-preflight     Verify Backstage and demo-service are ready"
	@echo "  demo-status        Show current platform demo status"
	@echo "  validate           Run IDP validation"

validate: idp-validate

idp-validate:
	python scripts/validate_idp.py

shell-check:
	find scripts -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n

backstage-bootstrap:
	scripts/backstage/bootstrap-custom-app.sh

demo-preflight:
	scripts/demo/preflight.sh

demo-status:
	scripts/demo/status.sh

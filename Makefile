.PHONY: help validate idp-validate shell-check template-test demo-preflight demo-status backstage-bootstrap
help:
	@echo "idp-validate, shell-check, template-test, demo-preflight, demo-status, backstage-bootstrap"
validate: idp-validate shell-check template-test
idp-validate:
	python scripts/validate_idp.py
shell-check:
	find scripts -type f -name "*.sh" -print0 | xargs -0 -n1 bash -n
template-test:
	python scripts/validate_template_render.py
backstage-bootstrap:
	scripts/backstage/bootstrap-custom-app.sh
demo-preflight:
	scripts/demo/preflight.sh
demo-status:
	scripts/demo/status.sh

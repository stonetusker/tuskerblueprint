help:
	@echo "Available targets:"
	@echo "  lint"
	@echo "  validate"
	@echo "  fmt"

fmt:
	terraform fmt -recursive infrastructure/terraform || true

validate:
	terraform -chdir=infrastructure/terraform validate || true

lint:
	@echo "Linting will be added during CI implementation."

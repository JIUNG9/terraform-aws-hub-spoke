.PHONY: fmt validate lint test all

fmt:
	terraform fmt -recursive

validate:
	@for dir in modules/vpc modules/tgw modules/tgw-attachment; do \
		echo "Validating $$dir..."; \
		cd $$dir && terraform init -backend=false > /dev/null 2>&1 && terraform validate && cd ../../..; \
	done

lint:
	tflint --recursive

test:
	cd modules/vpc && terraform init -backend=false > /dev/null && terraform test

all: fmt validate lint

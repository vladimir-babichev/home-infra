SHELL := bash
export ROOT_DIR := $(shell git rev-parse --show-toplevel)

.PHONY: setup
setup: ## Setup local environment
	$(ROOT_DIR)/scripts/setup.sh

.PHONY: lint
lint: ## Run pre-commit checks
	pre-commit run --color=always --show-diff-on-failure --all-files

.PHONY: help
help: ## This help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | sort

%:
	@:

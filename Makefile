SHELL := bash
export ROOT_DIR := $(shell git rev-parse --show-toplevel)

###
#	Setup
###
.PHONY: setup
setup: ## Setup local environment
	$(ROOT_DIR)/scripts/setup.sh

.PHONY: lint
lint: ## Run pre-commit checks
	pre-commit run --color=always --show-diff-on-failure --all-files

.PHONY: help
help: ## This help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | sort

###
#	Documentation
###
.PHONY: docs
docs: ## Build docs with mkdocs
	mkdocs build

.PHONY: docs-serve
docs-serve: ## Run docs locally
	mkdocs serve

.PHONY: docs-publish
docs-publish: ## Deploy docs to GitHub Pages
	mkdocs gh-deploy --force

.PHONY: docs-setup
docs-setup: ## Install required mkdocs plugins
	pip install -r docs/requirements.txt

%:
	@:

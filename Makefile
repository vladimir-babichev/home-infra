.PHONY: setup
setup:
	pre-commit install

.PHONY: lint
lint:
	pre-commit run --color=always --show-diff-on-failure --all-files

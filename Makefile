.PHONY: audit lint lint-catalog lint-markdown lint-shell test

lint: lint-shell lint-catalog test lint-markdown

lint-shell:
	bash -n scripts/*.sh scripts/lib/*.sh tests/*.sh
	shellcheck scripts/*.sh scripts/lib/*.sh tests/*.sh
	shfmt -d -i 2 -ci scripts tests

lint-catalog:
	ruby scripts/validate-catalog.rb

lint-markdown:
	npx --yes markdownlint-cli2@0.23.1 "**/*.md" "#.git"

test:
	./tests/smoke.sh

audit:
	./scripts/audit.sh --post-bootstrap --deep

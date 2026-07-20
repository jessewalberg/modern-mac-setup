.PHONY: audit lint lint-markdown lint-shell test

lint: lint-shell lint-markdown test

lint-shell:
	bash -n scripts/*.sh tests/*.sh
	shellcheck scripts/*.sh tests/*.sh
	shfmt -d -i 2 -ci scripts tests

lint-markdown:
	npx --yes markdownlint-cli2@0.23.1 "**/*.md" "#.git"

test:
	./tests/smoke.sh

audit:
	./scripts/audit.sh --deep

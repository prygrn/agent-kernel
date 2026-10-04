# Lints and tests the kernel's own shell scripts; also the targets the kernel's git hooks call.
.PHONY: quality test

SHELL_FILES := $(shell find hooks scripts tests -type f 2>/dev/null) templates/githook

quality:
	shellcheck -x $(SHELL_FILES)

test:
	@for test_file in tests/*.test.sh; do bash "$$test_file" || exit 1; done

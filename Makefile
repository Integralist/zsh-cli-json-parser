# Makefile for CLI autocompletion project

.PHONY: help validate_schema test

# Use npx to run ajv-cli without needing a global install.
# This requires Node.js and npm to be installed.
AJV = npx ajv-cli

help:
	@echo "Available targets:"
	@echo "  validate_schema   - Validates example.json against schema.json"
	@echo "  test              - Runs the test suite for get_cli_options.zsh"

validate_schema: schema.json example.json
	@echo "Validating example.json against schema.json..."
	@$(AJV) validate -s schema.json -d example.json > /dev/null
	@echo "Validation successful."

test:
	@echo "Running test suite..."
	@zsh test.zsh

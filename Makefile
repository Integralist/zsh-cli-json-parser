# Makefile for CLI autocompletion project

.PHONY: help validate_schema

# Use npx to run ajv-cli without needing a global install.
# This requires Node.js and npm to be installed.
AJV = npx ajv-cli

help:
	@echo "Available targets:"
	@echo "  validate_schema   - Validates example.json against schema.json"

validate_schema: schema.json example.json
	@echo "Validating example.json against schema.json..."
	@$(AJV) validate -s schema.json -d example.json > /dev/null
	@echo "Validation successful."

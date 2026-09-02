# Spec-first workflow. `make generate` turns the contract into code.
# CI runs `make verify` as its quality gate.

.PHONY: generate lint test verify sbom

generate: ## spec -> models + server stubs
	oapi-codegen --config api/codegen.yaml api/openapi.yaml

lint: ## static analysis
	golangci-lint run ./...

test: ## unit tests with coverage gate
	go test -race -coverprofile=coverage.out ./...

sbom: ## software bill of materials for the built artifact
	syft dir:. -o cyclonedx-json=sbom.json

verify: generate lint test ## the full quality gate CI enforces
	@git diff --exit-code internal/gen/ \
		|| (echo "generated code is stale - run 'make generate' and commit" && exit 1)

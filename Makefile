.PHONY: bootstrap bootstrap-local bootstrap-aws bootstrap-gcp bootstrap-azure test-local test-config test-unit test-integration test-api test-e2e test-load-smoke

bootstrap:
	./bootstrap.sh --target local

bootstrap-local:
	./bootstrap.sh --target local

bootstrap-aws:
	./bootstrap.sh --target aws

bootstrap-gcp:
	./bootstrap.sh --target gcp

bootstrap-azure:
	./bootstrap.sh --target azure
	./scripts/bootstrap.sh --target local

bootstrap-local:
	./scripts/bootstrap.sh --target local

bootstrap-aws:
	./scripts/bootstrap.sh --target aws

bootstrap-gcp:
	./scripts/bootstrap.sh --target gcp

bootstrap-azure:
	./scripts/bootstrap.sh --target azure
.PHONY: test-local test-config test-unit test-integration test-api test-e2e test-load-smoke

test-local:
	./scripts/test-local.sh

test-config:
	./scripts/test-local.sh

test-unit:
	@echo "Unit test command placeholder: wire backend/frontend unit test runners here once implementation exists."

test-integration:
	@echo "Integration test command placeholder: run service-backed integration tests via Docker Compose here."

test-api:
	@echo "API test command placeholder: run Bruno/Newman/OpenAPI validation here."

test-e2e:
	@echo "E2E test command placeholder: run Playwright smoke journeys here."

test-load-smoke:
	@echo "Load test placeholder: run k6 smoke scenarios here."

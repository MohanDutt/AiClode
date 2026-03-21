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

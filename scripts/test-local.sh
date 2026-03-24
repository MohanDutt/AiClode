#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  "docker-compose.yml"
  ".github/workflows/ci-cd.yml"
  "deploy/monitoring/otel-collector-config.yaml"
  "deploy/helm/aiclod/Chart.yaml"
  "deploy/helm/aiclod/values.yaml"
  "deploy/helm/aiclod/templates/deployment-api.yaml"
  "deploy/helm/aiclod/templates/deployment-web.yaml"
  "deploy/helm/aiclod/templates/deployment-worker.yaml"
  "deploy/helm/aiclod/templates/hpa-api.yaml"
  "deploy/helm/aiclod/templates/hpa-worker.yaml"
  "config/environments/local.env.example"
  "config/environments/staging.env.example"
  "config/environments/production.env.example"
  "config/i18n/supported-locales.json"
  "config/communications/channels.yaml"
  "config/ai/features.yaml"
  "config/ai/model-routing.json"
  "config/ai/prompts/chatbot-assistant.en-US.yaml"
  "config/admin/policies.yaml"
  "config/admin/dashboard-metrics.yaml"
  "config/admin/feature-flags.json"
  "config/i18n/email-templates/application-received.en-US.liquid"
  "docs/architecture/aiclod-global-platform-features.md"
  "docs/architecture/aiclod-ai-features.md"
  "docs/architecture/aiclod-admin-platform.md"
  "docs/api/aiclod-api-reference.md"
  "docs/business/aiclod-business-model.md"
  "docs/operations/aiclod-deployment-setup.md"
  "docs/operations/aiclod-one-click-bootstrap.md"
  "docs/operations/aiclod-scaling-guide.md"
  "docs/quality/aiclod-testing-strategy.md"
  "bootstrap.sh"
  "bootstrap.ps1"
  "scripts/bootstrap.py"
  "scripts/bootstrap.sh"
  "scripts/bootstrap.ps1"
  "infra/terraform/README.md"
  "infra/terraform/aws/main.tf"
  "infra/terraform/gcp/main.tf"
  "infra/terraform/azure/main.tf"
  "apps/web/Dockerfile"
  "apps/web/server.py"
  "apps/api/Dockerfile"
  "apps/api/app.py"
  "apps/worker/Dockerfile"
  "apps/worker/worker.py"
  "docs/operations/aiclod-scaling-guide.md"
  "config/i18n/email-templates/application-received.en-US.liquid"
  "docs/architecture/aiclod-global-platform-features.md"
  "docs/architecture/aiclod-ai-features.md"
  "config/i18n/email-templates/application-received.en-US.liquid"
  "docs/architecture/aiclod-global-platform-features.md"
  "docs/operations/aiclod-deployment-setup.md"
  "docs/quality/aiclod-testing-strategy.md"
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || { echo "Missing required file: $file" >&2; exit 1; }
done

grep -q "services:" docker-compose.yml
grep -q "mailpit:" docker-compose.yml
grep -q "AI_FEATURES_ENABLED" docker-compose.yml
grep -q "build:" docker-compose.yml
grep -q "ADMIN_CONSOLE_ENABLED" docker-compose.yml
grep -q "build-and-release:" .github/workflows/ci-cd.yml
grep -q "config/ai" .github/workflows/ci-cd.yml
grep -q "config/admin" .github/workflows/ci-cd.yml
grep -q "build-and-release:" .github/workflows/ci-cd.yml
grep -q "config/ai" .github/workflows/ci-cd.yml
grep -q "HorizontalPodAutoscaler" deploy/helm/aiclod/templates/hpa-api.yaml
grep -q "HorizontalPodAutoscaler" deploy/helm/aiclod/templates/hpa-worker.yaml
grep -q "DEFAULT_PLATFORM_LOCALE" deploy/helm/aiclod/templates/configmap.yaml
grep -q "AI_FEATURES_ENABLED" deploy/helm/aiclod/templates/configmap.yaml
grep -q "ADMIN_CONSOLE_ENABLED" deploy/helm/aiclod/templates/configmap.yaml
grep -q "OpenTelemetry Collector" docs/operations/aiclod-deployment-setup.md
grep -q "AI runtime defaults" docs/operations/aiclod-deployment-setup.md
grep -q "Admin runtime defaults" docs/operations/aiclod-deployment-setup.md
grep -q "multi-language" docs/architecture/aiclod-global-platform-features.md
grep -q "job recommendations" docs/architecture/aiclod-ai-features.md
grep -q "fraud detection" docs/architecture/aiclod-admin-platform.md
grep -q "GET /admin/users" docs/api/aiclod-api-reference.md
grep -q "queue depth" docs/operations/aiclod-scaling-guide.md
grep -q "monthly recurring revenue" docs/business/aiclod-business-model.md
grep -q "./bootstrap.sh --target local" docs/operations/aiclod-one-click-bootstrap.md
grep -q "scripts/bootstrap.sh" bootstrap.sh
grep -q -- "-auto-approve" scripts/bootstrap.py
grep -q -- "--build" scripts/bootstrap.py
grep -q "bootstrap-local:" Makefile
grep -q "terraform fmt -check -recursive infra/terraform" .github/workflows/ci-cd.yml
grep -q "bootstrap-local:" Makefile
grep -q "terraform fmt -check -recursive infra/terraform" .github/workflows/ci-cd.yml
grep -q "./scripts/bootstrap.sh --target local" docs/operations/aiclod-one-click-bootstrap.md
grep -q -- "-auto-approve" scripts/bootstrap.py
grep -q "bootstrap-local:" Makefile
grep -q "terraform fmt -check -recursive infra/terraform" .github/workflows/ci-cd.yml
grep -q "OpenTelemetry Collector" docs/operations/aiclod-deployment-setup.md
grep -q "AI runtime defaults" docs/operations/aiclod-deployment-setup.md
grep -q "multi-language" docs/architecture/aiclod-global-platform-features.md
grep -q "job recommendations" docs/architecture/aiclod-ai-features.md
grep -q "chat" config/communications/channels.yaml
grep -q '"defaultLocale": "en-US"' config/i18n/supported-locales.json
grep -q '"provider": "openai-compatible"' config/ai/model-routing.json
grep -q "resumeScoring" config/ai/features.yaml
grep -q "jobModeration" config/admin/policies.yaml
grep -q '"provider": "config"' config/admin/feature-flags.json
grep -q "build-and-release:" .github/workflows/ci-cd.yml
grep -q "HorizontalPodAutoscaler" deploy/helm/aiclod/templates/hpa-api.yaml
grep -q "HorizontalPodAutoscaler" deploy/helm/aiclod/templates/hpa-worker.yaml
grep -q "DEFAULT_PLATFORM_LOCALE" deploy/helm/aiclod/templates/configmap.yaml
grep -q "SUPPORTED_CURRENCIES" deploy/helm/aiclod/templates/configmap.yaml
grep -q "OpenTelemetry Collector" docs/operations/aiclod-deployment-setup.md
grep -q "Communication services" docs/operations/aiclod-deployment-setup.md
grep -q "multi-language" docs/architecture/aiclod-global-platform-features.md
grep -q "chat" config/communications/channels.yaml
grep -q '"defaultLocale": "en-US"' config/i18n/supported-locales.json
grep -q "build-and-release:" .github/workflows/ci-cd.yml
grep -q "HorizontalPodAutoscaler" deploy/helm/aiclod/templates/hpa-api.yaml
grep -q "HorizontalPodAutoscaler" deploy/helm/aiclod/templates/hpa-worker.yaml
grep -q "OpenTelemetry Collector" docs/operations/aiclod-deployment-setup.md
grep -q "unit tests" docs/quality/aiclod-testing-strategy.md
grep -q "integration tests" docs/quality/aiclod-testing-strategy.md
grep -q "API tests" docs/quality/aiclod-testing-strategy.md
grep -q "load testing" docs/quality/aiclod-testing-strategy.md

if command -v docker >/dev/null 2>&1; then
  docker compose config >/dev/null
else
  echo "WARNING: docker not installed; skipped docker compose config validation" >&2
fi

if command -v helm >/dev/null 2>&1; then
  helm lint ./deploy/helm/aiclod >/dev/null
else
  echo "WARNING: helm not installed; skipped helm lint" >&2
fi

if command -v terraform >/dev/null 2>&1; then
  terraform fmt -check -recursive infra/terraform >/dev/null
else
  echo "WARNING: terraform not installed; skipped terraform fmt" >&2
fi

echo "Local deployment and testing scaffolding validation passed"

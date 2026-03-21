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

echo "Local deployment and testing scaffolding validation passed"

# AiClod Deployment Setup

## Overview

This repository includes deployment scaffolding for:

- **Local development** via `docker-compose.yml`
- **Production deployment** via Helm on Kubernetes
- **Autoscaling** via Horizontal Pod Autoscalers (HPA)
- **CI/CD** via GitHub Actions
- **Environment configuration templates** under `config/environments/`
- **Monitoring/logging telemetry** via OpenTelemetry Collector
- **Globalization defaults** for locale, currency, timezone, and international applications
- **Communication services** for chat, notifications, and localized email templates
- **AI runtime defaults** for recommendations, scoring, analytics, and chatbot support
- **Admin runtime defaults** for moderation, fraud review, dashboards, revenue tracking, and feature flags

## Included Files

- `docker-compose.yml`
- `.github/workflows/ci-cd.yml`
- `deploy/helm/aiclod/Chart.yaml`
- `deploy/helm/aiclod/values.yaml`
- `deploy/helm/aiclod/templates/*`
- `deploy/monitoring/otel-collector-config.yaml`
- `config/environments/*.env.example`
- `config/i18n/supported-locales.json`
- `config/i18n/email-templates/*`
- `config/communications/channels.yaml`
- `config/ai/features.yaml`
- `config/ai/model-routing.json`
- `config/ai/prompts/*`
- `config/admin/policies.yaml`
- `config/admin/dashboard-metrics.yaml`
- `config/admin/feature-flags.json`
- `docs/operations/aiclod-scaling-guide.md`

## Local Usage

```bash
docker compose up -d
```

Local communication preview endpoints:

- Web UI: `http://localhost:3001`
- API: `http://localhost:3000`
- Mailpit inbox: `http://localhost:8025`
- RabbitMQ management: `http://localhost:15672`

## Helm Usage

```bash
helm upgrade --install aiclod ./deploy/helm/aiclod --namespace aiclod --create-namespace
```

## Global Platform Configuration

The Helm chart config map publishes platform-wide runtime values for:

- `DEFAULT_PLATFORM_LOCALE` and `SUPPORTED_LOCALES`
- `DEFAULT_TIMEZONE` and `SUPPORTED_TIMEZONES`
- `DEFAULT_CURRENCY` and `SUPPORTED_CURRENCIES`
- `JOB_APPLICATION_REGIONS`
- `CHAT_WS_BASE_URL` and notification/email provider settings
- `AI_FEATURES_ENABLED`, provider routing, and model defaults for recommendations, scoring, forecasting, and chatbot flows
- `ADMIN_CONSOLE_ENABLED`, admin analytics/fraud settings, revenue currency, and feature-flag provider defaults

This keeps web, API, and worker runtimes aligned on the same internationalization, communications, AI, and admin defaults.

This keeps web, API, and worker runtimes aligned on the same internationalization, communications, and AI defaults.

This keeps web, API, and worker runtimes aligned on the same internationalization and communications defaults.

## Notes

- The chart assumes external managed data services in production.
- Image repositories/tags are designed to be overridden by CI/CD.
- Secrets in Helm are placeholders and should be replaced with External Secrets or a secret manager for real environments.
- The GitHub Actions release job activates once application Dockerfiles are present under `apps/web`, `apps/api`, and `apps/worker`.
- OpenTelemetry Collector remains the recommended path for tracing chat delivery latency, notification fan-out, email dispatch worker health, AI inference latency, and admin queue backlog.


## Related Documentation

- `docs/api/aiclod-api-reference.md` for route and payload guidance.
- `docs/operations/aiclod-scaling-guide.md` for workload and dependency scaling recommendations.
- `docs/operations/aiclod-one-click-bootstrap.md` for cross-platform localhost and cloud bootstrap commands.
- `docs/business/aiclod-business-model.md` for packaging, monetization, and KPI guidance.
- `docs/business/aiclod-business-model.md` for packaging, monetization, and KPI guidance.
- OpenTelemetry Collector remains the recommended path for tracing chat delivery latency, notification fan-out, email dispatch worker health, and AI inference latency.
- OpenTelemetry Collector remains the recommended path for tracing chat delivery latency, notification fan-out, and email dispatch worker health.

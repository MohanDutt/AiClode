# AiClod Deployment Setup

## Overview

This repository includes deployment scaffolding for:

- **Local development** via `docker-compose.yml`
- **Production deployment** via Helm on Kubernetes
- **Autoscaling** via Horizontal Pod Autoscalers (HPA)
- **CI/CD** via GitHub Actions
- **Environment configuration templates** under `config/environments/`
- **Monitoring/logging telemetry** via OpenTelemetry Collector

## Included Files

- `docker-compose.yml`
- `.github/workflows/ci-cd.yml`
- `deploy/helm/aiclod/Chart.yaml`
- `deploy/helm/aiclod/values.yaml`
- `deploy/helm/aiclod/templates/*`
- `deploy/monitoring/otel-collector-config.yaml`
- `config/environments/*.env.example`

## Local Usage

```bash
docker compose up -d
```

## Helm Usage

```bash
helm upgrade --install aiclod ./deploy/helm/aiclod --namespace aiclod --create-namespace
```

## Notes

- The chart assumes external managed data services in production.
- Image repositories/tags are designed to be overridden by CI/CD.
- Secrets in Helm are placeholders and should be replaced with External Secrets or a secret manager for real environments.
- The GitHub Actions release job activates once application Dockerfiles are present under `apps/web`, `apps/api`, and `apps/worker`.

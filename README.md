# AiClod

AiClod is a cloud-agnostic SaaS job portal architecture blueprint designed for both local development with Docker Compose and cloud deployment on Kubernetes.

The recommended default implementation stack is fully open-source: Next.js, NestJS, PostgreSQL, OpenSearch, Valkey, RabbitMQ, MinIO, Keycloak, and Kubernetes-native DevOps tooling.

## Platform Capabilities

- Multi-language user experiences for candidate, employer, and admin journeys.
- Currency and timezone-aware pricing, billing, scheduling, and reporting.
- International job applications with region-specific eligibility, consent, and compliance metadata.
- Omnichannel communication scaffolding for in-app chat, notifications, and localized email templates.
- AI feature scaffolding for job recommendations, resume scoring, skill-gap analysis, predictive hiring analytics, and chatbot support.
- Admin platform scaffolding for user/employer management, moderation, fraud detection, analytics dashboards, revenue tracking, and feature flags.

## Documentation

- [System Architecture](docs/architecture/aiclod-system-architecture.md)
- [Global Platform Features](docs/architecture/aiclod-global-platform-features.md)
- [AI Features](docs/architecture/aiclod-ai-features.md)
- [Admin Platform](docs/architecture/aiclod-admin-platform.md)
- [NestJS Backend Architecture](docs/backend/aiclod-nestjs-backend-architecture.md)
- [API Reference](docs/api/aiclod-api-reference.md)
- [Next.js Frontend Architecture](docs/frontend/aiclod-nextjs-frontend-architecture.md)
- [OpenSearch / Elasticsearch Search Architecture](docs/search/aiclod-opensearch-search-architecture.md)
- [Monetization and Billing Architecture](docs/billing/aiclod-monetization-and-billing-architecture.md)
- [Business Model](docs/business/aiclod-business-model.md)
- [Security Architecture](docs/security/aiclod-security-architecture.md)
- [Deployment Setup](docs/operations/aiclod-deployment-setup.md)
- [One-Click Bootstrap](docs/operations/aiclod-one-click-bootstrap.md)
- [Scaling Guide](docs/operations/aiclod-scaling-guide.md)
- [Testing Strategy](docs/quality/aiclod-testing-strategy.md)
- [PostgreSQL Schema](docs/data/aiclod-postgresql-schema.md)

## Quick Start

- Linux/macOS: `./bootstrap.sh --target local`
- Windows PowerShell: `pwsh -File .\bootstrap.ps1 -Target local`
- Cloud targets: replace `local` with `aws`, `gcp`, or `azure`.

- Linux/macOS: `./scripts/bootstrap.sh --target local`
- Windows PowerShell: `pwsh -File .\scripts\bootstrap.ps1 -Target local`
- Cloud targets: replace `local` with `aws`, `gcp`, or `azure`.

- [Scaling Guide](docs/operations/aiclod-scaling-guide.md)
## Documentation

- [System Architecture](docs/architecture/aiclod-system-architecture.md)
- [NestJS Backend Architecture](docs/backend/aiclod-nestjs-backend-architecture.md)
- [Next.js Frontend Architecture](docs/frontend/aiclod-nextjs-frontend-architecture.md)
- [OpenSearch / Elasticsearch Search Architecture](docs/search/aiclod-opensearch-search-architecture.md)
- [Monetization and Billing Architecture](docs/billing/aiclod-monetization-and-billing-architecture.md)
- [Security Architecture](docs/security/aiclod-security-architecture.md)
- [Deployment Setup](docs/operations/aiclod-deployment-setup.md)
- [Testing Strategy](docs/quality/aiclod-testing-strategy.md)
- [PostgreSQL Schema](docs/data/aiclod-postgresql-schema.md)

## Scaffold Directories

- `config/i18n/` stores locale metadata and localized email templates.
- `config/communications/` stores channel policy defaults for chat, notifications, and email delivery.
- `config/ai/` stores AI feature flags, model routing defaults, and prompt templates.
- `config/admin/` stores admin policies, dashboard defaults, and feature-flag metadata.
- `config/environments/` contains environment variable templates for local, staging, and production deployments.
- `infra/terraform/` contains provider-specific infrastructure entry points for AWS, GCP, and Azure.
- `config/environments/` contains environment variable templates for local, staging, and production deployments.
- `config/environments/` contains environment variable templates for local, staging, and production deployments.
- [PostgreSQL Schema](docs/data/aiclod-postgresql-schema.md)
- [PostgreSQL Schema](docs/data/aiclod-postgresql-schema.md)
- [PostgreSQL Schema](docs/data/aiclod-postgresql-schema.md)
- [PostgreSQL Schema](docs/data/aiclod-postgresql-schema.md)
- [PostgreSQL Schema](docs/data/aiclod-postgresql-schema.md)
- [PostgreSQL Schema](docs/data/aiclod-postgresql-schema.md)
- [PostgreSQL Schema](docs/data/aiclod-postgresql-schema.md)


# AiClod Global Platform Features

## Overview

AiClod should behave like a global hiring platform from day one. The scaffold in this repository now includes configuration and architectural guidance for:

- multi-language web and email experiences,
- currency and timezone-aware platform settings,
- international job application workflows, and
- an omnichannel communication system spanning chat, notifications, and email templates.

## Multi-language and Localization

Recommended implementation defaults:

- Store the tenant default locale, user preferred locale, and browser fallback locale independently.
- Load front-end translation bundles with `next-intl` or an equivalent locale-aware routing layer.
- Persist notification and email template locale selections so retries remain deterministic.
- Mark RTL locales explicitly so layout direction can change at the shell and component level.

The repository includes `config/i18n/supported-locales.json` plus localized email template examples under `config/i18n/email-templates/`.

## Currency and Timezone

Global job marketplaces need consistent money and scheduling semantics. Recommended rules:

- Store monetary values in minor units alongside ISO-4217 currency codes.
- Store canonical timestamps in UTC and render user-facing dates in the candidate or recruiter timezone.
- Allow organizations to configure a billing currency separately from job-post display currency when needed.
- Capture job timezone, interview timezone, and tenant reporting timezone independently.

The environment templates and Helm values expose supported currencies, supported timezones, and platform defaults.

## International Job Applications

International hiring adds data and policy requirements beyond a domestic workflow. AiClod should support:

- region-specific work authorization questions,
- visa sponsorship flags and relocation preferences,
- localized consent notices and equal-opportunity forms,
- cross-border document collection for resumes, cover letters, and identity proofs, and
- compliance review queues for markets with additional validation requirements.

A practical implementation should represent application forms as versioned schemas so each market can evolve without redeploying the entire workflow.

## Communication System

### Chat

The preferred baseline is a websocket-backed chat gateway in the API tier with Redis/Valkey for presence and RabbitMQ for fan-out, audit, and moderation events. Candidate-employer messaging should be permissioned per application and organization.

### Notifications

Notifications should be event-driven and fan out into channel-specific delivery workers. The default channel set is:

- in-app notifications for dashboards,
- email for durable workflow updates, and
- push notifications for mobile or browser opt-in clients.

### Email Templates

Localized transactional emails should be stored as versioned templates with placeholders for locale, timezone, candidate name, job title, and organization branding. The included template examples show how to localize both subject lines and HTML bodies.

## Deployment Notes

- Local Docker Compose includes Mailpit to capture outbound email templates during development.
- Helm values expose globalization and communication settings so tenants can be tuned per environment.
- Communication queues should be traced with OpenTelemetry to measure delivery latency and failure rates.

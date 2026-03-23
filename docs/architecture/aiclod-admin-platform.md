# AiClod Admin Platform

## Overview

AiClod needs a first-class admin system to operate the marketplace safely and profitably. The scaffold in this repository now defines defaults for:

- user and employer management,
- job moderation,
- fraud detection,
- analytics dashboards,
- revenue tracking, and
- feature flag controls.

## User and Employer Management

Administrators should be able to review accounts, suspend or restore users, manage recruiter access, and audit employer onboarding status. Sensitive actions should be logged and require scoped admin permissions.

## Job Moderation

Job moderation should combine policy checks, review queues, and escalation workflows. A baseline implementation should support draft holds, escalation reasons, moderator notes, and publish/unpublish decisions.

## Fraud Detection

Fraud controls should aggregate risk signals from signup behavior, payment events, suspicious job posting patterns, application spam, and communication abuse. High-risk cases should land in explicit review queues with analyst notes and disposition tracking.

## Analytics Dashboard

The admin dashboard should surface marketplace health, moderation throughput, candidate/employer funnel conversion, fraud trends, and system status indicators. Analytics tiles should separate operational metrics from financial KPIs.

## Revenue Tracking

Revenue reporting should expose MRR, ARR, GMV, refunds, delinquency, and plan mix. Financial numbers should always carry currency metadata and distinguish booked revenue from cash collection.

## Feature Flag Controls

Feature flags should be centrally managed with ownership, rollout rules, and audit history. Admins should be able to gate features by tenant, region, plan, or internal cohort.

## Configuration Assets

The repository includes:

- `config/admin/policies.yaml` for admin workflows and review queues,
- `config/admin/dashboard-metrics.yaml` for analytics/revenue dashboard defaults, and
- `config/admin/feature-flags.json` for configurable feature flag metadata.

## Deployment Notes

- Admin runtime defaults are exposed through env templates, Docker Compose, and Helm config values.
- Feature-flag changes should be audited and ideally promoted through staged rollout workflows.
- Fraud and moderation queues should be traced with OpenTelemetry so operators can monitor backlog and latency.

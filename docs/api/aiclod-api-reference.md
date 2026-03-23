# AiClod API Reference

## Overview

AiClod's API should be exposed as a versioned REST surface rooted at `/api/v1`, with websocket endpoints for realtime chat and notification updates. The API should be tenant-aware, role-aware, and safe for extension as the platform grows.

## Authentication and Authorization

- Authentication should rely on OIDC/OAuth2 access tokens issued by Keycloak or another standards-compliant identity provider.
- API clients should send `Authorization: Bearer <token>`.
- Authorization should combine tenant membership, organization role, and system admin scopes.
- Admin routes should require elevated scopes and emit audit events for mutating actions.

## API Conventions

- Base path: `/api/v1`
- Payloads: JSON for request/response bodies unless multipart upload is required.
- Time values: ISO-8601 in UTC.
- Money values: integer minor units plus ISO-4217 currency code.
- Pagination: cursor-based where large lists are expected.
- Errors: RFC 7807-style problem details are recommended.

## Core Resource Groups

### Authentication

- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /auth/me`

### Candidate APIs

- `GET /candidate/profile`
- `PATCH /candidate/profile`
- `GET /candidate/applications`
- `POST /candidate/applications`
- `GET /candidate/recommendations`
- `POST /candidate/chat/sessions`

### Employer APIs

- `GET /employer/jobs`
- `POST /employer/jobs`
- `PATCH /employer/jobs/{jobId}`
- `GET /employer/jobs/{jobId}/applicants`
- `POST /employer/jobs/{jobId}/publish`
- `GET /employer/analytics`

### Search APIs

- `GET /jobs/search`
- `GET /jobs/{jobSlug}`
- `GET /filters/metadata`

### Communications APIs

- `GET /notifications`
- `PATCH /notifications/{notificationId}/read`
- `GET /chat/sessions/{sessionId}`
- `POST /chat/sessions/{sessionId}/messages`

### AI APIs

- `GET /ai/recommendations/jobs`
- `POST /ai/resume-score`
- `POST /ai/skill-gap-analysis`
- `GET /ai/hiring-forecasts`
- `POST /ai/chatbot/messages`

### Admin APIs

- `GET /admin/users`
- `POST /admin/users/{userId}/suspend`
- `GET /admin/employers`
- `GET /admin/jobs/moderation-queue`
- `POST /admin/jobs/{jobId}/moderate`
- `GET /admin/fraud/cases`
- `GET /admin/analytics/dashboard`
- `GET /admin/revenue/summary`
- `GET /admin/feature-flags`
- `PATCH /admin/feature-flags/{flagKey}`

## Example Response Shapes

### `GET /jobs/search`

```json
{
  "data": [
    {
      "id": "job_123",
      "title": "Senior Backend Engineer",
      "organization": "Example Corp",
      "location": "Berlin, DE",
      "salary": { "amountMinor": 12000000, "currency": "EUR" },
      "matchScore": 0.87
    }
  ],
  "pageInfo": {
    "nextCursor": "opaque-cursor"
  }
}
```

### `POST /ai/resume-score`

```json
{
  "resumeScore": 82,
  "band": "strong_match",
  "strengths": ["Distributed systems", "PostgreSQL tuning"],
  "risks": ["Limited public-cloud experience"],
  "explanations": [
    {
      "type": "skill_match",
      "message": "Matched 9 of 12 required skills",
      "confidence": 0.79
    }
  ]
}
```

## Websocket Endpoints

- `GET /ws/chat` for realtime conversation events.
- `GET /ws/notifications` for in-app notification fan-out.
- Connection authentication should happen during the websocket handshake using a bearer token or short-lived signed session token.

## Operational Requirements

- All write APIs should emit audit and analytics events.
- Admin, AI, moderation, and fraud endpoints should be traced with OpenTelemetry.
- Rate limits should be applied by route group and actor type.
- Public search endpoints should support CDN-safe caching headers where appropriate.

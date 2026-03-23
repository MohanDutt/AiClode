# AiClod Security Architecture

## 1. Purpose

This document defines the **full security architecture** for AiClod.

It covers:

- JWT authentication,
- RBAC and policy enforcement,
- OWASP-aligned protections,
- rate limiting and abuse prevention,
- data encryption,
- GDPR and privacy controls,
- fraud detection.

The objective is to provide a production-ready security model for a cloud-agnostic SaaS job portal serving candidates, employers, recruiters, administrators, and integration partners.

---

## 2. Security Principles

AiClod security should follow these principles:

1. **Zero trust by default** between users, services, plugins, and external systems.
2. **Least privilege** for users, tenants, services, and infrastructure components.
3. **Defense in depth** across application, API, infrastructure, and operations.
4. **Secure-by-default platform posture** with explicit exception handling.
5. **Privacy-aware design** for candidate and employer data.
6. **Auditability and traceability** for sensitive actions.
7. **Resilience to fraud and abuse** in public and private workflows.

---

## 3. Threat Model Overview

AiClod must account for threats across these surfaces:

- public web traffic and anonymous search,
- authenticated candidate flows,
- employer/recruiter dashboards,
- admin console,
- plugin and integration interfaces,
- payment and billing flows,
- resume uploads and document handling,
- search and data export behavior,
- internal platform and infrastructure access.

### 3.1 Primary Threat Categories

- account takeover,
- credential stuffing,
- broken access control,
- injection attacks,
- cross-site scripting,
- CSRF where cookie-backed flows exist,
- insecure direct object reference (IDOR),
- plugin abuse,
- search scraping and resume harvesting,
- invoice/payment fraud,
- insider misuse,
- privacy breaches and unlawful retention.

---

## 4. Identity and Authentication Architecture

### 4.1 Authentication Model

AiClod should use an external identity provider such as **Keycloak** with OIDC/OAuth2.

Supported authentication modes:
- email/password,
- passwordless or magic-link where desired,
- social login for candidates,
- enterprise SSO for employers,
- MFA for admin and privileged roles,
- service-to-service auth for internal APIs.

### 4.2 JWT-Based Authentication

JWT should be the primary application token format for API authorization.

Recommended token split:
- **access token**: short-lived, bearer token for API requests
- **refresh token**: long-lived, rotation-controlled, revocable token
- optional **ID token** for client identity context only

### 4.3 JWT Claims

Recommended claims:

- `sub` user ID
- `iss` issuer
- `aud` audience
- `exp`, `iat`, `nbf`
- `tenant_id` when tenant scoped
- `org_ids` where needed
- `roles`
- `permissions` or policy scopes when appropriate
- `session_id`
- `amr` / MFA state

### 4.4 Token Security Controls

- use asymmetric signing (RS256/ES256) where possible,
- rotate signing keys,
- validate `iss`, `aud`, `exp`, `nbf`, and signature on every request,
- keep access tokens short-lived,
- use refresh token rotation,
- support immediate revocation for high-risk sessions,
- track token/session metadata for anomaly detection.

### 4.5 Session Security

For browser-based flows:
- prefer secure HTTP-only cookies for refresh/session handling where applicable,
- set `Secure`, `HttpOnly`, and `SameSite` appropriately,
- bind sessions to device or browser risk signals when justified,
- invalidate sessions on password reset, high-risk auth events, and privilege changes.

---

## 5. Authorization Model

### 5.1 RBAC Foundation

AiClod should implement multi-layer RBAC.

Recommended role scopes:
- **platform roles**: super admin, support admin, finance admin
- **tenant roles**: tenant admin, billing admin, recruiter, hiring manager, coordinator
- **candidate roles**: job seeker / candidate
- **service roles**: worker, scheduler, plugin runtime, internal API client

### 5.2 Beyond RBAC: Policy Controls

RBAC alone is not sufficient for a SaaS job portal.

Add policy checks such as:
- recruiter can view only candidates in accessible scopes,
- billing admin can manage plans but not impersonate candidates,
- employer can view candidate details only if entitlement allows it,
- admin action may require step-up auth or MFA,
- export operations may require elevated permission.

### 5.3 Authorization Enforcement Points

Authorization must be enforced in:
- frontend route guards for UX,
- backend controllers/guards,
- application services,
- repository query scoping,
- search query scoping,
- background-job processors,
- admin tools.

### 5.4 Tenant Isolation Rules

Every tenant-aware operation must enforce:
- tenant membership validation,
- tenant-scoped resource lookup,
- organization scope checks where relevant,
- prevention of cross-tenant ID access.

---

## 6. API Security and OWASP Protections

### 6.1 OWASP API Security Alignment

AiClod should explicitly protect against OWASP API Top 10 risks, especially:

- broken object level authorization,
- broken authentication,
- broken function level authorization,
- unrestricted resource consumption,
- injection,
- mass assignment,
- security misconfiguration,
- SSRF,
- improper inventory management,
- unsafe consumption of third-party APIs.

### 6.2 Input Validation

All external inputs must be:
- schema validated,
- type validated,
- length constrained,
- normalized where necessary,
- rejected if unknown/unsafe fields are present for sensitive operations.

Recommended approach:
- NestJS DTO validation,
- Zod/class-validator,
- whitelist mode on DTO parsing,
- explicit mapping to domain commands.

### 6.3 Output Handling

- escape user-provided content before HTML rendering,
- sanitize rich text and resumes before display,
- avoid leaking internal IDs or ranking signals when unnecessary,
- return least-privilege response DTOs.

### 6.4 Injection Protection

Protect against:
- SQL injection via parameterized queries/ORM safeguards,
- OpenSearch query injection through structured query builders,
- command injection in plugin or file-processing flows,
- template injection in notifications/content rendering.

### 6.5 XSS and CSRF Protection

- use output escaping and content sanitization,
- enforce CSP where possible,
- avoid unsafe inline scripts,
- use CSRF protection on cookie-backed mutation flows,
- verify origin/referer on sensitive browser actions when appropriate.

### 6.6 File Upload Protection

Resume and attachment uploads must enforce:
- MIME and extension allowlists,
- file size limits,
- malware scanning,
- document parsing in isolated workers,
- safe storage with non-executable handling,
- signed URL expiration and access controls.

---

## 7. Rate Limiting and Abuse Prevention

### 7.1 Rate Limiting Layers

Apply rate limiting at multiple layers:

- CDN/WAF edge,
- ingress/API gateway,
- application routes,
- auth endpoints,
- search endpoints,
- payment webhook endpoints,
- export/report generation endpoints.

### 7.2 Recommended Limits by Endpoint Type

Examples:
- login and password reset: aggressive per-IP + per-account limits
- anonymous search: moderate rate limits with bot mitigation
- job apply endpoints: IP, account, and job-based limits
- candidate unlock/export actions: tenant/user-specific limits
- admin endpoints: stricter anomaly monitoring rather than only throughput limits

### 7.3 Abuse Signals

Monitor for:
- excessive search scraping,
- repeated candidate profile unlock attempts,
- repeated failed logins,
- unusual export volume,
- mass messaging or outreach abuse,
- suspicious coupon/promotion usage.

### 7.4 Bot and Scraper Protection

Use:
- WAF rules,
- device/browser reputation,
- CAPTCHA or progressive challenges only where justified,
- behavioral rate limiting,
- hidden decoy telemetry/endpoints where needed.

---

## 8. Data Encryption Architecture

### 8.1 Encryption in Transit

- TLS everywhere for client-to-edge and service-to-service traffic,
- mTLS for sensitive internal service communication where appropriate,
- secure webhook endpoint transport only,
- disable weak ciphers and old TLS versions.

### 8.2 Encryption at Rest

Encrypt at rest for:
- PostgreSQL volumes/backups,
- object storage buckets,
- search clusters,
- cache snapshots where persistence is enabled,
- log and audit storage.

### 8.3 Field-Level Protection

Sensitive fields that may justify stronger controls:
- billing contact information,
- legal identifiers if collected,
- candidate contact details,
- salary expectations in some jurisdictions,
- audit-sensitive admin notes.

For especially sensitive fields, consider:
- application-level encryption,
- tokenization or format-preserving masking,
- restricted decryption paths.

### 8.4 Secrets Management

Secrets must never live in code or plain config files.

Use:
- Kubernetes secrets only as a delivery mechanism, not a source-of-truth,
- Vault / cloud secret manager / External Secrets Operator,
- key rotation policies,
- scoped access for each workload.

---

## 9. Privacy Controls and GDPR Architecture

### 9.1 Privacy-by-Design Principles

- collect only necessary data,
- classify PII and sensitive business data,
- define retention rules per data category,
- support user-facing privacy controls,
- maintain lawful processing and audit records.

### 9.2 GDPR Data Subject Rights

AiClod should support:
- right of access,
- right to rectification,
- right to erasure,
- right to data portability,
- right to restrict processing,
- right to object,
- consent withdrawal where consent-based processing exists.

### 9.3 Privacy Workflow Requirements

Implement workflows for:
- data export requests,
- account deletion requests,
- employer or candidate privacy preference changes,
- retention-based automatic deletion or anonymization,
- legal hold exceptions.

### 9.4 Data Retention and Deletion Strategy

Recommended policy model:
- resumes retained only as long as justified by product/legal basis,
- dormant candidate accounts reviewed for retention expiration,
- job application records retained by configurable tenant policy,
- invoices retained per financial/legal obligations,
- audit logs retained under compliance policy.

### 9.5 Anonymization vs Deletion

Use true deletion when legally required and feasible.

Use anonymization for:
- analytics continuity,
- fraud models,
- historical reporting,
- legally required financial record preservation where direct identifiers are not needed.

### 9.6 Privacy Controls in Product UX

Candidates and employers should be able to control:
- profile visibility,
- resume visibility,
- discoverability in search,
- outreach preferences,
- email/notification consent,
- export/delete account requests.

---

## 10. Fraud Detection and Risk Controls

### 10.1 Fraud Surface Areas

AiClod must detect and mitigate fraud in:
- fake employer account creation,
- fraudulent job postings,
- scam outreach to candidates,
- resume scraping,
- payment abuse and chargebacks,
- coupon/promotion abuse,
- synthetic or abusive candidate profiles,
- admin or insider misuse.

### 10.2 Risk Signals

Recommended fraud signals:
- account age,
- device and IP reputation,
- geo anomalies,
- repeated payment failures,
- unusually high candidate unlock velocity,
- unusual job posting frequency,
- repeated content moderation flags,
- email/domain reputation,
- mismatch between billing region and operational behavior.

### 10.3 Fraud Scoring Model

Use a rules-plus-signals model initially:

- deterministic blocks for severe patterns,
- risk scoring for medium-confidence anomalies,
- manual review queue for ambiguous cases,
- feedback loop from trust/safety and support actions.

### 10.4 High-Risk Actions Requiring Additional Controls

Examples:
- mass candidate export,
- unusually high resume unlock volume,
- large billing changes,
- payout/refund actions,
- admin impersonation,
- first-time high-budget premium campaign purchase.

Controls may include:
- MFA step-up,
- manual review,
- temporary hold,
- velocity limit,
- secondary confirmation.

---

## 11. Security Logging and Auditability

### 11.1 Security Events to Log

Log at minimum:
- successful and failed logins,
- MFA enrollment and challenge events,
- password resets,
- token/session revocations,
- privilege changes,
- export and unlock actions,
- admin actions,
- webhook verification failures,
- payment/refund actions,
- fraud-trigger events.

### 11.2 Audit Log Requirements

Audit logs should be:
- immutable or append-only,
- timestamped,
- actor-attributed,
- tenant-aware where applicable,
- searchable,
- retained under policy.

### 11.3 Sensitive Logging Rules

Never log:
- raw passwords,
- full tokens,
- card data,
- private resume contents unless explicitly justified,
- secrets or encryption keys.

Mask or hash where necessary.

---

## 12. Infrastructure and Platform Security

### 12.1 Kubernetes Security Controls

Use:
- non-root containers,
- read-only root filesystems where possible,
- NetworkPolicies,
- Pod Security standards,
- image signing and provenance,
- resource quotas/limits,
- admission policies.

### 12.2 Supply Chain Security

- sign container images,
- generate SBOMs,
- scan dependencies and images,
- pin critical dependencies,
- review plugin packages before trust elevation,
- monitor CVEs continuously.

### 12.3 Environment Segmentation

- separate dev/staging/prod environments,
- isolate admin and operational access paths,
- restrict direct production database access,
- use bastion or audited access workflows for emergency operations.

---

## 13. Secure Plugin and Integration Model

### 13.1 Plugin Risk Model

Plugins increase risk because they execute external or semi-trusted logic.

Controls should include:
- capability-based permissions,
- explicit allowlists,
- per-plugin secrets isolation,
- execution timeout limits,
- network egress restrictions where possible,
- plugin-specific audit logs,
- sandboxing for higher-risk plugins.

### 13.2 Third-Party Webhooks and APIs

- verify webhook signatures,
- rate limit inbound webhooks,
- use idempotency keys,
- isolate retries,
- log failures without leaking secrets,
- validate outbound target URLs to reduce SSRF risk.

---

## 14. Security Testing and Verification

### 14.1 Required Testing Layers

AiClod security verification should include:
- SAST,
- dependency scanning,
- secret scanning,
- DAST on exposed environments,
- permission boundary tests,
- abuse-case testing,
- upload-malware workflow testing,
- payment webhook replay testing.

### 14.2 Manual Security Reviews

Perform recurring reviews for:
- admin impersonation features,
- candidate unlock/export workflows,
- billing and refund controls,
- plugin onboarding,
- GDPR deletion/export flows,
- search scraping resistance.

### 14.3 Security Regression Tests

Automate tests for:
- JWT validation failures,
- expired/revoked token handling,
- cross-tenant access denial,
- role-based route restrictions,
- quota/entitlement abuse,
- signed upload/download URL expiry,
- webhook signature rejection.

---

## 15. Incident Response and Recovery

### 15.1 Incident Types

Prepare playbooks for:
- suspected account takeover,
- data exposure incident,
- payment fraud spike,
- search scraping incident,
- malicious job posting campaign,
- compromised plugin or integration,
- encryption key or secret exposure.

### 15.2 Response Capabilities

The platform should support:
- rapid token/session revocation,
- tenant suspension,
- plugin disablement,
- forced password reset,
- emergency rate-limit tightening,
- forensic log access,
- regulator/customer notification workflows.

---

## 16. Recommended Implementation Sequence

1. Implement authentication, JWT validation, and tenant-aware RBAC guards.
2. Add repository/query-level tenant isolation and audit logging.
3. Add OWASP-aligned input validation, file upload hardening, and secure headers/CSP.
4. Add rate limiting, abuse detection, and scraper protection.
5. Add privacy controls, GDPR export/deletion workflows, and retention policies.
6. Add fraud scoring and high-risk action review flows.
7. Add full security testing automation and incident playbooks.

This sequence establishes strong identity and access control first, then deepens application, privacy, and fraud protections over time.

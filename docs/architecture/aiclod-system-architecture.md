# AiClod System Architecture

## 1. Goals

AiClod is a production-ready, cloud-agnostic SaaS job portal for employers, recruiters, candidates, and platform administrators. The architecture is optimized for:

- **Fast local onboarding** with `docker-compose`.
- **Cloud deployment** on any CNCF-aligned Kubernetes platform.
- **Modular monolith delivery** today, with clear seams for **future microservice extraction**.
- **Clean Architecture** boundaries to keep domain logic independent of frameworks.
- **Plugin-based extensibility** for job ingestion, resume parsing, assessments, notifications, billing, and partner integrations.
- **Operational readiness** with autoscaling, observability, security, tenancy, and disaster recovery.

---

## 2. Architecture Principles

### 2.1 Design Principles

1. **Modular Monolith First**
   - One deployable application for velocity, consistency, and operational simplicity.
   - Internal modules communicate through explicit application services, domain events, and module APIs.
   - No cross-module database table ownership.

2. **Cloud-Agnostic by Default**
   - Kubernetes-native deployment primitives.
   - Open standards: PostgreSQL, Redis, S3-compatible object storage, OpenTelemetry, Prometheus, Grafana, Loki/ELK, Keycloak/Auth0/OIDC.
   - Works on AWS, Azure, GCP, DigitalOcean, OpenShift, Rancher, or self-managed Kubernetes.

3. **Clean Architecture**
   - Domain and use cases remain independent from delivery and infrastructure.
   - Frameworks, database engines, queues, and external APIs are adapters.

4. **Plugin Extensibility**
   - Extension points for internal and third-party capabilities.
   - Plugins are isolated behind contracts and policies.

5. **Operationally Safe**
   - Horizontal scaling for stateless workloads.
   - Queue-based async processing.
   - Defense-in-depth security.
   - Blue/green or rolling upgrades.

---

## 2.4 Global Platform Requirements

AiClod must support international hiring operations without introducing region-specific forks. That means the core platform should treat locale, currency, timezone, and communication preferences as first-class configuration primitives rather than optional presentation concerns.

Key requirements:

- locale-aware routing and content delivery for public and authenticated surfaces,
- currency-aware monetization and reporting defaults,
- timezone-safe scheduling for interviews, reminders, and SLAs,
- region-aware job application policies and compliance forms, and
- omnichannel communication orchestration for chat, notifications, and email.

---

## 3. Context Diagram

```mermaid
flowchart TB
    candidate[Candidate Users]
    employer[Employer / Recruiter Users]
    admin[Platform Admins]
    partner[External Partners]

    subgraph edge[Edge Layer]
        cdn[CDN / WAF]
        ingress[Ingress / API Gateway]
    end

    subgraph app[AiClod Platform]
        web[Web App / SPA]
        api[Modular Monolith API]
        worker[Background Workers]
        plugin[Plugin Runtime]
        events[Domain Events / Queue]
    end

    subgraph data[Data Layer]
        pg[(PostgreSQL)]
        redis[(Redis)]
        obj[(S3-Compatible Object Storage)]
        search[(OpenSearch / Elasticsearch)]
    end

    subgraph ops[Operations]
        obs[Observability Stack]
        secrets[Secrets / Config]
        iam[OIDC / IAM]
    end

    candidate --> cdn
    employer --> cdn
    admin --> cdn
    cdn --> ingress
    ingress --> web
    ingress --> api

    api --> pg
    api --> redis
    api --> obj
    api --> search
    api --> events
    worker --> events
    worker --> pg
    worker --> redis
    worker --> obj
    worker --> search
    plugin --> api
    plugin --> events

    partner <---> ingress
    api --> iam
    api --> secrets
    api --> obs
    worker --> obs
    ingress --> obs
```

---

## 4. Deployment Topology

### 4.1 Localhost Topology (`docker-compose`)

Local development uses containers that mirror production dependencies while remaining simple enough for contributor machines.

```mermaid
flowchart LR
    browser[Browser]
    subgraph docker[Docker Compose Network]
        web[web-ui]
        api[api]
        worker[worker]
        scheduler[scheduler]
        postgres[(postgres)]
        redis[(redis)]
        minio[(minio)]
        mailhog[(mailhog)]
        opensearch[(opensearch)]
        otel[otel-collector]
    end

    browser --> web
    web --> api
    api --> postgres
    api --> redis
    api --> minio
    api --> opensearch
    api --> mailhog
    api --> otel
    worker --> redis
    worker --> postgres
    scheduler --> api
```

**Local objectives:**
- Single-command startup.
- Seed data for employers, jobs, applicants, and workflows.
- Mail capture with MailHog.
- S3-compatible local file storage with MinIO.
- Optional OpenSearch for full-text job search.
- OpenTelemetry collector for tracing and log forwarding.

### 4.2 Cloud Topology (Kubernetes)

```mermaid
flowchart TB
    internet[Internet / Users]
    dns[DNS]
    waf[WAF / CDN]
    ing[Ingress Controller]

    subgraph k8s[Kubernetes Cluster]
        subgraph ns1[Namespace: aiclod-app]
            webd[Web Deployment]
            apid[API Deployment]
            workerd[Worker Deployment]
            sched[Scheduler/CronJobs]
            hpa[HPA / KEDA]
            ppol[Network Policies]
            svc[ClusterIP Services]
        end

        subgraph ns2[Namespace: aiclod-platform]
            otel[OpenTelemetry Collector]
            prom[Prometheus]
            grafana[Grafana]
            loki[Loki / Log Stack]
            extsec[External Secrets]
        end
    end

    subgraph managed[Managed or Self-Hosted Data Services]
        pg[(PostgreSQL HA)]
        redis[(Redis / Valkey)]
        obj[(Object Storage)]
        search[(OpenSearch)]
        mq[(Message Broker / Queue)]
        idp[(OIDC Identity Provider)]
    end

    internet --> dns --> waf --> ing --> svc
    svc --> webd
    svc --> apid
    apid --> pg
    apid --> redis
    apid --> obj
    apid --> search
    apid --> mq
    apid --> idp
    workerd --> mq
    workerd --> pg
    workerd --> obj
    sched --> apid
    hpa --> apid
    hpa --> workerd
    apid --> otel
    workerd --> otel
    ing --> prom
    otel --> loki
    otel --> grafana
    extsec --> apid
```

**Cloud objectives:**
- Stateless app pods.
- Separate operational namespace.
- Managed data services when available, self-hosted alternatives when required.
- Autoscaling via CPU, memory, and queue depth.
- Environment-specific configuration through ConfigMaps, Secrets, and External Secrets.

---

## 5. Application Structure: Modular Monolith with Clean Architecture

### 5.1 Layered Structure

```text
interfaces/
  web/
  api/
  admin/
application/
  commands/
  queries/
  workflows/
  policies/
domain/
  candidate/
  employer/
  job/
  application/
  billing/
  notification/
  plugin/
  shared/
infrastructure/
  persistence/
  messaging/
  cache/
  search/
  storage/
  auth/
  observability/
plugins/
  builtin/
  external/
```

### 5.2 Clean Architecture Rules

- **Domain layer** contains entities, value objects, domain services, invariants, and domain events.
- **Application layer** orchestrates use cases, transactions, authorization checks, and DTO mapping.
- **Interface layer** exposes HTTP/GraphQL/WebSocket/admin endpoints.
- **Infrastructure layer** implements repositories, queues, search adapters, file storage, identity providers, and plugin loading.

### 5.3 Internal Business Modules

| Module | Responsibilities | Data Ownership |
|---|---|---|
| Identity & Access | users, organizations, roles, RBAC/ABAC, SSO mapping | user, role, membership tables |
| Tenant Management | tenant config, branding, quotas, plan limits | tenant and subscription metadata |
| Employer Management | companies, recruiters, hiring teams | employer/company data |
| Candidate Management | candidate profiles, resumes, preferences, portfolios | candidate profile data |
| Job Catalog | job requisitions, job posts, approval workflows, publishing | jobs, job metadata |
| Search & Discovery | indexing, filters, recommendations, saved searches | search documents and query analytics |
| Application Tracking | applications, statuses, notes, scoring, pipeline stages | application lifecycle data |
| Communication Hub | email, SMS, in-app notifications, templates | notification logs and templates |
| Billing & Subscription | plans, usage, invoices, payment provider abstraction | billing metadata |
| Analytics & Reporting | funnel analytics, employer KPIs, admin metrics | read models / aggregates |
| Plugin Platform | plugin registry, contracts, lifecycle, sandboxing | plugin metadata |
| Audit & Compliance | audit events, retention, legal requests | immutable audit trail |

### 5.4 Module Interaction Rules

- Modules call each other through **application service interfaces**, never direct table reads.
- Shared concepts live in a **shared kernel** only when stable and ubiquitous.
- Long-running actions publish **domain/integration events**.
- Search, email, indexing, resume parsing, and recommendation jobs are **asynchronous**.

---

## 6. Service Inventory

Although AiClod ships initially as a modular monolith, operational capabilities are separated into deployable runtime roles.

| Runtime | Primary Responsibility | Stateless | Scale Pattern |
|---|---|---|---|
| Web UI | Candidate, employer, and admin frontends | Yes | Scale on CPU/RPS |
| API | Main modular monolith serving REST/GraphQL and internal orchestration | Yes | Scale on CPU, memory, latency |
| Worker | Async jobs: notifications, indexing, resume parsing, exports, webhooks | Yes | Scale on queue depth |
| Scheduler | Cron-driven workflows, cleanup, sync jobs | Yes | 1 active / leader elected |
| Plugin Runtime | Controlled execution for plugin hooks and outbound integrations | Prefer yes | Scale with plugin demand |
| Search Engine | Full-text search and faceted filtering | Usually external | Scale by shard/replica |
| PostgreSQL | Source-of-truth relational database | No | Vertical + read replicas |
| Redis | cache, rate limiting, session state, queues/streams | No | HA or managed |
| Object Storage | resumes, logos, exports, generated reports | N/A | External service |
| Message Broker | event distribution and job buffering | No | Clustered / managed |

---

## 7. Data Architecture

### 7.1 Primary Storage Choices

- **PostgreSQL** for transactional consistency, relational data, JSONB flexibility, and partitioning support.
- **Redis/Valkey** for caching, distributed locks, session/token adjuncts, rate limiting, and short-lived workflow state.
- **S3-compatible Object Storage** for resumes, company branding assets, generated exports, and audit archives.
- **OpenSearch/Elasticsearch** for low-latency job search and candidate discovery.
- **Message Broker / Queue** for async work and integration events. Options include RabbitMQ, NATS JetStream, Kafka, Redis Streams, or cloud-managed equivalents.

### 7.2 Logical Data Domains

```mermaid
flowchart LR
    tenant[Tenant Data]
    identity[Identity Data]
    employer[Employer Data]
    candidate[Candidate Data]
    jobs[Job Data]
    apps[Application Data]
    billing[Billing Data]
    audit[Audit Data]
    searchdocs[Search Documents]
    objects[Object Blobs]

    tenant --> apps
    identity --> employer
    identity --> candidate
    employer --> jobs
    candidate --> apps
    jobs --> apps
    apps --> billing
    jobs --> searchdocs
    candidate --> searchdocs
    candidate --> objects
    employer --> objects
    apps --> audit
```

### 7.3 Tenancy Model

Recommended default: **shared database, shared schema, tenant discriminator** with strong row-level isolation at the application and optionally database policy layer.

Upgrade path:
1. Shared schema for SMB and mid-market tenants.
2. Dedicated schema for regulated or high-scale tenants.
3. Dedicated database/cluster for strategic enterprise customers.

All tenancy modes should preserve the same repository contracts to avoid application rewrites.

---

## 8. Plugin-Based Extensibility

### 8.1 Plugin Goals

Plugins let AiClod extend core capabilities without polluting the domain model or tightly coupling to vendor APIs.

### 8.2 Supported Plugin Categories

- Job board syndication plugins.
- Resume parsing providers.
- Candidate assessment providers.
- CRM/ATS bridge connectors.
- Notification channels.
- Payment gateways.
- HRIS integrations.
- Background verification and compliance checks.
- AI enrichment and ranking adapters.

### 8.3 Plugin Architecture

```mermaid
flowchart TB
    api[API / Application Layer] --> registry[Plugin Registry]
    registry --> contracts[Plugin Contracts]
    registry --> policy[Permission & Policy Engine]
    registry --> runtime[Plugin Runtime / Sandbox]
    runtime --> hooks[Lifecycle Hooks]
    hooks --> sync[Sync Hooks]
    hooks --> async[Async Event Hooks]
    runtime --> adapters[External Provider Adapters]
    runtime --> audit[Audit & Metrics]
```

### 8.4 Plugin Model

- **Manifest-driven registration**: name, version, capabilities, required scopes, config schema, health endpoints.
- **Contract-first APIs**: each plugin type implements a narrow interface.
- **Feature flags**: plugins can be enabled by environment, tenant, plan, or user role.
- **Sandboxing options**:
  - In-process trusted plugins for first-party extensions.
  - Out-of-process sidecar/service plugins for third-party or high-risk logic.
- **Resilience**:
  - Timeout budgets.
  - Circuit breakers.
  - Retries with dead-letter queues.
  - Per-plugin rate limiting and quotas.

### 8.5 Future-Proofing

The plugin boundary doubles as the **microservice extraction seam**. A heavily used plugin runtime can later become an independent service without changing calling code materially.

---

## 9. Request and Event Flows

### 9.1 Candidate Job Search Flow

```mermaid
sequenceDiagram
    participant U as Candidate Browser
    participant W as Web UI
    participant A as API
    participant C as Cache
    participant S as Search Engine
    participant P as PostgreSQL

    U->>W: Search jobs
    W->>A: GET /jobs?filters=...
    A->>C: Check cached query
    alt Cache hit
        C-->>A: Search result page
    else Cache miss
        A->>S: Full-text + facets query
        S-->>A: Search results
        A->>C: Cache result
    end
    A->>P: Fetch policy-aware details as needed
    P-->>A: Job metadata
    A-->>W: Paginated result DTO
    W-->>U: Render results
```

### 9.2 Job Application Submission Flow

```mermaid
sequenceDiagram
    participant U as Candidate
    participant API as API
    participant OBJ as Object Storage
    participant DB as PostgreSQL
    participant MQ as Queue
    participant WRK as Worker
    participant NOTIF as Notification Plugin
    participant IDX as Search Indexer

    U->>API: Submit application + resume
    API->>OBJ: Upload resume
    API->>DB: Create application transaction
    API->>MQ: Publish ApplicationSubmitted
    API-->>U: 202/201 Success
    MQ-->>WRK: Consume event
    WRK->>NOTIF: Send confirmations
    WRK->>IDX: Update employer and candidate search views
    WRK->>DB: Persist workflow/audit updates
```

### 9.3 Employer Job Posting Flow

1. Recruiter creates or edits a draft job.
2. Domain policies validate plan limits, permissions, and required fields.
3. Approval workflow executes if the tenant requires review.
4. On publish, the job is committed to PostgreSQL.
5. `JobPublished` event is emitted.
6. Workers update search indexes, syndicate to external job boards, and notify followers/subscribers.

### 9.4 Analytics Flow

- Product and business events are emitted from the application layer.
- Events are routed to an analytics pipeline and/or warehouse.
- Operational dashboards use Prometheus + Grafana.
- Business intelligence can read from denormalized read models or a warehouse sink.

---

## 10. Scaling Strategy

### 10.1 Stateless Scale Units

**Horizontally scalable components:**
- Web UI
- API pods
- Worker pods
- Plugin runtime pods

These components must avoid local disk dependence except ephemeral cache or temp files.

### 10.2 Kubernetes Autoscaling

Recommended autoscaling layers:

1. **Horizontal Pod Autoscaler (HPA)**
   - API based on CPU, memory, and custom latency/RPS metrics.
   - Web based on CPU and request concurrency.

2. **KEDA or queue-driven autoscaling**
   - Worker pods scale from queue depth, lag, or stream backlog.
   - Plugin runtime scales by plugin-specific queues.

3. **Cluster Autoscaler / Node Autoscaler**
   - Adds nodes when pod scheduling pressure increases.

4. **Vertical Pod Autoscaler (selective)**
   - Recommended for rightsizing non-bursty control-plane workloads, not as the primary scaling method for API pods.

### 10.3 Database Scaling

- Start with one primary PostgreSQL instance and automated backups.
- Add **read replicas** for reporting and read-heavy endpoints.
- Use **connection pooling** via PgBouncer.
- Partition large tables such as audit logs, applications, and activity streams.
- Archive historical data into object storage or cold analytics systems.

### 10.4 Search Scaling

- Use separate ingest and query node roles when search traffic becomes significant.
- Increase shard count conservatively; prefer larger shards over too many tiny shards.
- Reindex asynchronously via background workers.

### 10.5 Cache Scaling

- Cache hot reference data, public job searches, auth/session adjuncts, and rate-limit counters.
- Use tenant-aware cache keys.
- Apply explicit TTLs and stampede protection.

### 10.6 Traffic Management

- Rolling updates with readiness probes.
- Canary or blue/green deployments for risky releases.
- Sticky sessions should be avoided; use token-based auth.
- Global CDN for static assets and media delivery.

### 10.7 Multi-Region Strategy

Phase-based evolution:
- **Phase 1**: single region, multi-AZ.
- **Phase 2**: active/passive disaster recovery with database replication and object storage replication.
- **Phase 3**: active/active read-local patterns for search and content, with carefully scoped write ownership.

---

## 11. Security Architecture

### 11.1 Identity and Access

- OIDC/SAML-compatible identity provider.
- Support local auth, social login, and enterprise SSO.
- RBAC for platform roles and tenant roles.
- Optional ABAC for premium workflows.
- SCIM for enterprise provisioning.

### 11.2 Data Security

- TLS everywhere in transit.
- AES-256 or cloud-native encryption at rest.
- Secrets in Vault, External Secrets, or cloud secret managers.
- PII minimization and field-level access control.
- Resume/document scanning before persistence.

### 11.3 Platform Security

- Kubernetes NetworkPolicies.
- Pod security standards.
- Non-root containers.
- Signed images and SBOM generation.
- WAF + rate limiting at ingress.
- Audit trail for admin and high-risk actions.

### 11.4 Compliance Readiness

Design for:
- GDPR and CCPA deletion/export workflows.
- SOC 2 evidence capture.
- Tenant-specific retention policies.
- Immutable audit logs.

---

## 12. Reliability and Disaster Recovery

### 12.1 Reliability Targets

- API availability target: **99.9%+** for standard plans.
- RPO target: **< 15 minutes** for transactional data.
- RTO target: **< 1 hour** for primary-region recovery in the baseline design.

### 12.2 Resilience Patterns

- Idempotent async jobs.
- Retries with exponential backoff.
- Dead-letter queues.
- Circuit breakers for plugins and third-party providers.
- Health checks: liveness, readiness, startup probes.
- Graceful shutdown and in-flight job draining.

### 12.3 Backup Strategy

- PostgreSQL PITR backups.
- Redis persistence if used beyond ephemeral caching.
- Object storage versioning.
- Search index rebuild scripts from source-of-truth data.

---

## 13. Observability

### 13.1 Telemetry Standards

- **Metrics**: Prometheus/OpenMetrics.
- **Tracing**: OpenTelemetry.
- **Logs**: structured JSON logs aggregated in Loki/ELK.

### 13.2 Golden Signals

- Request rate, error rate, duration.
- Queue depth and job latency.
- DB query latency and saturation.
- Cache hit ratio.
- Search latency and indexing lag.
- Plugin success/failure rate.

### 13.3 Business KPIs

- Job posting conversion.
- Candidate application completion rate.
- Employer time-to-fill.
- Search-to-apply funnel.
- Notification delivery rate.

---

## 14. CI/CD and Environment Promotion

### 14.1 Environments

- Local
- Development
- Staging
- Production

### 14.2 Delivery Pipeline

1. Run linting, unit tests, contract tests, and security scanning.
2. Build immutable container images.
3. Generate SBOM and sign images.
4. Push Helm chart/Kustomize manifests.
5. Deploy automatically to development.
6. Promote to staging after smoke tests.
7. Use manual or policy-gated promotion to production.

### 14.3 IaC Approach

- Terraform/OpenTofu for cloud resources.
- Helm or Kustomize for Kubernetes manifests.
- Compose file for local parity.

---

## 15. Local-to-Cloud Parity Strategy

### 15.1 Docker Compose Services

Recommended local stack:
- `web`
- `api`
- `worker`
- `scheduler`
- `postgres`
- `redis`
- `minio`
- `mailhog`
- `opensearch` (optional profile)
- `otel-collector`

### 15.2 Kubernetes Workloads

Recommended production workloads:
- `Deployment/web`
- `Deployment/api`
- `Deployment/worker`
- `Deployment/plugin-runtime`
- `CronJob/scheduler-jobs`
- `Ingress/aiclod`
- `HPA/api`
- `ScaledObject/worker` (if using KEDA)
- `NetworkPolicy/*`
- `ExternalSecret/*`

### 15.3 Configuration Strategy

- Twelve-factor configuration.
- Environment variables for endpoints, credentials references, feature flags, tenant defaults.
- Avoid environment-specific code branches.

---

## 16. Evolution Path to Microservices

The modular monolith is intentionally organized so high-change or high-scale modules can be extracted later.

### 16.1 Likely First Extractions

1. Search & Discovery service.
2. Communication/Notification service.
3. Analytics/Reporting pipeline.
4. Plugin Runtime / Integration Hub.
5. Billing service.

### 16.2 Extraction Criteria

Extract only when one or more of the following occur:
- Independent scaling needs.
- Distinct team ownership.
- Security or compliance isolation requirements.
- Release cadence conflicts.
- Technology specialization needs.

### 16.3 Extraction Method

- Keep current module interfaces stable.
- Replace in-process calls with async messages or service APIs.
- Move module-owned tables into service-owned storage.
- Preserve domain events and contracts.

---

## 17. Complete Open-Source Technology Stack

This section defines the **recommended default open-source stack** for AiClod. Every choice is biased toward:

- strong performance for search-heavy and workflow-heavy job portal traffic,
- horizontal scalability on Kubernetes,
- fast local development with Docker Compose, and
- cloud-agnostic deployment without locking the platform to a single provider.

### 17.1 Primary Stack Decisions

| Layer | Selected Open-Source Tooling | Why This Is the Best Default for AiClod |
|---|---|---|
| Frontend | **Next.js (React, TypeScript)** | Hybrid SSR/ISR/CSR delivery improves SEO for public job pages, keeps the employer dashboard responsive, and deploys cleanly in containers or static/CDN-assisted modes. |
| Backend | **NestJS on Node.js (TypeScript)** | Strong module system, DI, and testing ergonomics align well with a modular monolith and clean architecture while supporting high developer velocity and a unified TypeScript stack. |
| API Contracts | **OpenAPI + REST**, optional **GraphQL** for back-office aggregation | REST keeps public/job application flows cacheable and simple, while GraphQL can be selectively introduced for complex employer/admin UIs without forcing it across the whole platform. |
| Database | **PostgreSQL** | Mature relational consistency, excellent indexing, JSONB support, partitioning, and reliable cloud/self-hosted options make it the strongest source-of-truth database for SaaS transactional workloads. |
| Search | **OpenSearch** | Open-source Lucene-based search with robust full-text, faceting, ranking, and analyzers needed for jobs and candidate discovery at scale. |
| Cache | **Valkey** | Open-source Redis-compatible cache with strong ecosystem compatibility, low latency, and easy use for caching, rate limiting, and ephemeral coordination. |
| Queue / Async | **RabbitMQ** | Excellent fit for business workflows, retries, dead-letter queues, routing patterns, and operational simplicity for a modular monolith before Kafka-level scale is required. |
| Object Storage | **MinIO** | S3-compatible, self-hostable, performs well locally and in Kubernetes, and preserves portability to any S3-compatible or hyperscaler object storage target. |
| Authentication / IAM | **Keycloak** | Mature open-source identity platform with OIDC, SAML, MFA, social login, brokered enterprise SSO, and multi-tenant-friendly realm/client patterns. |
| Container Build / Runtime | **Docker + BuildKit** | Ubiquitous local developer experience, deterministic image builds, and straightforward CI/CD integration. |
| Local Orchestration | **Docker Compose** | Lowest-friction way to run the full developer stack locally with parity for supporting services. |
| Cloud Orchestration | **Kubernetes** | The most portable scheduling and autoscaling substrate across managed or self-hosted environments. |
| Kubernetes Packaging | **Helm** with optional **Kustomize overlays** | Helm provides reusable packaging; Kustomize is useful for environment-specific overlays without changing application code. |
| Ingress | **ingress-nginx** | Widely adopted, cloud-neutral, and feature-rich enough for TLS termination, rate limiting, and path/domain routing. |
| Certificate Management | **cert-manager** | Standard Kubernetes-native automation for ACME/internal PKI certificate issuance and rotation. |
| Secrets Delivery | **External Secrets Operator** | Keeps workloads cloud-agnostic while supporting multiple secret backends such as Vault, AWS, Azure, or GCP. |
| GitOps Delivery | **Argo CD** | Open-source, Kubernetes-native continuous delivery with strong drift detection and environment promotion support. |
| Infrastructure as Code | **OpenTofu** | Open-source Terraform-compatible IaC with strong multi-cloud and self-hosted ecosystem support. |
| CI | **Woodpecker CI** | Lightweight, fully open-source, container-native CI that can be self-hosted on any cloud or on-prem environment without tying delivery to a proprietary control plane. |
| Image Registry | **Harbor** | Open-source OCI registry with role-based access control, image signing support, retention policies, and strong Kubernetes ecosystem alignment. |
| Vulnerability Scanning | **Trivy** | Fast open-source scanning for containers, IaC, and dependencies that fits both CI pipelines and admission/policy checks. |
| Observability | **OpenTelemetry Collector + Prometheus + Grafana + Loki + Tempo** | End-to-end open-source telemetry stack for metrics, logs, and traces with portable instrumentation and deep Kubernetes support. |
| Policy / Security | **Kyverno** | Kubernetes-native policy-as-code for image, pod, and security guardrails without requiring deep Rego expertise. |
| Service Networking | **Cilium** | High-performance eBPF-based networking, policy enforcement, and observability while remaining Kubernetes-distribution agnostic. |
| Database Migrations | **Prisma Migrate** or **Flyway** | Schema evolution can stay disciplined and automated; Prisma suits TypeScript-heavy teams, Flyway suits broader polyglot ecosystems. |
| Background Scheduling | **Kubernetes CronJobs + NestJS scheduler adapters** | Keeps scheduled work simple initially and migratable later without introducing a separate orchestration platform too early. |

### 17.2 Detailed Justification by Platform Area

#### Frontend: Next.js + React + TypeScript

**Why it fits:**
- Public job listings benefit from **server-side rendering** and **incremental static regeneration**, which improves SEO and time-to-content.
- Employer dashboards and candidate profile workflows benefit from React’s component ecosystem and mature state/data libraries.
- TypeScript shared contracts reduce drift between UI and backend DTOs.

**Scalability and performance rationale:**
- Public, cacheable routes can be pushed to a CDN and served as edge-cached HTML.
- Authenticated dashboards can use client-side hydration and API caching patterns.
- Split rendering strategies let AiClod optimize public job discovery and private SaaS interactions independently.

**Cloud-agnostic rationale:**
- Can run as a standard Node.js container on Kubernetes.
- Can also export/cache static assets behind any CDN or object storage endpoint.

#### Backend: NestJS on Node.js

**Why it fits:**
- NestJS enforces module boundaries that align well with the modular monolith domains defined earlier.
- Dependency injection, interceptors, guards, and pipes support clean architecture, authorization, validation, and observability.
- Shared TypeScript across frontend and backend improves productivity and reduces integration errors.

**Scalability and performance rationale:**
- Node.js is highly effective for I/O-heavy SaaS workloads such as auth, CRUD, search APIs, messaging, and plugin orchestration.
- Heavy CPU or ML-like tasks can be pushed to background workers or isolated plugin runtimes rather than overloading request threads.
- Horizontal scaling is straightforward because API instances stay stateless.

**Cloud-agnostic rationale:**
- Runs identically in Docker Compose, Kubernetes, or any OCI-compatible environment.
- No dependence on provider-specific serverless primitives.

#### Database: PostgreSQL

**Why it fits:**
- Job applications, employer subscriptions, audit records, workflow states, and permissions all need strong relational integrity.
- JSONB supports controlled schema flexibility for plugin metadata, dynamic job attributes, and external payload snapshots.

**Scalability and performance rationale:**
- Strong indexing, partitioning, and read-replica support allow AiClod to scale beyond early-stage usage without replatforming.
- PgBouncer, partitioned tables, materialized views, and CDC patterns support growth in traffic and analytics.

**Cloud-agnostic rationale:**
- Available everywhere: managed services, operators on Kubernetes, or self-hosted VMs.
- Avoids dependence on a proprietary globally distributed SQL layer too early.

#### Search: OpenSearch

**Why it fits:**
- AiClod requires relevance-ranked full-text search, aggregations, filters, synonyms, analyzers, and indexing pipelines.
- Candidate and job discovery are first-class product capabilities, not optional features.

**Scalability and performance rationale:**
- Search workloads are isolated from transactional reads, reducing pressure on PostgreSQL.
- Horizontal shard/replica scaling and async indexing let search grow independently from the core API.

**Cloud-agnostic rationale:**
- OpenSearch can be self-managed or consumed as a compatible managed service without changing the application contract.

#### Cache: Valkey

**Why it fits:**
- Provides the Redis-compatible ecosystem AiClod needs for low-latency caching, rate limiting, distributed locks, and ephemeral state.
- Avoids coupling the platform to non-open licensing directions.

**Scalability and performance rationale:**
- Extremely low-latency reads help absorb repeated search/filter requests and hot configuration lookups.
- Reduces database pressure during traffic spikes.

**Cloud-agnostic rationale:**
- Runs locally, on Kubernetes, or through managed Redis-compatible services with minimal changes.

#### Queue / Messaging: RabbitMQ

**Why it fits:**
- AiClod’s async workflows are business-event-driven: notifications, job syndication, parsing, indexing, exports, and webhooks.
- RabbitMQ’s exchanges, routing keys, retries, and dead-letter queues fit these patterns exceptionally well.

**Scalability and performance rationale:**
- Handles moderate-to-high throughput very well without the operational overhead of Kafka for an initial modular monolith.
- Consumers can scale independently by queue depth using KEDA.

**Cloud-agnostic rationale:**
- RabbitMQ works the same across Compose, Kubernetes, VMs, and managed offerings.

#### Object Storage: MinIO

**Why it fits:**
- Resumes, employer logos, attachments, exports, and generated reports belong in S3-compatible object storage, not the relational database.
- MinIO gives the same API locally and in self-hosted production.

**Scalability and performance rationale:**
- Object storage scales far better than shared filesystems for user-uploaded content.
- Presigned URLs and CDN fronting reduce application bandwidth costs and latency.

**Cloud-agnostic rationale:**
- S3 API compatibility preserves the option to move between MinIO, Ceph RGW, AWS S3, GCS interoperability layers, and other compatible providers.

#### Authentication / IAM: Keycloak

**Why it fits:**
- AiClod needs candidate auth, recruiter auth, admin auth, enterprise SSO, and optional social login without building identity in-house.
- Keycloak supports OIDC, SAML, MFA, identity brokering, fine-grained clients, and admin APIs.

**Scalability and performance rationale:**
- Centralizing auth removes security-critical complexity from the application codebase.
- Scales horizontally behind Kubernetes with externalized databases and caches.

**Cloud-agnostic rationale:**
- Fully open-source and deployable on any infrastructure without vendor lock-in.

### 17.3 DevOps and Platform Tooling

#### Build, Packaging, and Delivery

- **Docker + BuildKit** for reproducible image builds and layer caching.
- **Docker Compose** for local full-stack parity.
- **Kubernetes** as the production scheduler for portable autoscaling and rolling deployments.
- **Helm** for packaging reusable charts, with **Kustomize** overlays where environment patching is useful.
- **Argo CD** for GitOps-based reconciliation and auditability.
- **Woodpecker CI** for self-hosted pipeline execution.
- **Harbor** for OCI image storage, signing workflows, and retention controls.
- **Trivy** for image, filesystem, and IaC vulnerability scanning.
- **OpenTofu** for provisioning DNS, networking, managed databases, buckets, and cluster dependencies across clouds.

**Why this combination works:**
- It preserves a consistent artifact model from local to production.
- It avoids provider-specific deployment frameworks.
- It keeps rollback, drift detection, and environment promotion explicit and auditable.

#### Networking and Security Controls

- **ingress-nginx** for L7 ingress control.
- **cert-manager** for certificate automation.
- **External Secrets Operator** for secret synchronization.
- **Kyverno** for policy enforcement on pods, images, and namespaces.
- **Cilium** for high-performance networking and network policy enforcement.

**Why this combination works:**
- All components are open-source, Kubernetes-native, and portable across managed and self-hosted clusters.
- They improve security posture without changing application code.

#### Observability Stack

- **OpenTelemetry Collector** for telemetry ingestion and vendor-neutral instrumentation.
- **Prometheus** for metrics scraping and alerting inputs.
- **Grafana** for dashboards.
- **Loki** for logs.
- **Tempo** for traces.

**Why this combination works:**
- It gives AiClod complete observability with a standard open-source stack.
- The same instrumentation can later feed commercial APM tools if required, preserving optionality.

### 17.4 End-to-End Stack Summary

```text
Frontend:        Next.js + React + TypeScript
Backend:         NestJS + Node.js + TypeScript
Database:        PostgreSQL
Search:          OpenSearch
Cache:           Valkey
Queue:           RabbitMQ
Storage:         MinIO (S3-compatible)
Authentication:  Keycloak
Local Dev:       Docker Compose
Cloud Runtime:   Kubernetes
Packaging:       Helm + Kustomize
GitOps:          Argo CD
IaC:             OpenTofu
Ingress:         ingress-nginx
Secrets:         External Secrets Operator
TLS:             cert-manager
Policy:          Kyverno
Network:         Cilium
Observability:   OpenTelemetry + Prometheus + Grafana + Loki + Tempo
CI:              Woodpecker CI
```

### 17.5 Why This Stack Is the Recommended Default

This stack is the best default for AiClod because it combines:

- **strong developer productivity** through TypeScript, NestJS, React, and Docker Compose,
- **scalable runtime characteristics** through stateless app tiers, RabbitMQ workers, OpenSearch, and PostgreSQL,
- **cloud portability** through Kubernetes, OpenTofu, S3-compatible storage, and open protocols, and
- **low lock-in risk** because every critical component has a strong open-source deployment path.

The result is a platform that can launch quickly as a modular monolith, scale to meaningful SaaS traffic, and evolve into a more distributed architecture only when that complexity becomes justified.
## 17. Recommended Technology Baseline

This architecture is cloud-agnostic, so the technology list is intentionally interchangeable.

| Concern | Preferred Baseline | Acceptable Alternatives |
|---|---|---|
| Frontend | React/Next.js | Vue/Nuxt, Angular |
| Backend | Node.js (NestJS) or Java/Kotlin (Spring Boot) or .NET | Go, Python/FastAPI |
| Database | PostgreSQL | MySQL-compatible if required |
| Cache | Redis / Valkey | KeyDB |
| Search | OpenSearch | Elasticsearch, Meilisearch (smaller scale) |
| Queue | RabbitMQ / NATS / Redis Streams / Kafka | Cloud-native queues |
| Object Storage | S3-compatible | Azure Blob, GCS, MinIO |
| Auth | Keycloak / Auth0 / Ory / cloud OIDC | Custom auth only if unavoidable |
| Deployment | Kubernetes + Helm/Kustomize | OpenShift, Rancher, managed K8s |
| Telemetry | OpenTelemetry + Prometheus + Grafana | Vendor APM with OTel support |

---

## 18. Executive Summary

AiClod should launch as a **modular monolith** with four primary runtime roles: **web**, **API**, **worker**, and **scheduler**, backed by the following **default open-source stack**:

- **Frontend:** Next.js + React + TypeScript
- **Backend:** NestJS + Node.js + TypeScript
- **Database:** PostgreSQL
- **Search:** OpenSearch
- **Cache:** Valkey
- **Queue/Eventing:** RabbitMQ
- **Object Storage:** MinIO
- **Authentication:** Keycloak
- **Delivery:** Woodpecker CI + Harbor + Trivy
- **Platform:** Docker Compose locally, Kubernetes + Helm + Argo CD in the cloud
- **Observability:** OpenTelemetry + Prometheus + Grafana + Loki + Tempo

This provides:
AiClod should launch as a **modular monolith** with four primary runtime roles: **web**, **API**, **worker**, and **scheduler**, backed by **PostgreSQL**, **Redis**, **object storage**, **search**, and a **queue/event layer**. This provides:

- Simple developer onboarding through Docker Compose.
- Production-grade Kubernetes deployment with autoscaling.
- Clean Architecture boundaries to protect core domain logic.
- Plugin-driven extensibility for partner and AI integrations.
- A fully open-source, cloud-agnostic platform baseline.
- A deliberate migration path toward microservices only when justified by scale, team topology, or compliance needs.

This design minimizes premature operational complexity while preserving clear extraction seams for future growth.

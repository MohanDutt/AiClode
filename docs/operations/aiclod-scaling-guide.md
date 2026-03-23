# AiClod Scaling Guide

## Overview

AiClod should scale horizontally at the application layer and selectively at the data/queue/search layers. This guide describes the baseline scaling approach for web, API, worker, search, communications, AI, and admin workloads.

## Workload Categories

### Web

- Scale on request rate, latency, and cache hit ratio.
- Keep web nodes stateless and CDN-friendly.
- Prefer SSR caching and route-level revalidation to reduce origin load.

### API

- Scale on CPU, memory, p95 latency, and database connection pressure.
- Use read/write timeouts and bulkheads around search, AI, and communication providers.
- Split heavy admin and reporting paths if they begin to contend with user-facing traffic.

### Worker

- Scale on queue depth, processing latency, and retry backlog.
- Separate worker pools for communications, AI jobs, indexing, billing, and moderation if queues diverge materially.
- Consider KEDA or queue-depth driven autoscaling for bursty async pipelines.

## Data Layer Scaling

### PostgreSQL

- Add connection pooling early.
- Use read replicas for analytics/reporting paths where consistency tolerates lag.
- Partition large event, audit, recommendation, and analytics tables.

### OpenSearch

- Separate hot query nodes from indexing-heavy workloads when search volume grows.
- Monitor shard size, JVM pressure, and indexing latency.
- Keep semantic/vector workloads isolated from general keyword search if AI retrieval becomes dominant.

### Redis / Valkey and RabbitMQ

- Use Redis for low-latency caches, rate limits, websocket presence, and ephemeral coordination.
- Use RabbitMQ for durable async pipelines such as notifications, AI jobs, moderation review, and fraud analysis.
- Track unacked messages, consumer lag, and DLQ rates.

## AI and Admin Scaling

### AI Pipelines

- Separate online inference from batch scoring where possible.
- Queue long-running resume scoring and forecast generation.
- Keep fallback rules available when providers degrade or cost limits are hit.

### Admin Workloads

- Precompute dashboard snapshots for expensive moderation, finance, and fraud aggregations.
- Isolate heavy admin/reporting queries from tenant-facing OLTP paths.
- Protect moderation and fraud queues with SLOs and backlog alerts.

## Recommended Metrics

- request rate, error rate, and latency by route group
- queue depth and age by worker type
- database CPU, IOPS, lock waits, and replication lag
- search latency, shard health, and indexing throughput
- AI latency, token usage, fallback rate, and cost per workflow
- admin backlog, moderation throughput, fraud review turnaround time, and dashboard freshness

## Scaling Playbook

1. Confirm the saturated dependency (web, API, queue, DB, search, AI provider, or admin query path).
2. Reduce unnecessary load with caching, batching, or feature-flagged degradation.
3. Increase replicas or queue consumers where the workload is stateless.
4. Tune downstream capacity (DB/search/broker) before further app scaling if bottlenecks persist.
5. Record the incident, thresholds, and final tuning choices in an operations runbook.

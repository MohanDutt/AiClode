# AiClod AI Features

## Overview

AiClod should expose AI capabilities as governed platform features rather than one-off experiments. The scaffold in this repository now defines configuration and architectural defaults for:

- job recommendations,
- resume scoring,
- skill-gap analysis,
- predictive hiring analytics, and
- candidate and recruiter chatbot support.

## AI Design Principles

- Keep deterministic business rules separate from probabilistic model outputs.
- Require feature flags, model routing, and prompt templates to be versioned configuration.
- Capture confidence scores, explanations, and audit metadata for AI-assisted decisions.
- Allow human override for hiring actions that affect candidate progression or employer spend.

## Job Recommendations

Recommended baseline:

- combine lexical search, semantic retrieval, and behavioral signals,
- personalize by locale, timezone, market, skills, salary range, and candidate activity, and
- fall back to deterministic ranking when embeddings or AI providers are unavailable.

## Resume Scoring

Resume scoring should produce an explainable score band, strengths, risks, and normalization notes. Scoring pipelines should combine parsing, rule-based enrichment, and model-generated rationale while avoiding irreversible automated rejection decisions.

## Skill-Gap Analysis

Skill-gap analysis should compare required skills against candidate evidence and return:

- missing skills,
- adjacent or transferable skills,
- recommended learning actions, and
- confidence indicators for each inferred gap.

## Predictive Hiring Analytics

Predictive analytics should forecast metrics such as application-to-interview conversion, time-to-fill, offer acceptance probability, and sourcing channel quality. Forecasts should be tenant-aware and should clearly distinguish observed metrics from predicted outcomes.

## Chatbot Support

The chatbot should support candidate self-service, recruiter workflow assistance, and escalation to humans. A safe baseline includes retrieval over public help content, tenant policy snippets, and contextual application data with explicit permission checks.

## Configuration Assets

The repository includes:

- `config/ai/features.yaml` for feature flags and queues,
- `config/ai/model-routing.json` for model selection defaults, and
- `config/ai/prompts/*.yaml` for versioned prompt templates.

## Deployment Notes

- Runtime defaults are exposed through environment templates, Docker Compose, and Helm config values.
- AI inference can target a managed gateway or an internal orchestration service, but the integration point should remain a configurable base URL.
- Worker traces should include AI request latency, queue wait time, provider response status, and fallback reason codes.

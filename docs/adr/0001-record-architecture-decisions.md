# ADR-0001: Record architecture decisions

- **Status:** Accepted
- **Date:** 2026-10-02
- **Issue:** —

## Context

Several people and AI agents contribute to this project. Without a record of why things were built a certain way, decisions get re-litigated or silently reversed.

## Decision

We will keep Architecture Decision Records in `docs/adr/`, one Markdown file per decision, based on [template.md](template.md). An ADR is added in the same PR as any new functionality or architectural change.

## Alternatives Considered

- **No formal records** — rationale gets lost in chat and PR history.
- **Wiki pages** — live outside the repo and drift from the code.

## Consequences

- Decisions are reviewable alongside the code that implements them.
- Contributors spend a few minutes per significant change writing an ADR.

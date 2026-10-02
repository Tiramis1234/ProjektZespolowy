# ADR-0002: Trunk-based branching on `main`

- **Status:** Accepted
- **Date:** 2026-10-02
- **Issue:** —

## Context

The team needs a simple branching model that works with CI/CD and keeps integration problems small.

## Decision

We will use `main` as the only long-lived branch. CI/CD runs on `main`. Every GitHub issue gets a short-lived branch named `<type>/<issue-number>-<short-description>`, merged via pull request and deleted after merge. Commits follow Conventional Commits with a single-line message; details go in the PR description.

## Alternatives Considered

- **Git Flow (`develop`, `release/*`)** — more ceremony and long-lived divergence than a small team needs.
- **Committing directly to `main`** — no review and no CI gate before integration.

## Consequences

- `main` must stay releasable; broken builds are fixed immediately via `hotfix/` branches.
- Branches must stay small and short-lived to avoid painful merges.

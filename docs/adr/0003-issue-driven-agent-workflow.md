# ADR-0003: Issue-driven agent workflow with enforced conventions

- **Status:** Accepted
- **Date:** 2026-10-02
- **Issue:** —

## Context

Humans and AI agents work side by side. Without guardrails, agents may pick up work nobody asked for, guess at unclear requirements, rewrite the project rules, or drift from the branch and commit conventions.

## Decision

- Work is tracked as GitHub issues on a kanban board (GitHub Projects). Each person works only on issues assigned to them; an agent works only on issues assigned to its human co-author.
- Agents always start in plan mode and ask clarifying questions instead of assuming. Claude Code enforces plan mode through `.claude/settings.json`.
- Only the repository owner may change `AGENTS.md` and `CLAUDE.md`, enforced by `CODEOWNERS` and CI.
- A `Conventions` GitHub Actions workflow checks branch names, PR titles, commit messages, AI co-author trailers, and protected files on every PR.
- Issue forms (feature, bug, task) and a PR template standardize what goes into issues and PRs.

## Alternatives Considered

- **Rules in docs only** — easy to forget or ignore; CI makes them visible at review time.
- **Third-party lint actions (e.g. commitlint)** — extra dependencies for checks a short shell script already covers.

## Consequences

- PRs that break conventions fail CI and must be fixed before merge.
- Plan mode and questions add a little upfront time but reduce rework.
- The owner-only check relies on `github.repository_owner`; if the repo moves to an organization, the check must be updated to use a team or allowed-user list.

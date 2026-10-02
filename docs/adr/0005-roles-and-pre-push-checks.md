# ADR-0005: Roles, owner-only issues, and pre-push checks

- **Status:** Accepted
- **Date:** 2026-10-02
- **Issue:** —

## Context

The team needs a single person to control what work exists, and agents need clear limits on what they may do. Convention violations caught only in CI waste a round trip.

## Decision

- The repository has roles. The owner can do everything; contributors work on assigned issues, comment, and open/review PRs. An AI agent has exactly its co-author's role.
- Only the repository owner creates issues. The `Issue guard` workflow closes issues opened by anyone else.
- Protected files (rules, workflows, hooks, convention script) can only be changed by the owner, enforced by `CODEOWNERS` and CI.
- A versioned `pre-push` hook in `.githooks/` blocks pushes to `main` and runs `scripts/check-conventions.sh` (and `scripts/test.sh` when it exists). CI runs the same script, so local and CI checks cannot drift.
- PR titles and descriptions are checked for AI attribution as well as commits.

## Alternatives Considered

- **Third-party hook managers (husky, pre-commit, lefthook)** — tied to a language ecosystem before the stack is chosen; `core.hooksPath` needs nothing extra.
- **Relying on GitHub permissions alone** — GitHub cannot stop collaborators from opening issues.

## Consequences

- Each clone must run `git config core.hooksPath .githooks` once; CI still catches anyone who skips it.
- Contributors must route bugs and ideas through the owner.
- The owner-only checks rely on `github.repository_owner`; moving the repo to an organization requires updating them.

# ADR-0004: Test-driven development with coverage and mutation testing

- **Status:** Accepted
- **Date:** 2026-10-02
- **Issue:** —

## Context

Humans and AI agents both write code here. AI-written code in particular can look plausible while being wrong, and high line coverage alone does not prove tests catch faults.

## Decision

- All production code is written test-first using red → green → refactor.
- Four test types are required: unit, e2e, regression (for every bug fix), and mutation testing.
- New and changed code must have 100% line and branch coverage; the project-wide minimum is 90%; mutation score on changed code must be at least 80%.
- Fast tests (unit, regression, coverage) run in the pre-push hook; all test types run in CI.
- Concrete tools are chosen together with the tech stack and recorded in AGENTS.md.

## Alternatives Considered

- **Tests after implementation** — tends to test what the code does rather than what it should do, and leaves gaps.
- **Coverage only, no mutation testing** — coverage shows code was executed, not that tests would fail if it were wrong.

## Consequences

- Slower initial development in exchange for fewer regressions and safer refactoring.
- Mutation testing is slow, so it runs in CI rather than locally on every push.
- Thresholds can only be lowered by the repository owner.

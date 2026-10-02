# ADR-0007: A local script opens PRs and moves cards to In Review

- **Status:** Accepted
- **Date:** 2026-10-02
- **Issue:** #9

## Context

Finishing a task took several manual steps: push, open a PR from the template, link the issue, and move the card to **In Review**. The goal was to open the PR automatically when the card moves to **In Review**. GitHub Actions cannot trigger on Projects v2 item changes for a user-owned board; the `projects_v2_item` event is only sent for organization projects.

## Decision

We will provide `scripts/review.sh`, run from the issue branch by whoever finished the task. It validates the branch, the issue title, and the generated PR description with `scripts/check-conventions.sh`, pushes, opens a ready-for-review PR into `main` (or reuses an open one), and moves the card to **In Review**. Moving the card and opening the PR are one step, so they cannot drift apart.

## Alternatives Considered

- **Scheduled workflow polling the board** — PRs opened with the workflow token do not trigger other workflows, so the required `conventions` check would never run. A personal token avoids that, but makes its owner the author of every PR, which skips the protected-files check for contributors' branches. It would also lag by the schedule interval.
- **Moving the repository and board to an organization** — enables `projects_v2_item` webhooks, but needs a GitHub App or webhook receiver and changes the owner-only checks that rely on `github.repository_owner` (ADR-0005).

## Consequences

- PRs are authored by the person who did the work, and CI runs as usual.
- Dragging a card to **In Review** in the board UI does not open a PR; the script is the supported path.
- The board's project and field ids are hard-coded in the script; recreating the board means updating them there and in AGENTS.md.

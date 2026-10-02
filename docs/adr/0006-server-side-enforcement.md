# ADR-0006: Enforce workflow rules on GitHub, not only locally

- **Status:** Accepted
- **Date:** 2026-10-02
- **Issue:** #7

## Context

ADR-0005 relies on a local `pre-push` hook plus a CI check. Neither was enforced by GitHub: the `main` ruleset only blocked deletion and force-push, the `Conventions` check was not required, `CODEOWNERS` review was not required, and squash merging was allowed. A PR could be merged with failing checks, and a contributor PR could delete the protected-files check by editing the workflow it runs from. The rule that a PR closes the issue named in its branch was not checked at all.

## Decision

- The `main` ruleset requires a pull request, the `conventions` status check, and an up-to-date branch. It requires no approvals, but it does require code-owner review, so changes to protected files need the owner's approval.
- The repository admin (the owner) may bypass the ruleset only through a pull request, so their own protected-file PRs can merge without a second reviewer, while direct pushes to `main` are rejected for everyone.
- Only merge commits and rebase merges are allowed; head branches are deleted on merge.
- `scripts/check-conventions.sh` fails a PR whose description lacks `Closes #<n>` for the issue number in the branch name.
- Claude Code settings deny `--no-verify` and ask before force pushes, `git reset --hard`, and `rm -rf`.

## Alternatives Considered

- **Require one approval on every PR** — too slow for a two-person team; CI plus code-owner review on protected files covers the risky changes.
- **Check that the issue is assigned to the PR author in CI** — needs an extra API call and token scope for little gain while the owner assigns every issue.

## Consequences

- A PR with failing conventions cannot be merged, and a stale branch must be updated from `main` first.
- Protected-file changes by contributors wait for the owner's review.
- Board automation (adding issues, moving cards on merge) is configured in the project's UI and is not versioned here.

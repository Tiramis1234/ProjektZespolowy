# AGENTS.md

This file defines the working standards for human and AI contributors in this repository.

> **Only the repository owner may change this file or `CLAUDE.md`.** See [Protected Files](#protected-files).

## AI Agent Rules

These apply to every AI agent (Claude, Codex, Gemini, ChatGPT, Copilot, etc.). The human you are working with is your **co-author**.

- **Your role is your co-author's role.** Never do anything their [role](#roles) does not allow, even if asked. If a task needs a higher role, stop and tell your co-author.
- **Always start in plan mode.** Explore read-only, then present a plan and wait for your co-author's approval before editing files, creating branches, or running anything that changes state. In Claude Code this is the default via `.claude/settings.json`; other agents must follow it manually.
- **Ask, don't assume.** Ask as many clarifying questions as needed before planning. Whenever anything is ambiguous — requirements, scope, naming, approach, acceptance criteria, test cases — ask instead of guessing. This applies during implementation too, not only at the start.
- **Only work on issues assigned to your co-author** (see [Task Board](#task-board)). If asked to work on anything else, point that out and ask before proceeding.
- **Follow TDD strictly** (see [Test-Driven Development](#test-driven-development)). Never write production code before a failing test requires it.
- **Never** add [AI attribution](#no-ai-attribution).
- **Never** bypass checks (`--no-verify`, disabling hooks, skipping tests, lowering thresholds).

## No AI Attribution

AI tools (Claude, Gemini, Codex, ChatGPT, Copilot, etc.) are never credited anywhere in this repository: no `Co-Authored-By` trailers in commits, no "Generated with ..." footers or co-author lines in PR titles and descriptions, and no attribution in issues or comments. The pre-push hook and CI reject commits and PRs that contain it.

## Roles

Every contributor has a role. An AI agent has exactly the role of its co-author — no more.

| Action                                                | Owner | Contributor |
| ----------------------------------------------------- | :---: | :---------: |
| Create issues                                         |  Yes  |     No      |
| Assign issues, manage the board                       |  Yes  |     No      |
| Comment on issues                                     |  Yes  |     Yes     |
| Work on issues assigned to them, move their own cards |  Yes  |     Yes     |
| Open and review pull requests                         |  Yes  |     Yes     |
| Change [protected files](#protected-files)            |  Yes  |     No      |
| Change repository settings, roles, branch protection  |  Yes  |     No      |

Additional roles: _TBD — defined by the owner._

To determine your co-author's role:

```bash
gh repo view --json owner --jq .owner.login   # repository owner
gh api user --jq .login                       # your co-author
```

If the logins match, the role is **Owner**; otherwise it is **Contributor** unless listed differently above. If unsure, ask.

## Scope

- Keep changes small, targeted, and directly tied to the requested outcome.
- Do not refactor unrelated code in the same change.
- Preserve existing behavior unless the task explicitly requires a behavior change.
- Treat public interfaces (APIs, CLI, data formats) as product surface area; do not make incidental contract changes.

## Workflow

1. Pick an issue assigned to you (or your co-author) from the [Task Board](#task-board).
2. Read the issue and its comments in full; ask about anything unclear.
3. Plan the change **including the test plan** (which unit, e2e, and regression tests) and get it approved before editing.
4. Create a dedicated branch for the issue from an up-to-date `main` (see [Branching](#branching)) and move the card to **In Progress**.
5. **Red:** write failing tests derived from the acceptance criteria.
6. **Green:** write the minimum code to make them pass.
7. **Refactor:** clean up with all tests green. Repeat 5–7 until every acceptance criterion is covered.
8. Run the full suite with coverage and mutation testing; close any gaps.
9. Update docs when setup, run commands, or behavior changed.
10. Add an ADR when the change introduces new functionality or an architectural decision (see [Architecture Decision Records](#architecture-decision-records-adr)).
11. Pull the latest `main` into your branch and fix any conflicts or failures (see [Pull Requests](#pull-requests)).
12. Push (the [pre-push hook](#local-setup) checks conventions and tests), open a pull request using the PR template, link the issue, and move the card to **In Review**.

## Local Setup

Enable the repository's git hooks once per clone:

```bash
git config core.hooksPath .githooks
```

The `pre-push` hook blocks pushes to `main` and runs [`scripts/check-conventions.sh`](scripts/check-conventions.sh) (branch name, commit messages, AI attribution). If `scripts/test.sh` exists, it also runs it. CI runs the same checks, so a push that skips the hook still fails review.

## Stack and Commands

_TBD — fill in once the tech stack is chosen._

| Purpose                      | Command |
| ---------------------------- | ------- |
| Install dependencies         | TBD     |
| Run the app                  | TBD     |
| Unit + regression tests      | TBD     |
| E2E tests                    | TBD     |
| Coverage report              | TBD     |
| Mutation tests               | TBD     |

When the stack is chosen, add `scripts/test.sh` (unit + regression tests with coverage thresholds, used by the pre-push hook) and a CI test job (all test types, coverage, and mutation testing).

## Task Board

Tasks are tracked as GitHub issues on the project's kanban board (GitHub Projects).

Project board: _TBD — add the link here._

| Column          | Meaning                                    |
| --------------- | ------------------------------------------ |
| **Todo**        | Ready to be picked up, assigned to someone |
| **In Progress** | Branch created, work ongoing               |
| **In Review**   | PR open, waiting for review                |
| **Done**        | PR merged, issue closed                    |

Rules:

- **Only the repository owner creates issues.** Issues opened by anyone else are closed automatically. Everyone else raises bugs, ideas, and proposals with the owner, who decides whether to create an issue.
- Only work on issues **assigned to you** (agents: assigned to your co-author). Do not pick up unassigned issues or issues assigned to someone else.
- If the issue lacks clear acceptance criteria, ask the owner before starting.
- Keep the card's column in sync with the actual state of the work.

Useful `gh` commands (requires `gh auth login`; board commands also need `gh auth refresh -s project`):

```bash
gh issue list --assignee @me --state open      # my assigned issues
gh issue view 12 --comments                    # read issue 12 and its discussion
gh issue view 12 --json assignees,projectItems # check assignee and board status
gh issue develop 12 --name feature/12-user-login --checkout  # branch linked to the issue
gh pr create --title "feat(auth): add login" --body-file <file>  # open PR
```

## Test-Driven Development

All production code is written test-first.

**Applies to:** production code — `feature/`, `bugfix/`, `hotfix/`, `refactor/`, and `test/` branches. **Exempt:** documentation, configuration, and CI-only changes (`docs/`, most `chore/`), and throwaway code on `spike/` and `research/` branches. Exempt changes still must not break existing tests.

**Cycle:**

1. **Red** — write a test for the next small piece of behavior. Run it and confirm it fails for the expected reason.
2. **Green** — write the minimum code to make it pass.
3. **Refactor** — improve code and tests while everything stays green.

**Rules:**

- No production code without a failing test that requires it.
- Every acceptance criterion in the issue maps to at least one test (unit, e2e, or regression — whichever fits).
- Every commit leaves the suite green: commit a test together with the code that makes it pass.
- Never delete, skip, or weaken a test to make it pass. Never lower coverage or mutation thresholds without owner approval.
- Tests are deterministic, isolated, and fast. Unit tests do not touch the real network, clock, filesystem, or randomness — inject or fake them.
- Test names describe behavior (`rejects_expired_token`, not `test_1`).

**Test types:**

| Type           | Purpose                                           | Required for                                 | Default location    |
| -------------- | ------------------------------------------------- | -------------------------------------------- | ------------------- |
| **Unit**       | One function/module in isolation                  | All new or changed logic                     | `tests/unit/`       |
| **E2E**        | Full user flows through the running application   | Every new or changed user-facing flow        | `tests/e2e/`        |
| **Regression** | Reproduce a fixed bug so it can never return      | Every bug fix — the failing test comes first | `tests/regression/` |
| **Mutation**   | Prove the tests actually catch faults in the code | All changed production code (run in CI)      | tool config         |

Use the stack's conventional layout if it differs from the defaults above, and record it in [Stack and Commands](#stack-and-commands).

**Coverage targets** (enforced in CI once the stack is set up):

- **100% line and branch coverage on new and changed code.**
- Project-wide minimum: 90% line and branch coverage.
- Mutation score on changed code: at least 80%. Surviving mutants are killed with new tests or justified in the PR.
- Coverage exclusions need an inline justification and a mention in the PR description.

**Where checks run:**

| Check                        | Pre-push  | CI  |
| ---------------------------- | :-------: | :-: |
| Conventions                  |    Yes    | Yes |
| Unit + regression + coverage |    Yes    | Yes |
| E2E                          | On demand | Yes |
| Mutation                     | On demand | Yes |

## Branching

`main` is the only long-lived branch. It is always releasable, and CI/CD runs on it. There are no `develop`, `release`, or other permanent branches.

- Never commit or push directly to `main`; all changes land through pull requests.
- One short-lived branch per GitHub issue, created from an up-to-date `main`.
- Keep branches short-lived: merge as soon as the issue is done, then delete the branch.
- Rebase on or merge `main` to stay current; do not branch off other feature branches.

Format: `<type>/<issue-number>-<short-description>` (lowercase, kebab-case). Enforced by the pre-push hook and CI.

| Type        | Use for                                                     | Example                          |
| ----------- | ----------------------------------------------------------- | -------------------------------- |
| `feature/`  | New functionality                                           | `feature/12-user-login`          |
| `bugfix/`   | Fixing a bug                                                | `bugfix/34-null-session-crash`   |
| `hotfix/`   | Urgent fix for a broken `main`                              | `hotfix/56-broken-build`         |
| `refactor/` | Code restructuring without behavior change                  | `refactor/78-split-auth-service` |
| `docs/`     | Documentation only                                          | `docs/90-setup-guide`            |
| `test/`     | Adding or fixing tests only                                 | `test/91-login-coverage`         |
| `chore/`    | Tooling, config, dependencies, CI                           | `chore/92-add-linter`            |
| `spike/`    | Time-boxed throwaway prototype to test feasibility          | `spike/93-websocket-poc`         |
| `research/` | Investigating options; outcome is a written finding or ADR  | `research/94-auth-providers`     |

Spike and research branches answer a question rather than ship a feature. Record the outcome in the issue, and in an ADR when it leads to a decision. Spike code is not merged as-is; production code is rewritten test-first on a `feature/` branch.

## Commits

- One logical change per commit.
- Include only relevant files in each commit.
- Use [Conventional Commits](https://www.conventionalcommits.org/) format (enforced by the pre-push hook and CI):

  ```
  <type>(<scope>): <summary>
  ```

  - `type`: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`, `perf`, `ci`, `build`
  - `scope`: optional; the affected area/module, only when it adds clarity
  - `summary`: imperative mood, lowercase, no trailing period, ideally under 50 characters

  Examples:

  ```
  feat(auth): add login endpoint
  fix(parser): handle empty input
  docs: update setup instructions
  ```

- Keep commit messages minimal — a single subject line. No body is needed; the full context (why, how, verification) belongs in the pull request description.
- No AI attribution — see [No AI Attribution](#no-ai-attribution).

## Pull Requests

- **Before opening a PR, pull the latest `main` into your branch and fix any problems:**

  ```bash
  git fetch origin
  git rebase origin/main   # or: git merge origin/main
  ```

  Resolve any conflicts, rerun the tests and convention checks, and fix every failure before pushing. Never open a PR with conflicts or failing checks. If `main` moves while the PR is open and causes conflicts or CI failures, repeat this and fix them.

  After a rebase, update your already-pushed branch with `git push --force-with-lease` (see [Safety Rules](#safety-rules)).
- One PR per issue/branch; link the issue (e.g. `Closes #12`).
- Title follows the same format as commits: `<type>(<scope>): <summary>`.
- Fill in [the PR template](.github/pull_request_template.md). The description carries the detail the commits omit:
  - **What** changed
  - **Why** it changed
  - **How** it was verified, including tests added and coverage / mutation results
  - **Remaining gaps** or follow-ups, if any
- No AI attribution — see [No AI Attribution](#no-ai-attribution).
- Merge with **rebase** or a **merge commit** — not squash — so one-logical-change commits are preserved.

## Protected Files

Only the **repository owner** may change:

- `AGENTS.md`, `CLAUDE.md`
- `.github/` (templates, workflows, `CODEOWNERS`)
- `.claude/settings.json`
- `.githooks/`, `scripts/check-conventions.sh`

CI fails any PR from someone else that touches them, and `CODEOWNERS` requires the owner's review. Agents: do not edit these unless your co-author is the owner (see [Roles](#roles)). If you think a rule should change, raise it with the owner.

## Coding Standards

- Prefer readability over cleverness.
- Follow existing project style and structure.
- Avoid introducing new dependencies unless clearly justified.
- Add comments only when logic is non-obvious.
- Prefer focused changes over broad rewrites.
- Never hardcode secrets; use environment variables and keep an example template (e.g. `.env.example`) up to date.

## Safety Rules

- Never run destructive commands such as `rm -rf` or `git reset --hard` without explicit approval.
- Force pushes:
  - **Allowed:** `git push --force-with-lease` to **your own** issue branch, e.g. after rebasing on `main`.
  - **Never:** plain `--force`, force-pushing `main`, or force-pushing a branch someone else is working on.
- Do not overwrite unrelated user-authored changes.
- If unexpected repo changes appear and they affect the current task, pause and confirm direction.
- Do not silently change migrations, auth behavior, or public contracts outside the requested scope.

## Documentation

- Project documentation lives in `docs/`.
- Update `README.md` when setup, run commands, environment variables, or behavior changes.
- Keep docs concise, operational, and command-focused.
- Prefer documenting actual current behavior over aspirational architecture.

## Architecture Decision Records (ADR)

ADRs live in `docs/adr/` and record why the project is built the way it is.

- Add an ADR when a change:
  - introduces new functionality or a new module/component
  - adds or replaces a dependency, framework, or external service
  - changes architecture, data model, public contracts, or infrastructure/CI/CD
  - makes a non-obvious trade-off future contributors should know about
- Skip ADRs for bug fixes, small refactors, and docs-only changes.
- Copy [docs/adr/template.md](docs/adr/template.md) to `docs/adr/NNNN-short-title.md`, using the next free 4-digit number.
- Commit the ADR in the same PR as the change it describes and add it to the index in [docs/adr/README.md](docs/adr/README.md).
- ADRs are immutable once accepted. To change a decision, write a new ADR and mark the old one `Superseded by ADR-NNNN`.

## Definition of Done

A change is complete when:

- The issue was assigned to you (or your co-author), the work stayed within your role, and the plan was approved.
- Requested behavior is implemented on its own issue branch.
- For production code ([exemptions](#test-driven-development)): written test-first; unit tests cover all new logic, e2e tests cover user-facing flows, bug fixes include a regression test; coverage on new and changed code is 100% and mutation testing meets the threshold (or gaps are justified).
- Documentation is updated when needed.
- An ADR is added when the change introduces new functionality or an architectural decision.
- The branch is up to date with `main`, with no conflicts.
- Commits follow the commit conventions, the pre-push hook and CI pass.
- A PR is open, linked to the issue, with the template filled in, and the card is in **In Review**.
- The diff is focused and reviewable.

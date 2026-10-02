#!/usr/bin/env bash
# Finishes a task: pushes the current issue branch, opens its PR, and moves its card to In Review.
# Usage: scripts/review.sh [--dry-run]
set -euo pipefail

PROJECT_OWNER=Tiramis1234
PROJECT_NUMBER=2
PROJECT_ID=PVT_kwHOB15U784BlbR9
STATUS_FIELD_ID=PVTSSF_lAHOB15U784BlbR9zhkINfQ
IN_REVIEW_OPTION_ID=7a829419

die() { echo "error: $*" >&2; exit 1; }

dry_run=0
case ${1:-} in
  '') ;;
  --dry-run) dry_run=1 ;;
  *) die "unknown argument: $1 (usage: scripts/review.sh [--dry-run])" ;;
esac

root=$(git rev-parse --show-toplevel)
conventions="$root/scripts/check-conventions.sh"

branch=$(git branch --show-current)
[[ -n "$branch" ]] || die "not on a branch"
bash "$conventions" --branch "$branch" || die "run this from an issue branch"
[[ "$branch" =~ ^[a-z]+/([0-9]+)- ]]
issue=${BASH_REMATCH[1]}

git fetch -q origin main
if [[ $(git rev-list --count origin/main..HEAD) -eq 0 ]]; then
  die "branch '$branch' has no commits ahead of origin/main"
fi

repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
title=$(gh issue view "$issue" --json title --jq .title)
issue_url=$(gh issue view "$issue" --json url --jq .url)
if ! bash "$conventions" --title "$title"; then
  die "retitle issue #$issue to <type>(<scope>): <summary>; the PR reuses it"
fi

body=$(sed -e 's/\r$//' -e "s/^Closes #\$/Closes #$issue/" "$root/.github/pull_request_template.md")
bash "$conventions" --branch "$branch" --body "$body" || die "PR description would fail the conventions check"

existing=$(gh pr list --head "$branch" --state open --json url --jq '.[0].url // empty')

if [[ $dry_run -eq 1 ]]; then
  echo "title: $title"
  echo "---"
  echo "$body"
  echo "---"
  echo "would push '$branch' to origin"
  if [[ -n "$existing" ]]; then
    echo "would reuse existing PR $existing"
  else
    echo "would open a PR into main"
  fi
  echo "would move issue #$issue to In Review"
  exit 0
fi

git push -u origin HEAD

if [[ -n "$existing" ]]; then
  echo "PR already open: $existing"
else
  printf '%s\n' "$body" | gh pr create --base main --head "$branch" --title "$title" --body-file -
fi

item=$(gh project item-list "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --limit 1000 --format json \
  --jq ".items[] | select(.content.repository == \"$repo\" and .content.number == $issue) | .id")
if [[ -z "$item" ]]; then
  item=$(gh project item-add "$PROJECT_NUMBER" --owner "$PROJECT_OWNER" --url "$issue_url" --format json --jq .id)
fi
gh project item-edit --project-id "$PROJECT_ID" --id "$item" \
  --field-id "$STATUS_FIELD_ID" --single-select-option-id "$IN_REVIEW_OPTION_ID" > /dev/null
echo "Moved issue #$issue to In Review. Fill in What / Why / How in the PR description."

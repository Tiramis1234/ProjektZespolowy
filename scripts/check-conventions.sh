#!/usr/bin/env bash
# Checks repository conventions. Shared by the pre-push hook and CI.
# Usage: check-conventions.sh [--branch NAME] [--range BASE..HEAD] [--title TEXT] [--body TEXT]
set -euo pipefail

BRANCH_RE='^(feature|bugfix|hotfix|refactor|docs|test|chore|spike|research)/[0-9]+-[a-z0-9]+(-[a-z0-9]+)*$'
SUBJECT_RE='^(feat|fix|refactor|docs|test|chore|style|perf|ci|build)(\([a-z0-9._/-]+\))?!?: [^A-Z ].*[^.]$'
AI_RE='co-authored-by:.*(claude|anthropic|gemini|codex|openai|chatgpt|copilot)|generated (with|by) .*(claude|gemini|codex|chatgpt|copilot)'

status=0

report() {
  local level=$1; shift
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    echo "::$level::$*"
  else
    echo "$level: $*" >&2
  fi
}

fail() { report error "$@"; status=1; }

while [[ $# -gt 0 ]]; do
  case $1 in
    --branch)
      if [[ ! "$2" =~ $BRANCH_RE ]]; then
        fail "branch '$2' must match <type>/<issue-number>-<short-description>"
      fi
      shift 2 ;;
    --title)
      if [[ ! "$2" =~ $SUBJECT_RE ]]; then
        fail "PR title '$2' must match <type>(<scope>): <summary>"
      fi
      if grep -qiE "$AI_RE" <<< "$2"; then
        fail "PR title contains AI attribution"
      fi
      shift 2 ;;
    --body)
      if grep -qiE "$AI_RE" <<< "$2"; then
        fail "PR description contains AI attribution (Co-Authored-By / Generated with ...); remove it"
      fi
      shift 2 ;;
    --range)
      for sha in $(git rev-list --no-merges "$2"); do
        short=${sha:0:7}
        subject=$(git log -1 --format=%s "$sha")
        if [[ ! "$subject" =~ $SUBJECT_RE ]]; then
          fail "commit $short '$subject' must match <type>(<scope>): <summary>"
        fi
        if git log -1 --format=%B "$sha" | grep -qiE "$AI_RE"; then
          fail "commit $short contains AI attribution; remove it"
        fi
        if [[ -n "$(git log -1 --format=%b "$sha" | tr -d '[:space:]')" ]]; then
          report warning "commit $short has a body; keep commits to one line and put details in the PR"
        fi
      done
      shift 2 ;;
    *)
      echo "unknown argument: $1" >&2
      exit 2 ;;
  esac
done

exit $status

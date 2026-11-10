#!/usr/bin/env bash
# Deterministic part of the owner's decisions base: pull from the remote, save, list topics,
# and check that every case is filed under a topic. The agent does the reading and the writing.
set -euo pipefail

usage() {
  echo "usage: decisions.sh <pull|save|index|check> [--dir <base>] [--message <text>]" >&2
  exit 2
}

[ $# -ge 1 ] || usage
cmd=$1
shift
# ~/.agents/decisions is the documented location of the base, next to the skills.
dir="$HOME/.agents/decisions"
message=""
while [ $# -gt 0 ]; do
  case $1 in
    --dir) dir=${2:?--dir needs a path}; shift 2 ;;
    --message) message=${2:?--message needs a text}; shift 2 ;;
    *) usage ;;
  esac
done

if [ ! -d "$dir/.git" ]; then
  echo "DECISIONS_BASE_MISSING: $dir is not a git clone of the decisions base" >&2
  exit 3
fi
cd "$dir"
export GIT_TERMINAL_PROMPT=0

commit_local() {
  git add -A
  git diff --cached --quiet && return 0
  git commit -q -m "$1"
}

# The base is written on one branch only; anything else would silently fork it.
current_branch() {
  local branch default
  if ! branch=$(git symbolic-ref -q --short HEAD); then
    echo "DECISIONS_BRANCH_INVALID: $dir is not on a branch" >&2
    exit 5
  fi
  default=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##') || true
  if [ -n "$default" ] && [ "$default" != "$branch" ]; then
    echo "DECISIONS_BRANCH_INVALID: $dir is on '$branch', the base lives on '$default'" >&2
    exit 5
  fi
  echo "$branch"
}

# Cases are one file per decision with unique names, so they never conflict. Topic files are
# derived from cases: on a conflict the remote copy of the topic wins and is reported, so the
# agent rereads it and applies its change again.
merge_remote() {
  local branch=$1 err file other
  if ! err=$(git fetch -q origin 2>&1); then
    echo "DECISIONS_REMOTE_UNAVAILABLE: working on the local copy ($(echo "$err" | head -1))"
    return 1
  fi
  git rev-parse -q --verify "origin/$branch" >/dev/null || return 0
  git rev-parse -q --verify HEAD >/dev/null || { git reset -q --hard "origin/$branch"; return 0; }
  git merge -q --no-edit "origin/$branch" >/dev/null 2>&1 && return 0
  other=$(git diff --name-only --diff-filter=U | grep -v '^topics/' || true)
  if [ -n "$other" ]; then
    git merge --abort 2>/dev/null || true
    echo "DECISIONS_MERGE_FAILED: local and remote copies of $dir differ outside topics/; resolve by hand" >&2
    exit 4
  fi
  while read -r file; do
    [ -n "$file" ] || continue
    git checkout -q --theirs -- "$file"
    git add -- "$file"
    echo "TOPIC_OVERWRITTEN $file"
  done < <(git diff --name-only --diff-filter=U)
  git commit -q --no-edit
}

push_remote() {
  local err
  if ! err=$(git push -q origin "$1" 2>&1); then
    echo "DECISIONS_PUSH_PENDING: saved locally, not sent ($(echo "$err" | head -1))"
  fi
}

check() {
  local found=0 name
  for f in cases/*.md; do
    [ -e "$f" ] || continue
    name=$(basename "$f" .md)
    if ! grep -rqF "[[$name]]" topics/ 2>/dev/null; then
      echo "UNFILED $name"
      found=1
    fi
  done
  while read -r name; do
    [ -n "$name" ] || continue
    if [ ! -e "cases/$name.md" ]; then
      echo "DANGLING $name"
      found=1
    fi
  done < <(grep -rhoE '\[\[[^]]+\]\]' topics/ 2>/dev/null | tr -d '[]' | sort -u)
  [ $found -eq 0 ] && echo "CHECK_OK"
  return 0
}

case $cmd in
  pull)
    # Read-only for the caller: never commits what another session left unsaved.
    branch=$(current_branch)
    if [ -n "$(git status --porcelain)" ]; then
      echo "DECISIONS_PULL_SKIPPED: unsaved local changes, reading the local copy"
    else
      merge_remote "$branch" || true
    fi
    ;;
  save)
    [ -n "$message" ] || usage
    branch=$(current_branch)
    commit_local "$message"
    if merge_remote "$branch"; then push_remote "$branch"; fi
    check
    ;;
  index)
    for f in topics/*.md; do
      [ -e "$f" ] || continue
      desc=$(sed -n 's/^description: *//p' "$f" | head -1)
      echo "$(basename "$f" .md) — $desc"
    done
    ;;
  check) check ;;
  *) usage ;;
esac

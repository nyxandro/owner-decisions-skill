#!/usr/bin/env bash
# Deterministic part of the owner's decisions base: sync with the remote, save, list topics,
# and check that every case is filed under a topic. The agent does the reading and the writing.
set -euo pipefail

usage() {
  echo "usage: decisions.sh <sync|save|index|check> [--dir <base>] [--message <text>]" >&2
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

commit_local() {
  git add -A
  git diff --cached --quiet && return 0
  git commit -q -m "$1"
}

# Cases are one file per decision with unique names, so they never conflict. Topic files are
# derived from cases: on a conflict the remote side wins, and `check` then lists the local cases
# that lost their place so the agent files them again.
pull_remote() {
  if ! git fetch -q origin 2>/dev/null; then
    echo "DECISIONS_OFFLINE: remote unreachable, working on the local copy"
    return 1
  fi
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  git rev-parse -q --verify "origin/$branch" >/dev/null || return 0
  if ! git merge -q --no-edit -X theirs "origin/$branch" 2>/dev/null; then
    git merge --abort 2>/dev/null || true
    echo "DECISIONS_MERGE_FAILED: local and remote copies of $dir could not be merged; resolve by hand" >&2
    exit 4
  fi
}

push_remote() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD)
  if ! git push -q origin "$branch" 2>/dev/null; then
    echo "DECISIONS_PUSH_PENDING: saved locally, will be sent on the next sync"
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
  sync)
    commit_local "unsaved changes left by an earlier session"
    if pull_remote; then push_remote; fi
    check
    ;;
  save)
    [ -n "$message" ] || usage
    commit_local "$message"
    if pull_remote; then push_remote; fi
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

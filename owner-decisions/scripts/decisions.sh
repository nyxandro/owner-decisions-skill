#!/usr/bin/env bash
# Deterministic part of the owner's decisions base: create it on first use, connect it to a
# private repository, pull, save, list topics and check that every case is filed under a topic.
# The agent does the reading and the writing.
#
# Lines starting with NOTICE are for the owner: the agent passes each on in one line.
set -euo pipefail

usage() {
  echo "usage: decisions.sh <ensure|connect|pull|save|index|check> [--dir <base>] [--url <git address>] [--repo <name>] [--message <text>]" >&2
  exit 2
}

[ $# -ge 1 ] || usage
cmd=$1
shift
# ~/.agents/decisions is the documented location of the base, next to the skills.
dir="$HOME/.agents/decisions"
# Name of the private GitHub repository the base is kept in when GitHub is used.
repo="decisions"
url=""
message=""
while [ $# -gt 0 ]; do
  case $1 in
    --dir) dir=${2:?--dir needs a path}; shift 2 ;;
    --url) url=${2:?--url needs a git address}; shift 2 ;;
    --repo) repo=${2:?--repo needs a name}; shift 2 ;;
    --message) message=${2:?--message needs a text}; shift 2 ;;
    *) usage ;;
  esac
done

# A folder is a decisions base only with this file: a repository that is merely called
# "decisions" is never cloned, merged or written to.
MARKER=".decisions-base"
export GIT_TERMINAL_PROMPT=0

if ! command -v git >/dev/null 2>&1; then
  echo "DECISIONS_GIT_MISSING: git is not installed" >&2
  exit 6
fi

is_base() { [ -d "$dir/.git" ] && [ -f "$dir/$MARKER" ]; }

enter_base() {
  if ! is_base; then
    echo "DECISIONS_BASE_MISSING: $dir is not a decisions base" >&2
    exit 3
  fi
  cd "$dir"
  # Commits in the base need an author; a machine without git identity still gets a base.
  git config user.name >/dev/null || export GIT_AUTHOR_NAME="owner-decisions" GIT_COMMITTER_NAME="owner-decisions"
  git config user.email >/dev/null || export GIT_AUTHOR_EMAIL="owner-decisions@localhost" GIT_COMMITTER_EMAIL="owner-decisions@localhost"
}

has_remote() { git remote get-url origin >/dev/null 2>&1; }

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

# A refused login is a broken setup the owner must hear about; a missing network is not.
report_remote_failure() {
  local what=$1 err=$2
  if echo "$err" | grep -qiE 'authentication|permission denied|could not read username|access denied|403|repository not found'; then
    echo "NOTICE decisions base is not syncing: access to its repository was refused ($(echo "$err" | head -1))"
  else
    echo "$what ($(echo "$err" | head -1))"
  fi
}

# Cases are one file per decision with unique names, so they never conflict. Everything else is
# derived or descriptive: on a conflict the remote copy wins, and an overwritten topic is
# reported so the agent rereads it and applies its change again.
merge_remote() {
  local branch=$1 err file
  has_remote || return 1
  if ! err=$(git fetch -q origin 2>&1); then
    report_remote_failure "DECISIONS_REMOTE_UNAVAILABLE: working on the local copy" "$err"
    return 1
  fi
  git rev-parse -q --verify "origin/$branch" >/dev/null || return 0
  git rev-parse -q --verify HEAD >/dev/null || { git reset -q --hard "origin/$branch"; return 0; }
  git merge -q --no-edit --allow-unrelated-histories "origin/$branch" >/dev/null 2>&1 && return 0
  if git diff --name-only --diff-filter=U | grep -q '^cases/'; then
    git merge --abort 2>/dev/null || true
    echo "DECISIONS_MERGE_FAILED: the same case file differs locally and remotely in $dir; resolve by hand" >&2
    exit 4
  fi
  while read -r file; do
    [ -n "$file" ] || continue
    git checkout -q --theirs -- "$file"
    git add -- "$file"
    case $file in topics/*) echo "TOPIC_OVERWRITTEN $file" ;; esac
  done < <(git diff --name-only --diff-filter=U)
  git commit -q --no-edit
}

push_remote() {
  local err
  if ! err=$(git push -q -u origin "$1" 2>&1); then
    report_remote_failure "DECISIONS_PUSH_PENDING: saved locally, not sent" "$err"
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

gh_reason=""
gh_ready() {
  if ! command -v gh >/dev/null 2>&1; then
    gh_reason="the GitHub CLI (gh) is not installed"
    return 1
  fi
  if ! gh auth status >/dev/null 2>&1; then
    gh_reason="not logged in to GitHub (gh auth login)"
    return 1
  fi
}

LOCAL_HINT="To sync it between machines, give the agent the address of a private git repository."

# Sets gh_full to the account's repository for the base, "owner/name", or fails with gh_reason
# set. Not called in a subshell: both variables must reach the caller.
gh_full=""
github_repo() {
  local login
  gh_ready || return 1
  if ! login=$(gh api user --jq .login 2>/dev/null) || [ -z "$login" ]; then
    gh_reason="could not read the GitHub account"
    return 1
  fi
  gh_full="$login/$repo"
}

github_remote_url() {
  if [ "$(gh config get git_protocol 2>/dev/null)" = "ssh" ]; then
    echo "git@github.com:$1.git"
  else
    echo "https://github.com/$1.git"
  fi
}

github_is_private_base() {
  local full=$1
  gh api "repos/$full/contents/$MARKER" >/dev/null 2>&1 || { gh_reason="repository $full exists and is not a decisions base"; return 1; }
  [ "$(gh repo view "$full" --json visibility --jq .visibility 2>/dev/null)" = "PRIVATE" ] || { gh_reason="repository $full is not private"; return 1; }
}

init_local() {
  mkdir -p "$dir/cases" "$dir/topics"
  git -C "$dir" init -q
  git -C "$dir" symbolic-ref HEAD refs/heads/main
  echo 1 > "$dir/$MARKER"
  touch "$dir/cases/.gitkeep" "$dir/topics/.gitkeep"
  cat > "$dir/README.md" <<'EOF'
# Decisions base

The owner's decisions across all projects, kept so that agents settle a new question the way a
similar one was settled before and ask only what is new.

- `cases/` — one file per decision: the question, the options, the choice, the reason.
- `topics/` — principles drawn from the cases, with boundaries.

Read and maintained by the `owner-decisions` agent skill. Keep the repository private.
EOF
  enter_base
  commit_local "Decisions base created"
}

# Connects an existing local base to GitHub: an existing private base of this account is merged
# in, otherwise a private repository is created. Always ends with a NOTICE.
attach_github() {
  local full branch
  if ! github_repo; then
    echo "NOTICE decisions base is at $dir, local only: $gh_reason. $LOCAL_HINT"
    return 0
  fi
  full=$gh_full
  branch=$(current_branch)
  if gh repo view "$full" >/dev/null 2>&1; then
    if ! github_is_private_base "$full"; then
      echo "NOTICE decisions base is at $dir, local only: $gh_reason. $LOCAL_HINT"
      return 0
    fi
    git remote add origin "$(github_remote_url "$full")"
    if merge_remote "$branch"; then push_remote "$branch"; fi
    echo "NOTICE decisions base at $dir is synced with the existing private GitHub repository $full"
    return 0
  fi
  if gh repo create "$full" --private --source . --remote origin --push >/dev/null 2>&1; then
    echo "NOTICE decisions base created at $dir and synced with a new private GitHub repository $full"
  else
    git remote remove origin 2>/dev/null || true
    echo "NOTICE decisions base is at $dir, local only: could not create the GitHub repository $full. $LOCAL_HINT"
  fi
}

ensure() {
  local full
  is_base && return 0
  if [ -e "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
    echo "DECISIONS_BASE_MISSING: $dir exists and is not a decisions base" >&2
    exit 3
  fi
  # A second machine: the account already holds the base, take it instead of starting a new one.
  if github_repo && gh repo view "$gh_full" >/dev/null 2>&1 && github_is_private_base "$gh_full"; then
    full=$gh_full
    mkdir -p "$(dirname "$dir")"
    if gh repo clone "$full" "$dir" -- -q >/dev/null 2>&1; then
      echo "NOTICE decisions base cloned to $dir from the private GitHub repository $full"
      return 0
    fi
    rm -rf "$dir"
  fi
  init_local
  attach_github
}

connect() {
  local branch err
  enter_base
  if has_remote; then
    echo "DECISIONS_ALREADY_CONNECTED $(git remote get-url origin)"
    return 0
  fi
  if [ -z "$url" ]; then
    attach_github
    return 0
  fi
  # A GitHub address can be checked for privacy; other hosts are the owner's responsibility.
  if echo "$url" | grep -q 'github\.com' && gh_ready; then
    if [ "$(gh repo view "$url" --json visibility --jq .visibility 2>/dev/null)" = "PUBLIC" ]; then
      echo "NOTICE decisions base was not connected: $url is a public repository, and the base must stay private"
      exit 8
    fi
  fi
  branch=$(current_branch)
  git remote add origin "$url"
  if ! err=$(git fetch -q origin 2>&1); then
    git remote remove origin
    echo "NOTICE decisions base was not connected: $url is unreachable ($(echo "$err" | head -1))"
    exit 7
  fi
  if git rev-parse -q --verify "origin/$branch" >/dev/null && ! git cat-file -e "origin/$branch:$MARKER" 2>/dev/null; then
    git remote remove origin
    echo "NOTICE decisions base was not connected: $url already holds something that is not a decisions base"
    exit 7
  fi
  if merge_remote "$branch"; then push_remote "$branch"; fi
  echo "NOTICE decisions base at $dir is synced with $url"
  check
}

case $cmd in
  ensure) ensure ;;
  connect) connect ;;
  pull)
    # Read-only for the caller: never commits what another session left unsaved.
    enter_base
    branch=$(current_branch)
    if [ -n "$(git status --porcelain)" ]; then
      echo "DECISIONS_PULL_SKIPPED: unsaved local changes, reading the local copy"
    else
      merge_remote "$branch" || true
    fi
    ;;
  save)
    [ -n "$message" ] || usage
    enter_base
    branch=$(current_branch)
    commit_local "$message"
    if merge_remote "$branch"; then push_remote "$branch"; fi
    check
    ;;
  index)
    enter_base
    for f in topics/*.md; do
      [ -e "$f" ] || continue
      desc=$(sed -n 's/^description: *//p' "$f" | head -1)
      echo "$(basename "$f" .md) — $desc"
    done
    ;;
  check)
    enter_base
    check
    ;;
  *) usage ;;
esac

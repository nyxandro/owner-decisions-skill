#!/usr/bin/env bash
# Tests for decisions.sh with the stops file: `index` and `check` read it, `save` reports a
# conflicting copy. Run from anywhere: bash tests/decisions.test.sh
set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/owner-decisions/scripts/decisions.sh"
fails=0
# Every base of every test lives under one folder, removed on exit.
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT
export GIT_AUTHOR_NAME=test GIT_COMMITTER_NAME=test GIT_AUTHOR_EMAIL=test@localhost GIT_COMMITTER_EMAIL=test@localhost

# A minimal base as `ensure` leaves it: the marker file and a git repository on main.
new_base() {
  local base
  base=$(mktemp -d "$ROOT/base.XXXXXX")
  mkdir -p "$base/cases" "$base/topics"
  echo 1 > "$base/.decisions-base"
  git -C "$base" init -q
  git -C "$base" symbolic-ref HEAD refs/heads/main
  echo "$base"
}

write_case() { # base name
  printf -- '---\ndate: 2026-11-20\nproject: all\nclass: ordinary\nsource: reversal\n---\n\n## Question\nq\n' > "$1/cases/$2.md"
}

write_topic() { # base name description case
  printf -- '---\ndescription: %s\n---\n\n# Topic\n\n## A principle\n\nCases: [[%s]]\n' "$3" "$4" > "$1/topics/$2.md"
}

# Prints what the command printed; a non-zero exit is appended, so output alone means success.
run() { # base command
  local out status
  set +e
  out=$(bash "$SCRIPT" "$2" --dir "$1" 2>/dev/null)
  status=$?
  set -e
  printf '%s' "$out"
  [ $status -eq 0 ] || printf '%sEXIT %s' "${out:+$'\n'}" "$status"
}

expect() { # description expected actual
  if [ "$2" == "$3" ]; then
    echo "ok   $1"
  else
    echo "FAIL $1"
    echo "  expected: $(printf '%q' "$2")"
    echo "  actual:   $(printf '%q' "$3")"
    fails=$((fails + 1))
  fi
}

STOPS='# Stops

## Actions

- Do not install anything the owner did not ask for. "I did not ask you to install it" [[2026-11-20-all-no-unasked-install]]'

# index lists the topics, then shows the stops file whole.
base=$(new_base)
write_case "$base" 2026-11-20-all-settings
write_case "$base" 2026-11-20-all-no-unasked-install
write_topic "$base" settings "whether people get a setting" 2026-11-20-all-settings
printf '%s\n' "$STOPS" > "$base/stops.md"
expect "index shows topics, then the stops" \
  "settings — whether people get a setting

STOPS
$STOPS" "$(run "$base" index)"

# A case named only in the stops file is filed; a stop naming a missing case is dangling.
expect "check counts a case named only in stops.md as filed" "CHECK_OK" "$(run "$base" check)"
printf '%s [[2026-11-20-all-gone]]\n' "$STOPS" > "$base/stops.md"
expect "check reports a stop that names a missing case" "DANGLING 2026-11-20-all-gone" "$(run "$base" check)"

# Without a stops file nothing changes: no STOPS heading, the case is unfiled.
rm "$base/stops.md"
expect "index without stops.md lists only the topics" \
  "settings — whether people get a setting" "$(run "$base" index)"
expect "check without stops.md reports the case as unfiled" \
  "UNFILED 2026-11-20-all-no-unasked-install" "$(run "$base" check)"

# An empty stops file shows nothing, so an empty base still prints nothing at all.
base=$(new_base)
: > "$base/stops.md"
expect "index with an empty stops.md prints nothing" "" "$(run "$base" index)"

# Two machines change the same stop: the remote copy is kept and the agent is told to redo its edit.
remote="$ROOT/remote.git"
git init -q --bare "$remote"
git --git-dir "$remote" symbolic-ref HEAD refs/heads/main
a=$(new_base)
write_case "$a" 2026-11-20-all-no-unasked-install
printf '%s\n' "$STOPS" > "$a/stops.md"
git -C "$a" add -A && git -C "$a" commit -qm init
git -C "$a" remote add origin "$remote" && git -C "$a" push -q -u origin main
b="$ROOT/b"
git clone -q "$remote" "$b"
printf '%s\n' "${STOPS/install anything/install a package}" > "$a/stops.md"
bash "$SCRIPT" save --dir "$a" --message "machine a" >/dev/null
printf '%s\n' "${STOPS/install anything/install a service}" > "$b/stops.md"
out=$(bash "$SCRIPT" save --dir "$b" --message "machine b" 2>&1)
expect "a conflicting stops.md is reported as overwritten" "TOPIC_OVERWRITTEN stops.md" "$(grep -x 'TOPIC_OVERWRITTEN stops.md' <<<"$out" || true)"
expect "the remote stops.md is kept" "${STOPS/install anything/install a package}" "$(cat "$b/stops.md")"

[ $fails -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }

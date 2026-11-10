# Owner Decisions

A skill that keeps the owner's decisions across all projects in one private base and settles a
new decision question the way the owner settled a similar one. Only what is new reaches the
owner; their answers go back into the base.

- `owner-decisions/SKILL.md` — when it runs and what it does before a question and after an answer.
- `owner-decisions/references/consult.md` — instructions for the subagent that checks forks against the base.
- `owner-decisions/references/record.md` — the format of a case and a topic, and how a new case is filed.
- `owner-decisions/scripts/decisions.sh` — sync, save, index and filing check for the base.

The base itself is a separate private repository cloned to `~/.agents/decisions/`. Money and
irreversible actions are never settled from the base.

Design and the owner's decisions: `docs/specs/[10.11.2026]-owner-decisions.md`.

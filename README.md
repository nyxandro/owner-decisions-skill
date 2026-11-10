<div align="center">

# Owner Decisions

**An agent skill that answers a decision question the way you already answered a similar one, in any project, and asks you only what is new.**

[![Release](https://img.shields.io/github/v/release/nyxandro/owner-decisions-skill)](https://github.com/nyxandro/owner-decisions-skill/releases)
[![License](https://img.shields.io/github/license/nyxandro/owner-decisions-skill)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-SKILL.md-6f42c1)](https://agentskills.io/specification)

**English** · [Русский](README.ru.md)

</div>

Owner Decisions is a skill for Claude Code, Codex, OpenCode, Cursor and other agents that read
Agent Skills. It keeps your decisions from all projects in one private base of markdown files.
Before an agent asks you to choose between options, it checks the base, settles what you have
already decided, and sends you the rest. Your answers go back into the base.

## Why

If you run projects through agents, you answer the same kinds of questions again and again. Do
people get a setting or does the system decide. Is this risk worth a mechanism. Does a small
thing need a process. Each answer shows how you decide, and each one is lost when the session
ends.

This skill keeps them. The more you answer, the less you are asked.

## Install

| Agent | Command |
|---|---|
| Claude Code, Codex, OpenCode, Cursor and others | `npx skills add nyxandro/owner-decisions-skill -g` |
| Any agent, by hand | Download the [latest `.skill` archive](https://github.com/nyxandro/owner-decisions-skill/releases/latest/download/owner-decisions.skill) and unpack it into the agent's skills folder |

The skill ships without a base. Yours is a private repository of your own:

1. Create an empty private repository, for example `yourname/decisions`.
2. Clone it to `~/.agents/decisions` on every machine you work on. The skill fills it as you
   answer questions.
3. Add this to your agent's global rules file (`~/.claude/CLAUDE.md`, `AGENTS.md` or the like),
   with your repository's name:

```markdown
## Owner's decisions base

- My earlier decisions across all projects are kept in `~/.agents/decisions/`, a clone of the private repository `yourname/decisions`. If the folder is missing, clone it there.
- Before sending me a decision question — a fork, a choice between options — in any skill or plain session, check the forks against this base using the skill for the owner's decisions base, if one is installed. What the base settles is not asked; money and irreversible actions are always asked.
- Right after I answer such questions or reverse a decision made for me, record the answers in the base with the same skill, in the same turn, before continuing the work.
- If that skill or the base is unavailable, skip both steps without complaint and ask me as usual.
```

The rule is what makes the two moments reliable. It names no skill, so other skills know nothing
about this one, and everything works as before if you remove it.

## How it works

1. An agent has prepared questions for you, in any skill or a plain session.
2. Before sending them, it hands them to a subagent. The subagent pulls the base, reads the
   topics that fit and returns a verdict for each question: settled, with the decision it rests
   on, or ask.
3. A settled question is no longer asked. The agent takes the option and records it where the
   work already records decisions made for you, such as the "agent decisions" section of a
   specification. You get no separate list and no retelling of your own history.
4. You answer the rest. In the same turn the agent writes each answer as a case, files it under
   a topic and pushes the base.

## What is never settled for you

- **Money.** Spending, prices, paid services. A question where even one option costs money goes
  to you, also when you refused to spend last time.
- **The irreversible.** Deleting or rewriting stored data, sending or publishing outward, legal
  commitments.

A principle taken from a small personal project does not carry to a project with paying
customers or a client unless the principle says so. When in doubt, the question is asked.

## The base

```text
cases/    one file per decision: the question, the options, your choice, your reason
topics/   principles drawn from the cases, with boundaries: where you decided otherwise and why
```

- Cases are the record. Each has a unique name, so two machines never write the same file, and
  cases are never deleted.
- Topics are merged, not appended. An answer that exactly repeats a principle is not recorded
  at all; one that adds to it joins it. A case that goes
  against one becomes a boundary if the situations differ, or one short question to you if
  nothing explains the difference.
- There is no database and no service. A subagent reads the list of topics and the ones that
  fit. Plain files can be read, edited and reverted by hand.

`scripts/decisions.sh` does the mechanical part: `pull`, `save`, `index` and `check`. If two
machines change the same line of a topic, the remote copy is kept and the script names the
topic, so the agent applies its change again.

## Versions

The current version sits in `metadata.version` of `owner-decisions/SKILL.md`. Every version has
a git tag and a [release](https://github.com/nyxandro/owner-decisions-skill/releases) with its
own archive. [CHANGELOG.md](CHANGELOG.md) lists what changed.

<details>
<summary>Repository layout</summary>

<br>

```text
owner-decisions/SKILL.md                 the skill
owner-decisions/references/consult.md    instructions for the subagent that checks questions
owner-decisions/references/record.md     the format of a case and a topic, and how a case is filed
owner-decisions/scripts/decisions.sh     pull, save, index and filing check for the base
dist/owner-decisions.skill               the skill folder as a downloadable archive
docs/specs/                              the design and the decisions behind it (in Russian)
```

</details>

## License

[MIT](LICENSE)

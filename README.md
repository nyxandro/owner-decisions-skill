<div align="center">

# Owner Decisions

**An agent skill that answers a decision question the way you already answered a similar one, in any project, and asks you only what is new.**

[![Release](https://img.shields.io/github/v/release/nyxandro/owner-decisions-skill)](https://github.com/nyxandro/owner-decisions-skill/releases)
[![License](https://img.shields.io/github/license/nyxandro/owner-decisions-skill)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-SKILL.md-6f42c1)](https://agentskills.io/specification)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-d97757)](#install)

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
| Claude Code, as a plugin | `/plugin install owner-decisions --marketplace nyxandro/skills` |
| Claude Code, Codex, OpenCode, Cursor and others | `npx skills add nyxandro/owner-decisions-skill -g` |
| Any agent, by hand | Download the [latest `.skill` archive](https://github.com/nyxandro/owner-decisions-skill/releases/latest/download/owner-decisions.skill) and unpack it into the agent's skills folder |

Pick one. If you install it two ways, Claude Code loads the skill twice.

There is nothing else to set up. The first time the skill runs it creates your base in
`~/.agents/decisions` and tells you in one line where it is and whether it syncs:

| Your machine | What happens |
|---|---|
| Logged in to GitHub (`gh auth login`) | A private repository `decisions` is created in your account, or cloned if another machine already made it |
| No GitHub, or not logged in | The base stays on this machine and works fully. The line says why it does not sync |
| GitLab, your own git server, anything else | Tell the agent the address of a private repository once, and it connects the base to it |

The skill attaches itself through its description: no other skill names it, and nothing
changes if you remove it. If your agent tends to forget it in the middle of another skill, add
a line to your global rules file saying that questions to you are checked against the decisions
base first and your answers are recorded in it.

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

`scripts/decisions.sh` does the mechanical part: `ensure`, `connect`, `pull`, `save`, `index`
and `check`. A folder counts as a base only with its marker file, so a repository that is
merely called `decisions` is never touched, and a public GitHub repository is refused. If two
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
owner-decisions/scripts/decisions.sh     creates, connects, pulls, saves and checks the base
dist/owner-decisions.skill               the skill folder as a downloadable archive
docs/specs/                              the design and the decisions behind it (in Russian)
```

</details>

## License

[MIT](LICENSE)

<div align="center">

# Owner Decisions

**A Claude Code skill that remembers how you decide. Your AI agent answers a decision question the way you already answered a similar one, in any project, and asks you only what is new.**

[![Release](https://img.shields.io/github/v/release/nyxandro/owner-decisions-skill)](https://github.com/nyxandro/owner-decisions-skill/releases)
[![License](https://img.shields.io/github/license/nyxandro/owner-decisions-skill)](LICENSE)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-SKILL.md-6f42c1)](https://agentskills.io/specification)
[![Claude Code plugin](https://img.shields.io/badge/Claude%20Code-plugin-d97757)](#install)

**English** · [Русский](README.ru.md)

</div>

Owner Decisions is a skill for Claude Code, Codex, OpenCode, Cursor and other agents that read
Agent Skills. It keeps a decision log of your own choices across all projects in a private base
of markdown files. Before a coding agent asks you to choose between options, it checks the base,
settles what you have already decided, and sends you the rest. Your answers go back into the
base, so the agent's memory of how you decide grows with every project.

## Why

If you run projects through AI agents, you answer the same kinds of questions again and again.

- Do people get a setting, or does the system decide?
- Is this risk worth a mechanism?
- Does a small thing need a process?

Each answer shows how you decide, and each one is lost when the session ends. The next agent,
in the next project, asks again or guesses.

This skill keeps the answers. The more you answer, the less you are asked, and the agent's own
decisions start to follow yours.

## Install

| Agent | Command |
|---|---|
| Claude Code, as a plugin | `/plugin install owner-decisions --marketplace nyxandro/skills` |
| Claude Code, Codex, OpenCode, Cursor and others | `npx skills add nyxandro/owner-decisions-skill -g` |
| Any agent, by hand | Download the [latest `.skill` archive](https://github.com/nyxandro/owner-decisions-skill/releases/latest/download/owner-decisions.skill) and unpack it into the agent's skills folder |

Pick one. If you install it two ways, Claude Code loads the skill twice.

There is nothing else to set up. The first time the skill runs it creates your base in
`~/.agents/decisions` and tells you in one line where it is and whether it syncs.

| Your machine | What happens |
|---|---|
| Logged in to GitHub (`gh auth login`) | A private repository `decisions` is created in your account, or cloned if another machine already made it |
| No GitHub, or not logged in | The base stays on this machine and works fully. The line says why it does not sync |
| GitLab, your own git server, anything else | Tell the agent the address of a private repository once, and it connects the base to it |

<details>
<summary>Requirements and more install options</summary>

<br>

- The script needs `git` and `bash`. `gh` is optional and only creates or finds the private
  repository on GitHub. Without it the base is local, or synced with the address you give.
- The base must stay private. A folder counts as a base only with its marker file, so a
  repository that is merely called `decisions` is never touched, and a public GitHub repository
  is refused.
- The one-line plugin install needs Claude Code 2.1.275 or later. On an older version, add the
  catalog first with `/plugin marketplace add nyxandro/skills` and then run
  `/plugin install owner-decisions@nyxandro`.
- The catalog pins no version, so every commit here reaches plugin users as an update. Run
  `claude plugin marketplace update nyxandro` and `claude plugin update owner-decisions@nyxandro`,
  or turn on auto-update under `/plugin` → Marketplaces.
- With `npx skills`, `-g` installs the skill for every project, which is what a base shared by
  all projects needs. To install a given version, add its tag, as in
  `nyxandro/owner-decisions-skill@v1.0.0`.
- You can also clone this repository and link the `owner-decisions/` folder into your agent's
  skills folder. There is no build step.
- The skill attaches itself through its description: no other skill names it. If your agent
  forgets it in the middle of another workflow, add a line to your global rules file saying
  that questions to you are checked against the decisions base first and your answers are
  recorded in it.

</details>

## Usage

You do nothing new. Work as usual and answer the agent's questions; the skill runs before a
question reaches you and right after you answer.

A few things you can say when you want to:

- *What did I decide about backups before?*
- *Why did I choose differently in these two projects?*
- *No, here I do want the setting.* A reversal is recorded and marks where a principle ends.
- *Sync the decisions base with git@gitlab.com:me/decisions.git.*
- *Tidy the decisions base.*

## How it works

1. An agent has listed the decisions that are yours to make, in any skill or a plain session,
   along with the ones it would take itself but you could disagree with.
2. Before asking and before building on a guess, it hands them to a subagent. The subagent pulls
   the base, reads the topics that fit and returns a verdict for each: settled, with the
   decision it rests on, or ask.
3. A settled question is no longer asked. The agent takes the option and records it where the
   work already records your decisions, with the ground "by your earlier decision". You get no
   separate list and no retelling of your own history.
4. A decision of the agent's own that the base covers is taken your way. One the base is silent
   on stays the agent's: consulting the base does not add questions for you.
5. You answer the rest. In the same turn the agent writes each answer as a case, files it under
   a topic and pushes the base.

## What is never settled for you

- **Money.** Spending, prices, paid services. A question where even one option costs money goes
  to you, also when you refused to spend last time.
- **The irreversible.** Deleting or rewriting stored data, sending or publishing outward,
  releasing to real users, legal commitments.

A principle taken from a small personal project does not carry to a project with paying
customers or a client unless the principle says so. An explanation the agent worked out itself
is marked as its reading and settles nothing until you confirm it. When in doubt, the question
is asked.

## Example

A feature design in a personal Telegram bot produced four questions. Two reached the owner.

```text
Settled from the base, not asked
  A "quiet hours" switch for each person?
    No setting: the bot keeps quiet at night by itself.
    By your decision of 2026-03-14: people get no switches, the system decides.
  An external uptime monitor?
    As now, without it.
    By your decision of 2026-02-02: for a personal project the risk is accepted.

Asked
  A paid error tracker, $20 a month?      money is always yours to decide
  Admin texts in Russian or in English?   nothing close in the base
```

A case is one file with the question, the options, your choice and your reason:

```markdown
---
date: 2026-03-14
project: notes-bot
context: a personal note-taking bot in Telegram, one owner, no paying customers
class: ordinary
source: reversal
recommendation: rejected
---

## Question
Send a weekly digest: the agent offered "automatic, with a switch" and "on request".

## Options
- automatic, with a switch for the person
- only on request

## Decision
No switch at all: the bot decides by itself when a digest is worth sending.

## Reason
"People should not have to manage settings. The bot is supposed to be smart."
```

## The base

```text
cases/    one file per decision: the question, the options, your choice, your reason
topics/   principles drawn from the cases, with boundaries: where you decided otherwise and why
```

- Cases are the record. Each has a unique name, so two machines never write the same file, and
  cases are never deleted.
- Topics are merged, not appended. An answer that exactly repeats a principle is not recorded
  at all; one that adds to it joins it. A case that goes against a principle becomes a boundary
  if the situations differ, or one short question to you if nothing explains the difference.
- There is no database, no vector search and no service. A subagent reads the list of topics
  and the ones that fit, so the cost of a check does not grow with the number of cases. Plain
  files can be read, edited and reverted by hand.
- Headings inside the base are written in your language.

`scripts/decisions.sh` does the mechanical part: `ensure`, `connect`, `pull`, `save`, `index`
and `check`. If two machines change the same line of a topic, the remote copy is kept and the
script names the topic, so the agent applies its change again.

## Works well with

[Feature Blueprint](https://github.com/nyxandro/feature-blueprint-skill) designs a feature
before any code and sorts every decision into the agent's own and yours. That sorting is what
this skill needs to be useful: the decisions that are yours arrive as a clear list, each with
its situation and options, at the one moment before the design is built on a guess. And the
answers you give at its checkpoint are the richest source for the base, because each comes with
the options you turned down and your reason.

Neither skill needs the other. Owner Decisions works the same way in any workflow or plain
session where an agent is about to ask you to decide something.

## Versions

The current version sits in `metadata.version` of `owner-decisions/SKILL.md`, so any installed
copy tells you which one it is. Every version has a git tag and a
[release](https://github.com/nyxandro/owner-decisions-skill/releases) with its own archive.
[CHANGELOG.md](CHANGELOG.md) lists what changed.

<details>
<summary>Repository layout</summary>

<br>

```text
owner-decisions/              the skill
  SKILL.md                    when it runs, what it does before a question and after an answer
  references/consult.md       instructions for the subagent that checks decisions against the base
  references/record.md        the format of a case and a topic, and how a new decision is filed
  scripts/decisions.sh        creates, connects, pulls, saves and checks the base
dist/owner-decisions.skill    the skill folder as a downloadable archive
CHANGELOG.md                  what changed in each version
README.md, README.ru.md       this page in English and in Russian
```

</details>

## License

[MIT](LICENSE)

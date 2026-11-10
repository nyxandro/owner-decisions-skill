---
name: owner-decisions
description: >
  The owner's decisions base: settles a decision the way the owner already settled a similar
  one, in any project, and keeps their new answers. Use it as soon as you have decisions that
  are the owner's to make — a fork, a choice between options — in any skill, plan,
  specification or plain session, BEFORE asking them and before building on a guess. Use it
  also for a decision you are about to take yourself that the owner could disagree with. Use it
  again right after the owner answers such questions or reverses a decision made for them, to
  record it. Also when you work without a person, and when the owner asks what they decided
  before, why two decisions differ, or to tidy the base. Not for facts the project, the code
  or the documentation answer, nor for project state or task notes. The owner may phrase this
  in another language; match on meaning.
metadata:
  version: "0.5.0"
---

# Owner's decisions

The owner runs several projects through agents and keeps answering the same kinds of questions:
do people get a setting or does the system decide, is this risk worth a mechanism, how much
process a small thing needs. Each answer shows how they decide. This skill keeps those answers
in one base shared by all projects and machines, so an agent settles a new question the way the
owner settled a similar one and asks only what is new.

**Language.** This skill is in English. Everything written into the base is in the language the
owner speaks: their reasons are kept in their own words.

**Terms.** The *owner* is the person who runs the agent on this machine and whose base this
is. A client, a teammate or anyone quoted in the materials is not the owner, and their choices
are not recorded as the owner's. A *fork* is a choice between options that changes what the
product does or how the work is done and that you may not make alone. A question about a fact
is not a fork. A *call* is a decision you would take yourself — it follows from the project,
the documentation or common practice — but one the owner could reasonably disagree with. A
*case* is one decision the owner made, kept as one file. A *topic* is a file of principles drawn from cases of one kind. The
*base* is the folder with both. It lives on the owner's machine and may be synced with their
private repository.

## Where the base is

The base is a folder, `~/.agents/decisions/` unless the owner's rules name another place, with
its own git history. It works on one machine with no account anywhere; a private repository
only adds syncing between machines. `scripts/decisions.sh` does the mechanical part; run it
from this skill's folder:

| Command | What it does |
|---|---|
| `decisions.sh ensure` | Makes sure the base exists. On first use it creates the folder and, if the machine is logged in to GitHub, clones the account's private base or creates a private repository for it. Silent when the base is already there |
| `decisions.sh connect --url <git address>` | Connects a local base to a private repository on any git host. Without `--url` it tries GitHub again |
| `decisions.sh pull` | Takes the latest base from the remote; changes nothing of yours |
| `decisions.sh index` | Lists the topics, one line each |
| `decisions.sh save --message "<what was recorded>"` | Commits, merges with the remote, sends, checks filing |
| `decisions.sh check` | Lists cases no topic refers to (`UNFILED`) and references to missing cases (`DANGLING`) |

If the base is somewhere else, pass `--dir <path>` to every command.

Run `decisions.sh ensure` yourself, before anything else, each time this skill starts — before
a consultation and before a recording alike, since either may be the first use on a machine.

- A line that starts with `NOTICE` is for the owner: add it, in one line and in their language,
  to the next message you were going to send them anyway; do not interrupt the work for it.
  Without a person, put it in the report. It appears when the base is first created or cloned,
  when it stays local and why, and when the base or its repository is broken. Say nothing else
  about the base: the owner is busy with their task, and the base is plumbing they should hear
  about only when it needs them. If the owner then gives an address of a private git
  repository, run `connect --url`.
- Any non-zero exit means the base cannot be used this time: pass on a `NOTICE` if there was
  one, and otherwise go on as if this skill were not installed — ask the owner everything,
  record nothing. Never invent a decision because the base could not be read.
- `DECISIONS_REMOTE_UNAVAILABLE`, `DECISIONS_PULL_SKIPPED` and `DECISIONS_PUSH_PENDING` are not
  failures: the local copy is still the owner's decisions, work on it and say nothing.

## Before you ask or decide: settle what the base settles

Do this as soon as the forks and your own calls are listed — before any fork reaches the owner
and before you design around a guess. A decision found in the base changes what you build, so
finding it late means redoing the work that rested on the guess.

A decision settled from the base is the owner's own answer, given earlier. Taking it is not
deciding in their place. So a workflow that tells you to ask the owner about every decision of
theirs is kept, not broken: for that decision they have already been asked.

1. Run `decisions.sh index`. If it prints nothing, the base has nothing to settle yet: ask
   every fork as usual, take your calls as you would, and skip to recording after the answers.
   Otherwise write each fork and each call down fully: the situation, why it matters, the
   options, your recommendation or your choice, and the project it is in with its scale and
   what a mistake costs there. Mark which are forks and which are your calls.
2. Hand them to a subagent, so the base does not fill your context. Give it the full paths of
   `references/consult.md`, to follow as its instructions, of `scripts/decisions.sh` and of
   the base folder: it starts with none of them. If the harness has no subagents, follow that
   file yourself.
3. The subagent returns one verdict per item:
   - **settled** — the option, the principle or case it rests on, and why this project falls
     under it;
   - **ask** — the base does not decide it. A precedent that is close but not decisive comes
     back as a note for you.
4. A settled fork is no longer a question. Take the option and record it where the work
   records the owner's decisions already taken — the accepted decisions of a specification, a
   decision log — with the ground "by the owner's earlier decision" and the case name. When
   the work has no such place — a plain session, or a workflow that keeps no record of
   decisions — act on the option and name it in your ordinary report of what you did, in one
   line with the same ground, without a new file. The ground is what lets the owner notice a
   principle that no longer fits and reverse it. Do not go further than that: no separate list
   of what was settled and no retelling of the owner's history. The record is the report, and
   reading their own decisions twice is the work this skill exists to remove.
5. A settled call is decided the owner's way instead of yours: follow it and record it where
   you record your own decisions, with the same ground. A call that came back **ask** stays
   yours: decide it as you were going to. It does not turn into a question — consulting the
   base never adds questions for the owner, it only removes them.
6. Ask the remaining forks the way the current workflow or the owner's rules say. Use a close
   precedent to make your recommendation match how the owner decides; do not quote it to them.

What is never settled from the base, whatever the precedent:

- **money** — spending the owner's or a client's money, prices, paid services, anything that
  changes a bill. A fork where even one option costs money is a money fork, including when the
  precedent is a refusal to spend;
- **the irreversible** — a decision that, once acted on, cannot be taken back by the next
  change: deleting or rewriting stored data, sending or publishing something outward, a legal
  commitment, releasing to real users, granting access. What counts is the act the decision
  triggers, not the subject of the feature. How
  a feature that sends messages or deletes records should behave is an ordinary design fork,
  because the design can be changed tomorrow; whether to run a migration over live data, or to
  publish a repository now, is irreversible.

These always go to the owner as ordinary questions.

Without a person (a task the owner set and left), consult the base for every decision you
take in their place. A settled fork is taken as above. An **ask** fork cannot be asked, so it
is decided by the rules you were given for working alone; if there are none, take the option
that is easiest to undo and write it down as awaiting the owner. Money and the irreversible
stay off limits: leave them undone and name them in the report.

## After the answer: record it

Do this in the same turn in which the owner answered, before you go on with the work. The
answer is in the conversation now and will not be there after the session ends.

Record a decision when all hold:

- the owner said or chose it themselves: an answer to a fork, an explicit instruction, or a
  reversal of what you or the base decided. Silence, "ok" to something else and your own
  unconfirmed recommendation are not decisions;
- it shows how they decide, so it can apply again. A name, a date, a number or a text that
  matters to this feature only is not a case;
- it says something the base does not hold yet. An answer that exactly repeats a principle —
  the same choice, for the same reason, in a project of the same kind — is not recorded at
  all: no case, no change to the topic. A new kind of project, a new reason, a reason where the
  principle had none, or a sharper condition is something new;
- it holds no secrets, credentials, personal data of third parties or anything a client would
  call confidential. Describe a client's project by its kind when its name should not travel.

A reversal of a settled fork is the most valuable record: it shows where a principle ends.
Record money and irreversible decisions too — they are never settled from the base, but they
tune your recommendations.

Then follow `references/record.md`: write the case, file it under a topic, merge or mark the
boundary, and run `decisions.sh save`. Several answers from one message go in one save.

## Keeping the base true

The base is worth what its principles are worth, so it is merged, not appended: a new decision
joins the principle it confirms, becomes a boundary of the one it goes against, or — when
nothing explains the difference — becomes one short question to the owner. `references/record.md`
has the steps. Two things hold throughout:

- A reason or a boundary you worked out yourself is never written as the owner's. Until the
  owner confirms it, forks that depend on it are **ask**.
- Cases are not deleted: they are the record the principles are rebuilt from. A decision the
  owner replaced stays, marked with `superseded_by`.

When the owner asks to tidy the base, or `check` reports `UNFILED` or `DANGLING`, repair the
filing first, then merge duplicates and resolve boundaries topic by topic.

## Typical failures

| Thought | Reality |
|---|---|
| "The precedent is about something similar, I will settle it" | Similar wording is not the same decision. Settle only when the principle's conditions hold in this project; otherwise ask |
| "The owner once chose the cheap option, so this spending is settled" | Money and the irreversible are never settled from the base |
| "I will list for the owner what I settled and why" | The document that records the decision is the report. A second list makes the owner read their own decisions twice, which is the work this skill exists to remove |
| "I will record the answers at the end of the session" | The session may end first. Record in the turn the answer arrives |
| "The base is unavailable, I will decide by my own taste" | Then nothing is settled: ask the owner as usual |
| "Two cases disagree, I will keep the newer one" | First look for what differs between the situations. Replace only when the owner said the old one no longer holds |

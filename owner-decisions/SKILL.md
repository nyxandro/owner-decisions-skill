---
name: owner-decisions
description: >
  The owner's decisions base: answers a decision question the way the owner already answered a
  similar one, in any project, and keeps their new answers. Use it every time you are about to
  ask the owner to decide something — a fork, a choice between options, a "which way do you
  want it" — in any skill, plan, specification or plain session, BEFORE the question is sent:
  part of the questions get settled from the owner's earlier decisions and only the rest reach
  them. Use it again right after the owner answered such questions or reversed a decision you
  made for them, to record the answer. Also use it when you work without a person and must
  decide in the owner's place, and when the owner asks what they decided before, why two
  similar decisions differ, or to tidy the base. Not for facts the project, the code or the
  documentation answer, and not for storing project state or task notes. The owner may phrase
  this in another language; match on meaning.
metadata:
  version: "0.1.0"
---

# Owner's decisions

The owner runs several projects through agents and keeps answering the same kinds of questions:
do people get a setting or does the system decide, is this risk worth a mechanism, how much
process a small thing needs. Each answer shows how they decide. This skill keeps those answers
in one base shared by all projects and machines, so an agent settles a new question the way the
owner settled a similar one and asks only what is new.

**Language.** This skill is in English. Everything written into the base is in the language the
owner speaks: their reasons are kept in their own words.

**Terms.** A *fork* is a decision that belongs to the owner. A *case* is one decision the owner
made, kept as one file. A *topic* is a file of principles drawn from cases of one kind. The
*base* is the folder with both, a clone of the owner's private repository.

## Where the base is

The base lives in `~/.agents/decisions/` unless the owner's rules name another place. If the
folder is missing and the owner's rules name its repository, clone it there. If there is no
base and no way to get one, or a script command fails, go on silently as if this skill were not
installed: ask the owner everything, record nothing. Never invent
a decision because the base could not be read.

`scripts/decisions.sh` does the mechanical part; run it from this skill's folder:

| Command | What it does |
|---|---|
| `decisions.sh pull` | Takes the latest base from the remote; changes nothing of yours |
| `decisions.sh index` | Lists the topics, one line each |
| `decisions.sh save --message "<what was recorded>"` | Commits, merges with the remote, sends, checks filing |
| `decisions.sh check` | Lists cases no topic refers to (`UNFILED`) and references to missing cases (`DANGLING`) |

`DECISIONS_REMOTE_UNAVAILABLE`, `DECISIONS_PULL_SKIPPED` and `DECISIONS_PUSH_PENDING` exit with
zero: the local copy is still the owner's decisions, work on it. They print git's reason; if it
is not a missing network (access denied, push rejected), tell the owner in one line. Any
non-zero exit means the base cannot be used this time.

## Before the question: settle what the base settles

Do this when you have the forks ready and before any of them reaches the owner.

1. Write each fork down fully: the situation, why it matters, the options, your recommendation,
   and the project it is in with its scale and what a mistake costs there.
2. Hand the forks to a subagent with `references/consult.md` as its instructions, so the base
   does not fill your context. If the harness has no subagents, follow that file yourself.
3. The subagent returns one verdict per fork:
   - **settled** — the option, the principle or case it rests on, and why this project falls
     under it;
   - **ask** — the fork goes to the owner. A precedent that is close but not decisive comes
     back as a note for you.
4. A settled fork is no longer a question. Take the option and record it where the work
   already records decisions made for the owner — a specification's section of agent decisions
   for review, a decision log of a task without a person — with the ground "by the owner's
   earlier decision" and the case name. Do not show the owner a separate list of what was
   settled and do not retell them their own history: the record in the document is enough.
   When the work has no such document — a plain session — act on the option and name it in
   your ordinary report of what you did, as one more decision of yours, without a new file.
5. Ask the remaining forks the way the current skill or the owner's rules say. Use a close
   precedent to make your recommendation match how the owner decides; do not quote it to them.

What is never settled from the base, whatever the precedent:

- **money** — spending the owner's or a client's money, prices, paid services, anything that
  changes a bill. A fork where even one option costs money is a money fork, including when the
  precedent is a refusal to spend;
- **the irreversible** — deleting or rewriting stored data, sending or publishing outward,
  legal commitments, anything that cannot be taken back by the next change.

These always go to the owner as ordinary questions.

Without a person (a task the owner set and left), the base is the first source for every
decision you take in their place. Money and the irreversible stay off limits there too: follow
the rules of that mode for what you may not do.

## After the answer: record it

Do this in the same turn in which the owner answered, before you go on with the work. The
answer is in the conversation now and will not be there after the session ends.

Record a decision when all hold:

- the owner said or chose it themselves: an answer to a fork, an explicit instruction, or a
  reversal of what you or the base decided. Silence, "ok" to something else and your own
  unconfirmed recommendation are not decisions;
- it shows how they decide, so it can apply again. A name, a date, a number or a text that
  matters to this feature only is not a case;
- it holds no secrets, credentials or personal data of third parties.

A reversal of a settled fork is the most valuable record: it shows where a principle ends.
Record money and irreversible decisions too — they are never settled from the base, but they
tune your recommendations.

Then follow `references/record.md`: write the case, file it under a topic, merge or mark the
boundary, and run `decisions.sh save`. Several answers from one message go in one save.

## Keeping the base true

The base is worth what its principles are worth, so it is merged, not appended.

- A new case that repeats a principle adds its name to that principle and, if it sharpens the
  wording, changes the wording. It does not add a second principle.
- A new case that goes against a principle is a boundary, not an error. If the difference
  between the projects or situations explains it, write the boundary into the principle: where
  it holds, where the other answer holds, and why. If nothing explains it, move it to the
  topic's unresolved list and ask the owner once, in one line, what differs. Until they
  answer, forks under that principle are **ask**.
- A decision the owner replaced outright stays as a case with `superseded_by`, and the
  principle follows the newer one.
- A topic that grows past about 200 lines or answers two kinds of questions is split.

When the owner asks to tidy the base, or `check` reports `UNFILED` or `DANGLING`, repair the
filing first, then merge duplicates and resolve boundaries topic by topic. Do not delete cases:
they are the record the principles are rebuilt from.

## Typical failures

| Thought | Reality |
|---|---|
| "The precedent is about something similar, I will settle it" | Similar wording is not the same decision. Settle only when the principle's conditions hold in this project; otherwise ask |
| "The owner once chose the cheap option, so this spending is settled" | Money and the irreversible are never settled from the base |
| "I will list for the owner what I settled and why" | They asked not to. The record in the document is the report |
| "I will record the answers at the end of the session" | The session may end first. Record in the turn the answer arrives |
| "The base is unavailable, I will decide by my own taste" | Then nothing is settled: ask the owner as usual |
| "Two cases disagree, I will keep the newer one" | First look for what differs between the situations. Replace only when the owner said the old one no longer holds |

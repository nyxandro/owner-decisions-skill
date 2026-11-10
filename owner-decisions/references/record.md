# Recording a decision

The templates below are in English. In the base, write the headings and the labels in the
language the owner speaks, the same way everywhere in that base: if topics already exist, copy
the wording they use. Only the front matter keys, the file names and the `[[...]]` references
stay as they are — the script reads those.

## The case

One file per decision: `cases/<YYYY-MM-DD>-<project>-<slug>.md`. The date is the day the owner
decided, the slug is three to six words in Latin letters. The name is unique, so two machines
never write the same file. A case is not rewritten later, except to add `superseded_by`.

```markdown
---
date: 2026-11-10
project: <project name, or "all" for a decision about how the owner works everywhere>
context: <one line: what the project is, its scale, whose data, what a mistake costs>
class: ordinary | money | irreversible
source: answer | instruction | reversal | history
recommendation: taken | rejected | none
---

## Question
<the fork as a situation, in one to three lines>

## Options
<the options that were on the table, one line each>

## Decision
<what the owner chose>

## Reason
<the owner's reason, in their words where possible. If they gave none, say that it was not
given and do not make one up>
```

`source: history` marks a case taken from old materials rather than from a live answer;
`reversal` marks the owner overturning a decision made for them. `context` is what lets a later
reader tell whether a new project is of the same kind, so describe the project, not the
feature.

## The topic

`topics/<slug>.md` holds the principles drawn from cases of one kind. Before writing anything,
run `decisions.sh index` and read the topic that fits: whether a case is written at all depends
on what the topic already holds. Start a new topic only when no description covers the
question.

```markdown
---
description: <one line: which questions this topic answers — this is all the index shows>
---

# <Topic name>

## <The principle as a rule one can apply: "X, unless Y">

Applies when: <the conditions — kind of project, scale, whose data>
Reason: <the owner's reason, drawn from the cases; say so if none was given>
Boundary: <where the owner decided otherwise and what differed; omit if none>
Cases: [[case-name]], [[case-name]]

## Unresolved

- [[case-a]] against [[case-b]]: <what disagrees>. The owner was asked on <date>.
```

Every case is named in at least one topic as `[[file name without .md]]`; `decisions.sh check`
verifies this.

The reason line holds the owner's reason and nothing else. A principle settles later questions
only through it: without the reason nobody can tell whether a new situation is the same one. So
never put your own explanation there. The same goes for a boundary: if the owner said what
differs, write it as theirs; if you worked the difference out yourself, mark the boundary as
your reading. A boundary marked that way does not settle anything near it — such forks are
asked, and the owner's answer replaces your reading.

## Filing a new decision

0. The decision exactly repeats a principle — the same choice in a project of the same kind,
   with the same reason or with no reason given → write nothing. No case, no edit, no save.
1. The decision confirms a principle and adds to it — a new kind of project, a reason the
   principle lacked, a sharper condition → write the case, add its name to the cases line and
   update the wording or the conditions. One more case is not one more principle.
2. The case goes against a principle and the difference in project or situation explains it →
   write the boundary line: where each answer holds and why, marked as your reading unless the
   owner named the difference.
3. The case goes against a principle and nothing explains it → add both to the unresolved list
   and ask the owner once, in one line, what differs. Their answer becomes the boundary, or
   marks the old case replaced.
4. The owner said the old decision no longer holds → add `superseded_by: <new case name>` to
   the old case's front matter and rewrite the principle from the new one.
5. Nothing covers it → a new principle in the fitting topic, with one case. A case with the
   owner's reason is enough for the principle to settle the same question later; a case
   without a reason only informs recommendations, so say in the reason line that it is unknown.

A topic is read whole by whoever consults the base, so keep it short: when it passes about 200
lines or answers two kinds of questions, split it.

Then run `decisions.sh save --message "<project>: <what was decided>"`. If it prints `UNFILED`
or `DANGLING`, fix the filing and save again. If it prints `TOPIC_OVERWRITTEN <file>`, another
machine changed that topic at the same time and its copy was kept: reread the topic, apply your
change to it again and save again. If the save fails, nothing is lost: the files stay in the
folder and go out with the next save.

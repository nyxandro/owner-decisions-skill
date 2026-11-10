# Recording a decision

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

## Вопрос
<the fork as a situation, in one to three lines>

## Варианты
<the options that were on the table, one line each>

## Решение
<what the owner chose>

## Причина
<the owner's reason, in their words where possible. If they gave none, write "не названа" and
do not make one up>
```

Headings and text are in the owner's language. `source: history` marks a case taken from old
materials rather than from a live answer; `reversal` marks the owner overturning a decision
made for them.

## The topic

`topics/<slug>.md` holds the principles drawn from cases of one kind. Before writing anything,
run `decisions.sh index` and read the topic that fits: whether a case is written at all depends
on what the topic already holds. Start a new topic only when no
description covers the question.

```markdown
---
description: <one line: which questions this topic answers — this is all the index shows>
---

# <Topic name>

## <The principle as a rule one can apply: "X, unless Y">

Когда применимо: <the conditions — kind of project, scale, whose data>
Почему: <the reason, drawn from the cases>
Граница: <where the owner decided otherwise and what differed; omit if none>
Случаи: [[case-name]], [[case-name]]

## Нерешённые расхождения

- [[case-a]] против [[case-b]]: <what disagrees>. Вопрос владельцу задан <date>.
```

Every case is named in at least one topic as `[[file name without .md]]`; `decisions.sh check`
verifies this.

## Filing a new decision

0. The decision exactly repeats a principle — the same choice, the same reason, a project of
   the same kind as the principle's conditions name → write nothing. No case, no edit, no save.
1. The decision confirms a principle and adds to it — a new kind of project, a reason the
   principle lacked, a sharper condition → write the case, add its name to "Случаи" and update
   the wording or the conditions. One more case is not one more principle.
2. The case goes against a principle and the difference in project or situation explains it →
   write the "Граница" line: where each answer holds and why.
3. The case goes against a principle and nothing explains it → add both to "Нерешённые
   расхождения" and ask the owner once, in one line, what differs. Their answer becomes the
   boundary, or marks the old case replaced.
4. The owner said the old decision no longer holds → add `superseded_by: <new case name>` to
   the old case's front matter and rewrite the principle from the new one.
5. Nothing covers it → a new principle in the fitting topic, with one case. A case with the
   owner's reason is enough for the principle to settle the same question later; a case
   without a reason only informs recommendations, so say in "Почему" that the reason is
   unknown.

Then run `decisions.sh save --message "<project>: <what was decided>"`. If it prints `UNFILED`
or `DANGLING`, fix the filing and save again. If it prints `TOPIC_OVERWRITTEN <file>`, another
machine changed that topic at the same time and its copy was kept: reread the topic, apply your
change to it again and save again.

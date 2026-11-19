# Changelog

The current version is `metadata.version` in `owner-decisions/SKILL.md`. Every version is tagged
`vX.Y.Z` in git and published as a GitHub release with its own `.skill` archive. Versions are
numbered MAJOR.MINOR.PATCH.

- **PATCH** (1.0.1) is a fix or clearer wording. The skill behaves the same.
- **MINOR** (1.1.0) is a new or changed rule, for example what may be settled without asking.
- **MAJOR** (2.0.0) changes the format of the base or how the skill attaches to other work.

## [1.3.1] - 2026-11-19

### Fixed

- Right before writing, the agent pulls the base and reads the index again, and rereads the
  topic it writes into, even if it read them earlier in the session. In one session a message
  was sent again several times; each time the agent wrote from what it had read before its own
  first write, recorded the same answers again and started a second topic on the same subject
  under a near-identical name. A rollback undoes the conversation, not the files in the base.
- Before writing a case, the agent reads the cases of the same project dated today on the same
  question: the same answer writes nothing, a changed one supersedes the earlier case.
- A new topic is started only after comparing its subject with every description in a fresh
  index; a topic on the same subject under another name is written into.

## [1.3.0] - 2026-11-19

### Added

- Stops: what the owner stopped agents from doing mid-work ("I did not ask for this"), when
  the objection is to a kind of action taken unasked and nothing ties it to that moment or that
  project. They live in one short file, `stops.md`, under a few sections by subject, and
  nowhere else. When the agent is unsure, it is not a stop; when the owner objects to the same
  kind of action again, it is.
- `decisions.sh index` shows `stops.md` whole after the list of topics, so an agent sees every
  stop whatever question brought it to the base. A topic, by contrast, is read only when its
  question comes up, and a stop is about an action that does not look like a question.
- The skill also starts before an action nobody asked for (installing, sending outward,
  editing a rules file, rewriting stored data) and when the owner stops the agent mid-work.
- Before an action a stop names, the agent follows it. If the project gives a concrete reason
  to do otherwise, it asks the owner once and names that reason; it never breaks a stop
  silently, and without a person it leaves the action undone. A decision settled from the base
  never leads to an action a stop forbids.
- Permission "this time" leaves a stop as it was. A reason that holds for projects of a kind
  becomes the stop's "unless" line. A lifted stop is removed, and the case that lifts it goes
  to a topic so every case stays filed.
- Tests for the script: `tests/decisions.test.sh`.

### Changed

- `decisions.sh check` counts a case named in `stops.md` as filed and reports a stop that names
  a missing case.
- `decisions.sh save` reports a conflicting `stops.md` as `TOPIC_OVERWRITTEN`, as it does for a
  topic, so a stop added on another machine is not lost silently.

## [1.2.0] - 2026-11-19

The test "it shows how they decide, so it can apply again" was read loosely, and decisions that
hold only in one project or for one moment went into the base shared by all projects.

### Changed

- Only decisions that carry to other projects go into the base, and the owner's reason
  decides. A reason about how things should be carries anywhere. A reason that is a trait
  other projects share, such as a personal project or no paying users, carries to projects of
  that kind and is kept with that condition. A fact of one project or of one moment does not.
  A decision without a reason stays out unless the owner said it holds everywhere. The agent
  judges this itself and does not ask.
- A decision about the moment is kept nowhere. A decision about one project is kept only when
  a later session there would otherwise get it wrong, and only where that project alone reads
  it: the documents it keeps its decisions in, or the agent's memory for that project. Never in
  the agent's rules files (`AGENTS.md`, `CLAUDE.md`) or a memory shared by all projects, and
  never in a new file.
- Every reversal of something taken from the base, a fork or a call, is recorded whatever its
  reason; one with no reason goes to the unresolved list.
- Money and irreversible decisions are recorded only when they carry to other projects.
- The skill also starts when the owner says a choice the agent made is not what they wanted.
  Such a correction is weighed by the same test; most are about the moment and are not
  recorded. One that is recorded gets `source: reversal`.

## [1.1.0] - 2026-11-11

### Changed

- The agent consults the base itself; the subagent is gone. On trial runs a subagent spent
  about 65 thousand tokens and 45–50 seconds on one consultation, nearly all of it on starting
  up, while the topics it read took a few thousand. The topic is read by the main agent anyway
  when an answer is recorded, so the subagent saved little context.
- The test for a settled decision moved from `references/consult.md` into `SKILL.md`, and that
  file is removed. The test now warns against reading a precedent as support for the agent's
  own recommendation, which is what the separate reader used to guard against.

## [1.0.1] - 2026-11-11

### Changed

- The subagent that consults the base is told not to read the project: it judges from the
  description the asking agent gives and from the base. The asking agent adds to that
  description any rule or earlier decision of the project that bears on the question. The
  behaviour is the same; the wording closes a way to spend a whole project's reading on one
  consultation.

## [1.0.0] - 2026-11-11

The first stable version. The skill behaves as in 0.5.1.

### Added

- The skill installs as a Claude Code plugin from the
  [nyxandro/skills](https://github.com/nyxandro/skills) catalog.
- The page of the repository in English and in Russian: usage, an example, requirements and
  install options.

## [0.5.1] - 2026-11-10

### Fixed

- A call the agent took for its own that turns out to be about money or the irreversible goes
  to the owner. The text said such a call "stays the agent's", which would have let a planned
  rewrite of stored data through. Found on a trial consultation of forks and calls together.

## [0.5.0] - 2026-11-10

Checked against a workflow that sorts decisions into the agent's own and the owner's, asks
the owner about every one of theirs, and writes a full specification before asking.

### Changed

- The base is consulted for the agent's own calls too — decisions it would take itself but
  the owner could disagree with. Before, a decision the agent thought technical bypassed the
  base, so the owner reversed the same thing project after project. A call the base is silent
  on stays the agent's: consulting never adds questions for the owner.
- The consultation happens as soon as the decisions are listed, not at the moment of asking,
  so nothing is built on a guess the base contradicts.
- A decision settled from the base is stated to be the owner's own earlier answer, so it does
  not clash with a workflow's rule to ask the owner about every decision of theirs.
- A settled fork is recorded among the owner's accepted decisions, a settled call among the
  agent's decisions.
- A decision the project has already made outranks a precedent from another project.

## [0.4.0] - 2026-11-10

A second reading of the skill by its author and by a reader who had never seen it.

### Changed

- The templates of a case and a topic are in English and are written into the base in the
  owner's language. Before, the labels were in one language and the consulting agent looked for
  a label by that name, so the skill settled nothing for anyone else.
- A reason or a boundary the agent worked out itself is marked as its reading and settles
  nothing until the owner confirms it. Before, the agent's explanation of why two decisions
  differ could later pass for the owner's reason.
- "Irreversible" means the act a decision triggers, not the subject of the feature: how a
  feature that sends or deletes things behaves is an ordinary fork.
- A fork settled in a plain session is named in the report with its ground, so a principle
  that no longer fits gets noticed.
- The subagent is given the paths of the instructions, the script and the base.
- Without a person, an unsettled fork is decided by that mode's rules, or by the option
  easiest to undo.
- The owner is defined, a client's or teammate's choices are not recorded as the owner's, and
  nothing a client would call confidential goes into the base.
- A broken base (wrong branch, the same case differing on two machines) is reported to the
  owner in one line. A notice is added to the next message instead of interrupting the work.

### Removed

- Repeated statements of the same rule in three places.

## [0.3.1] - 2026-11-10

### Fixed

- A repository that refuses access because the machine has no saved login was taken for a
  missing network and passed in silence. It is now reported to the owner in one line. Found by
  running the first-use paths against a real GitHub repository.

## [0.3.0] - 2026-11-10

### Changed

- The skill sets itself up. On first use it creates the base as a local folder with its own
  history, and if the machine is logged in to GitHub it clones the account's private base or
  creates a private repository for it. No manual setup and no rule in the global rules file
  are needed.
- The base works without any account: syncing is an addition. A base on GitLab or any other git
  host is connected by giving the agent its address once.
- A base is recognised by a marker file, so a repository that is merely called `decisions` is
  never cloned or written to. A public GitHub repository is refused.
- The owner hears about the base in one line when it is first created, when it stays local and
  why, and when its repository refuses access. Everything else stays silent.

## [0.2.0] - 2026-11-10

### Changed

- An answer that exactly repeats a principle — the same choice, the same reason, a project of
  the same kind — is no longer recorded. The base grows only from what is new, so repeated
  questions about money or irreversible actions, which are always asked, stop adding files.

## [0.1.0] - 2026-11-10

The first version. Forks are checked against the base before they reach the owner, answers are
recorded in the turn they arrive, topics are merged instead of appended, and the base syncs
between machines through a private git repository. Checked on a trial consultation and on two
copies of a base; not yet run through a full feature design.

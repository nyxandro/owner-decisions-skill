# Changelog

The current version is `metadata.version` in `owner-decisions/SKILL.md`. Every version is tagged
`vX.Y.Z` in git and published as a GitHub release with its own `.skill` archive. Versions are
numbered MAJOR.MINOR.PATCH.

- **PATCH** (1.0.1) is a fix or clearer wording. The skill behaves the same.
- **MINOR** (1.1.0) is a new or changed rule, for example what may be settled without asking.
- **MAJOR** (2.0.0) changes the format of the base or how the skill attaches to other work.

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

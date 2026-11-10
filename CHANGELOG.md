# Changelog

The current version is `metadata.version` in `owner-decisions/SKILL.md`. Every version is tagged
`vX.Y.Z` in git and published as a GitHub release with its own `.skill` archive. Versions are
numbered MAJOR.MINOR.PATCH.

- **PATCH** (0.1.1) is a fix or clearer wording. The skill behaves the same.
- **MINOR** (0.2.0) is a new or changed rule, for example what may be settled without asking.
- **MAJOR** (1.0.0) changes the format of the base or how the skill attaches to other work.

- **2026-11-10.** The skill installs as a Claude Code plugin from the
  [nyxandro/skills](https://github.com/nyxandro/skills) catalog.

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

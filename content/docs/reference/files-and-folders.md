---
title: "Files and folders"
weight: 50
description: "What Xaden keeps in a repository and on a machine."
---

## In a repository that has Xaden

```text
xaden/
  xaden.conf            settings (see Configuration)
  RULES.md              rules for assistants; generated, do not edit
  README.md             what this folder is
  footprint.txt         the paths outside xaden/ that Xaden touched
  requirements/         one file per requirement, in epic folders, with INDEX.md
  personas/             user personas
  security-reviews/     recorded security reviews
  baselines/            findings that existed at adoption
  prompts/              optional: replaces a default prompt of the same name
  threat-model.md       written at kickoff (new projects start with a template)
AGENTS.md               a marked block that points to xaden/RULES.md
CLAUDE.md               only for Claude Code users: the line @AGENTS.md
.github/workflows/xaden.yml   the CI job, pinned to a version and checksum
```

New projects also get a `README.md`, `.gitignore`, `VERSION`, `CHANGELOG.md` and `SECURITY.md`; those belong to the project, not to Xaden.

## What `xaden/footprint.txt` records

One line per place outside `xaden/` that Xaden changed, so `xaden remove` can undo exactly that.

| Kind | Meaning | `xaden remove` |
|------|---------|----------------|
| `block` | a marked block in a file that existed | removes the block |
| `created-block` | a marked block in a file Xaden created | removes the block, and the file if nothing else is left |
| `line` | the line `@AGENTS.md` in an existing `CLAUDE.md` | removes the line |
| `created-line` | `CLAUDE.md` created by Xaden | removes the line, and the file if nothing else is left |
| `hook-block` | a block in a hook file of the repository (husky) | removes the block, and the file if only a shebang is left |
| `file` | a file Xaden added, such as the workflow | deletes it |
| `preset-file` | a configuration file of a preset | deletes it |

## Markers

Xaden's blocks are delimited by `<!-- xaden:begin -->` and `<!-- xaden:end -->` in Markdown files, and by `# >>> xaden >>>` and
`# <<< xaden <<<` in hook files. Text outside the markers is never changed.

## Outside the working tree

| Where | What |
|-------|------|
| `.git/hooks/pre-commit`, `.git/hooks/commit-msg` | a block that calls `xaden hook` (plain git, pre-commit, lefthook). Not shared by git; `xaden setup` creates it in each clone. |
| `.git/info/exclude` | the line `context-pack.md`, added by `xaden adopt`, so the pack from `xaden pack` stays out of `git status`. New projects ignore it in `.gitignore`. |

## On a machine

| Path | What |
|------|------|
| `~/.xaden` | the Xaden folder of a git install (any folder for a zip install) |
| `~/.local/bin/xaden` | the link to `scripts/xaden.sh` in that folder |
| `~/.local/share/xaden/versions/<version>/` | other Xaden versions installed for pinned projects; `XADEN_HOME` moves the parent folder |

---
title: "Work commands"
weight: 20
description: "prompt, req, check, context and doc."
---

Commands for daily work inside a project. Run them from any folder below the project's top. In a project that adopted Xaden they run the
installed Xaden version that `xaden/xaden.conf` pins.

## `xaden prompt`

Prints a task prompt for your assistant to follow.

```text
xaden prompt <name>
```

`<name>` is one of `kickoff`, `feature`, `bugfix`, `refactor`, `code-review`, `security-review`, `release`, `requirements-update`, `persona`
or `documentation`. A file of the same name in `xaden/prompts/` replaces the default. An unknown name is an error.

Guide: [Build features]({{< relref "docs/developer-guide/build-features" >}}).

## `xaden req`

Looks up and creates requirements. In Xaden `main` the command is `xaden project req`; `xaden req` is an alias with the same options and exit codes.

```text
xaden req list [--epic <epic>] [--status <status>]
xaden req show REQ-nnn [--brief]
xaden req for <path>...
xaden req find <word>...
xaden req new <epic> <job|quality> "<title>"
xaden req index
```

| Subcommand | Meaning |
|------------|---------|
| `list` | One line per requirement: ID, status, priority, title. `--epic` and `--status` narrow the list; an unknown status is refused. |
| `show REQ-nnn` | The file of one requirement. `--brief` prints the ID, status, title, the job or quality goal and the acceptance criteria only. |
| `for <path>...` | The requirements whose optional `paths:` front-matter line covers one of the files or folders. An entry ending in `/` covers the folder, an entry with `*`, `?` or `[` is a glob over the whole path (a `*` also crosses `/`), anything else is one file. A requirement without `paths:` never matches. |
| `find <word>...` | The requirements whose title or text holds every word, ignoring case, one line each. |
| `new <epic> <job\|quality> "<title>"` | Creates the next requirement as a draft and refreshes the index. The epic is lowercase words with hyphens. |
| `index` | Rewrites the generated `INDEX.md`, which lists only requirements that are not `done` or `dropped` and counts the others per epic, and `INDEX-full.md`, the full table that no tool imports, so the files an assistant loads stay small. |

`xaden check` warns, and does not fail, about a `paths:` entry that matches no file or folder, because a stale entry hides its requirement.

## `xaden check`

Runs the project's checks. In Xaden `main` the command is `xaden project check`; `xaden check` is an alias with the same options and exit codes.

```text
xaden check [--staged] [--strict]
```

| Option | Meaning |
|--------|---------|
| (none) | The full run: all files, the commands in `xaden.conf`, requirements, traceability, secret scan and workflow lint. |
| `--staged` | The pre-commit subset: staged files only, offline. |
| `--strict` | A missing tool is a failure instead of a skipped check. CI uses it. |

The full run also prints `NOT COVERED:` for each audit Xaden knows for your stack and nothing maps; see [Configuration]({{< relref "docs/reference/configuration" >}}).

Every run ends with a summary of passed, failed and skipped checks. A run with skipped checks ends with a warning. How findings are judged
is set by the mode; see [Configuration]({{< relref "docs/reference/configuration" >}}).

Exit status: `0` no check failed (skips included, with a warning); `1` a check failed.

## `xaden context`

Prints the rule IDs, the number of requirements by status, and the `CONTEXT CHECK` fingerprint that an assistant quotes in its first reply.

```text
xaden context
```

## `xaden doc`

Prints a guide that Xaden ships.

```text
xaden doc <clean-code|security|optional-tools|local-llm|rules-<topic>>
```

`rules-<topic>` prints one section of the rules that moved out of the always-loaded rules file: `rules-checks`, `rules-docs`, `rules-findings`, `rules-git`, `rules-requirements`, `rules-security` or `rules-working-style`. `xaden/RULES.md` names the one to read before a task; a classic project has the same text in `docs/rules/`.


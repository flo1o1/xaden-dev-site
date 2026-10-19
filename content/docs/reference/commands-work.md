---
title: "Work commands"
weight: 20
description: "prompt, req, check, persona, context, release, doc and preset."
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

Looks up and creates requirements.

```text
xaden req list
xaden req show REQ-nnn
xaden req new <epic> <job|quality> "<title>"
xaden req index
```

| Subcommand | Meaning |
|------------|---------|
| `list` | One line per requirement: ID, status, priority, title. |
| `show REQ-nnn` | The file of one requirement. |
| `new <epic> <job\|quality> "<title>"` | Creates the next requirement as a draft and refreshes the index. The epic is lowercase words with hyphens. |
| `index` | Rewrites the generated `INDEX.md`. |

## `xaden check`

Runs the project's checks.

```text
xaden check [--staged] [--strict]
```

| Option | Meaning |
|--------|---------|
| (none) | The full run: all files, the commands in `xaden.conf`, requirements, traceability, secret scan and workflow lint. |
| `--staged` | The pre-commit subset: staged files only, offline. |
| `--strict` | A missing tool is a failure instead of a skipped check. CI uses it. |

The full run of an adopted project also prints `NOT COVERED:` for each audit that the classic layout runs and nothing maps; see [Configuration]({{< relref "docs/reference/configuration" >}}).

Every run ends with a summary of passed, failed and skipped checks. A run with skipped checks ends with a warning. How findings are judged
is set by the mode; see [Configuration]({{< relref "docs/reference/configuration" >}}).

Exit status: `0` no check failed (skips included, with a warning); `1` a check failed.

## `xaden persona`

Creates a user persona from the template.

```text
xaden persona new "<name>"
```

The name is one line of at most 60 characters without `/`, `\`, `&` or `:`. Prints the path of the new file. Three to five personas keep the
checks focused.

## `xaden context`

Prints the rule IDs, the number of requirements by status, and the `CONTEXT CHECK` fingerprint that an assistant quotes in its first reply.

```text
xaden context
```

## `xaden release`

Cuts a release: checks, stamps `VERSION` and `CHANGELOG.md`, commits and tags locally. It never pushes.

```text
xaden release <major|minor|patch>
```

Needs a clean working tree, a `VERSION` file and a `CHANGELOG.md` with an `Unreleased` section. It refuses to continue while a check fails, a required
tool is missing, or a requirement, `SECURITY.md` or `xaden/threat-model.md` has an unfilled `TODO` marker. A failed step restores the files.

Guide: [Release a version]({{< relref "docs/developer-guide/release-a-version" >}}).

## `xaden doc`

Prints a guide that Xaden ships.

```text
xaden doc <clean-code|security|optional-tools|local-llm>
```

## `xaden preset`

Adds Xaden's preset for a stack to an adopted project.

```text
xaden preset <python|node>
```

Writes the preset's configuration files at the repository root (never over a file you have), maps the check commands in `xaden/xaden.conf`
and prints the command that installs the tools. Python: `ruff.toml`, `mypy.ini`, `requirements-dev.txt`. Node: `eslint.config.mjs`. It maps the kinds that have no command yet: `lint`, `typecheck` and `test`, and also `audit` (`pip-audit`, or `npm audit --audit-level=high` for Node) and, for Python, `security` (`bandit -q -r . -x ./.venv,./node_modules,./tests`), each with `findings-status = 1`. `expect` is not changed.

Guide: [Check modes and baselines]({{< relref "docs/developer-guide/check-modes-and-baselines" >}}).

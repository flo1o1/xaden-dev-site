---
title: "Configuration"
weight: 40
description: "Every setting in xaden/xaden.conf."
---

`xaden/xaden.conf` holds the settings of a project that has Xaden. It is read by Xaden, never executed, and changed by pull request like
code.

## Format

One setting per line, `key = value`. Lines that start with `#` are comments. Spaces around `=` do not matter. A key that is not listed
below is ignored.

```text
# Xaden settings of this repository.
version = 0.2.3
checksum = 59638a11f21ce827444dad0618533324ae206e191c59814de26049de13b6ea9c
mode = changed-files
commit-convention = conventional
assistants = claude
hook-checks = lint
expect = test,lint
check.test = npm test
check.lint = make lint
```

## Settings

| Key | Values | Meaning |
|-----|--------|---------|
| `version` | `MAJOR.MINOR.PATCH` | The Xaden version the project pins. The tooling that runs is this version; `xaden doctor` compares it with the installed one. |
| `checksum` | 64 hexadecimal characters | SHA-256 of the paths and contents of the pinned release. A download is installed only if it matches. |
| `mode` | `advisory`, `changed-files`, `strict` | What a new finding does. See below. Default when missing: `strict`. |
| `commit-convention` | `conventional`, `other` | `conventional` enforces Conventional Commits and the `Refs:` trailer; `other` lets the `Refs:` checks only advise. |
| `assistants` | comma-separated names, or `none` | The assistants the team uses. `claude` means `CLAUDE.md` exists with the line `@AGENTS.md`. |
| `hook-checks` | comma-separated check names | The checks the pre-commit hook runs. Default: `lint`. The full run and CI run all checks. |
| `expect` | comma-separated kinds: `test`, `lint`, `typecheck` | The kinds of checks the repository should have. A kind without a `check.<kind>` command is a gap. When the line is missing, Xaden looks at the files (`package.json`, `pyproject.toml`). |
| `check.<name>` | a shell command | A check Xaden runs from the repository root, for example `check.test = npm test`. The name is lowercase letters, digits and hyphens. |

## Modes

| Mode | A new finding | A gap (an expected kind without a command) |
|------|---------------|--------------------------------------------|
| `advisory` | warns, the check passes | warning |
| `changed-files` | fails if it is in a file the change touches | warning |
| `strict` | fails in any file | error |

A finding that is in the baseline never fails a check. A failure that names no file (a failing test) cannot be baselined: `advisory` warns,
the other modes fail. Changing `mode` is an approval point.

## Check commands

A check command runs with the repository as the working directory. Xaden judges its output line by line: a line of the form
`path:line:column: message` (or a GitHub annotation `::warning file=path,line=N::message`) is one finding; Xaden records it without the numbers,
so moving code does not make a finding new. If the first word of a command is not installed, the check is skipped and reported, or fails with
`--strict`.

## Baselines

`xaden/baselines/<check>.txt` lists the findings that existed when Xaden was adopted, one per line as `path: message`. Names: `shellcheck`,
`semgrep`, `actionlint`, `zizmor` and one per `check.<name>`. A full run on a developer machine removes fixed findings from the file. In CI
it only warns. A finding is never added.

Guide: [Check modes and baselines]({{< relref "docs/developer-guide/check-modes-and-baselines" >}}).

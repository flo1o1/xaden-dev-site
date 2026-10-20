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
expect = test,lint,audit
update-check = 1d
check.test = npm test
check.lint = make lint
check.audit = npm audit --audit-level=high
findings-status.audit = 1
```

## Settings

| Key | Values | Meaning |
|-----|--------|---------|
| `version` | `MAJOR.MINOR.PATCH` | The Xaden version the project pins. The tooling that runs is this version; `xaden project doctor` compares it with the installed one. |
| `checksum` | 64 hexadecimal characters | SHA-256 of the paths and contents of the pinned release. A download is installed only if it matches. |
| `mode` | `advisory`, `changed-files`, `strict` | What a new finding does. See below. Default when missing: `strict`. |
| `commit-convention` | `conventional`, `other` | `conventional` enforces Conventional Commits and the `Refs:` trailer, in the commit hook and in CI; `other` lets the `Refs:` checks only advise. `xaden project adopt` reads it from the history: `conventional` with no history, with at least 60 percent of the last 30 subjects (from 5 commits on) or with every subject (fewer than 5 commits) following Conventional Commits; otherwise `other`. A full `xaden check` prints a `TIP:` while it is `other`. |
| `assistants` | comma-separated names, or `none` | The assistants the team uses. `claude` means `CLAUDE.md` exists with the line `@AGENTS.md`. |
| `hook-checks` | comma-separated check names | The checks the pre-commit hook runs. Default: `lint`. The full run and CI run all checks. The audits (`audit`, `security`) stay out of the hook: they need the network or are slow. |
| `expect` | comma-separated kinds: `test`, `lint`, `typecheck`, `audit`, `security` | The kinds of checks the repository should have. A kind without a `check.<kind>` command is a gap. A new adoption of a Python or Node repository lists `audit` too, and `security` for Python; an adoption from before keeps its line, and no update adds to it. When the line is missing, Xaden looks at the files (`package.json`, `pyproject.toml`). |
| `findings-status.<name>` | a comma-separated list of exit statuses, 1 to 255 | The statuses with which the check `<name>` (`check.<name>` or a built-in one such as `shellcheck`) reports that it found violations. Only these go through the baseline and the mode. Any other non-zero status means the tool did not run to the end, and the check fails. Not allowed for `test`. `xaden project adopt` records `= 1` for a mapped check that exits with status 1 while the baseline is recorded, and `xaden project preset` sets `= 1` for the checks it maps (`audit`, `security` included); any other status is not recorded, you add it yourself. Loosening it is an approval point. |
| `require-signature` | `true`, `false` | `true`: only releases the maintainer signed are installed or run for this project. Default: `false`. Any other value, an empty one included, stops every `xaden` command. A git checkout of Xaden is never accepted. Setting it back is an approval point. |
| `update-check` | `off`, or a whole number of hours or days of at least `1h`: `12h`, `1d`, `7d` | How often `xaden core upgrade --check --if-due` may look for a newer Xaden and outdated dependencies. It only reports. Default: `off`. The `XADEN_UPDATE_CHECK` environment variable overrides it on one machine. |
| `aidd-cli` | a version, for example `5.5.0` | The exact version of the framework's installer that `xaden aidd` runs. Written by `xaden aidd enable` and `xaden aidd pin`, removed by `xaden aidd disable`. Absent: the framework is not switched on. |
| `aidd-release` | a release tag, for example `v5.12.0` | The release of the framework's plugins that the project holds. Written and removed with `aidd-cli`. |
| `aidd-assistants` | comma-separated names | The assistants the framework was installed for. Written and removed with `aidd-cli`. |
| `check.<name>` | a shell command | A check Xaden runs from the repository root, for example `check.test = npm test`. The name is lowercase letters, digits and hyphens. The kinds Xaden knows are listed under Check kinds below. |

## Modes

| Mode | A new finding | A gap (an expected kind without a command) |
|------|---------------|--------------------------------------------|
| `advisory` | warns, the check passes | warning |
| `changed-files` | fails if it is in a file the change touches | warning |
| `strict` | fails in any file | error |

A finding that is in the baseline never fails a check. A failure that names no file (a failing test) cannot be baselined: `advisory` warns,
the other modes fail. Changing `mode` is an approval point.

A check that exits with a status it does not declare as "violations found" (`findings-status.<name>`) failed to run to the end: it fails in
`changed-files` and `strict` and warns in `advisory`, even when everything it printed was in the baseline.

In `changed-files` mode the change is the staged files (pre-commit), the files since the previous tip of a push (`BEFORE_SHA`) or since the
merge base with the target branch of a pull request (`BASE_REF`) in CI, and otherwise the files that differ from the default branch. When
Xaden cannot tell, that run checks all files as `strict` does and says so; `xaden.conf` is not changed.

## Check commands

A check command runs with the repository as the working directory. Xaden judges its output line by line: a line of the form
`path:line:column: message` (or a GitHub annotation `::warning file=path,line=N::message`) is one finding; Xaden records it without the numbers,
so moving code does not make a finding new. If the first word of a command is not installed, the check is skipped and reported, or fails with
`--strict`.

## Check kinds

Any name works for `check.<name>`; these five are the kinds Xaden knows. `expect` may name them, and `xaden project adopt` and `xaden project preset` fill them.

| Kind | What it runs | Preset command (Python / Node) | Notes |
|------|--------------|--------------------------------|-------|
| `test` | the tests | `pytest -q` / `node --test` | A failing test names no file and is never baselined. |
| `lint` | the linters | `ruff check .` / `npx eslint .` | The only kind the pre-commit hook runs by default. |
| `typecheck` | the type checker | `mypy .` / `npx tsc --noEmit` | |
| `audit` | the dependency audit, every stack | `pip-audit` / `npm audit --audit-level=high` | Needs the network, so the check is labelled `check: audit (needs the network)` and fails with the tool's own message when offline; it is never reported as passed. |
| `security` | Bandit, Python only | `bandit -q -r . -x ./.venv,./node_modules,./tests` | |

The scan finds an existing command by a Makefile target named `audit` or `security`, or an npm script named `audit`. A tool it only sees
configured (a Bandit section in `pyproject.toml`) is listed as found without a command; nothing is guessed. The findings of `audit` and
`security` name no file, so they cannot be baselined: they fail in `changed-files` and `strict` and only warn in `advisory`. The preset
sets `findings-status` to `1` for both. The workflow `xaden project adopt` writes installs the pinned `bandit` and `pip-audit` for a Python project
before it runs the checks.

## What a full run says about unmapped checks

A project runs `bandit`, `pip-audit` (Python) and `npm audit` (Node) only when `check.audit` or `check.security` maps them. When a full
run finds a stack for which Xaden knows one of them and nothing maps it, it prints one line for each:

```text
NOT COVERED: pip-audit; a project made by xaden project create runs it. Map it with check.audit in xaden/xaden.conf (see "What Xaden checks")
TIP: name them in 'expect' once they are mapped (xaden project preset <stack> maps the commands) so a missing mapping is a gap
```

The line only informs. When `expect` names the kind, the missing mapping is a gap instead (see Modes) and the line does not appear, so an
adoption from before never turns red by an update. A project made by `xaden project create` never prints it. The Developer Guide page "What Xaden
checks" lists, per layout and stack, every check, whether a missing tool skips or fails it, which ones need the network and which run in the
pre-commit hook.

## Baselines

`xaden/baselines/<check>.txt` lists the findings that existed when Xaden was adopted, one per line as `path: message`. Names: `shellcheck`,
`semgrep`, `actionlint`, `zizmor` and one per `check.<name>`. A full run on a developer machine removes fixed findings from the file. In CI
it only warns. A finding is never added.

Guide: [Check modes and baselines]({{< relref "docs/developer-guide/check-modes-and-baselines" >}}).

---
title: "Project commands"
weight: 10
description: "core, project and every xaden project command, version and help."
---

Commands that act on a project and the Xaden version it uses: create, adopt, remove, setup, pin, rules, add-preset, release and persona, and the version. `doctor`, `fetch` and `ignore-list` read the project too but act on Xaden, so they are `xaden core` commands. They work from any folder unless
the entry says otherwise.

Commands are grouped by what they act on: `xaden core` acts on Xaden itself, `xaden project` on one project and the Xaden version it uses.
The commands for daily work (`check`, `req`, `context`, `prompt`, `doc`, `aidd`, `verify-commits`, `hook`) have no namespace, because git hooks, CI
workflows and the rules every assistant reads call them. The old top-level spellings of the moved commands (`xaden create`, `xaden pin`,
`xaden upgrade`, ...) are unknown.

## `xaden core`

```text
xaden core upgrade [--check [--if-due]] [<version>]
xaden core version
xaden core fetch <version>
xaden core doctor
xaden core ignore-list
xaden core help
```

The commands that act on Xaden itself, not on a project: `upgrade` updates it on this machine, `version` prints the installed version, `fetch`
installs a version, `doctor` compares the installed version with the pinned one and `ignore-list` prints the paths Xaden owns. `help` lists
these commands, and so do `-h` and `--help`. Without a command, `xaden core` prints the list and exits with status `2`. Details: [`xaden core upgrade`]({{< relref "docs/reference/commands-team" >}}#xaden-core-upgrade).

## `xaden project`

```text
xaden project <create|adopt|remove|pin|rules|add-preset|setup|release|persona|check|req|help> [<arguments>]
```

The commands that act on one project and the Xaden version it uses; each entry in this Reference names its full spelling. Without a
command, `xaden project` prints the list and exits with status `2`; `xaden project help` prints it and exits with `0`. A project that pins an older Xaden than the one that introduced these
names hands the command over as typed and that version does not know it: run `xaden project pin` first.

`xaden check` and `xaden req` are shortcuts of `xaden project check` and `xaden project req`, and `xaden version` is an alias of
`xaden core version`: the same output and exit codes, no notice. `aidd` is a namespace of its own, for the AI-Driven Development
framework (`xaden aidd help` lists its commands; every namespace has a `help` command). A project command outside a git repository fails and names `xaden project create <name>`
and `xaden project adopt`; in a repository that has not adopted Xaden it prints `this repository has not adopted Xaden; run: xaden project adopt`.

## `xaden project create`

Creates a project in the `xaden/` layout, with its own git repository, hooks, a CI workflow and a first commit on `main`.

```text
xaden project create [--assistants <list>] <name> [<dir>]
xaden project create --autopilot [--stack python|node] [--assistants <list>] <name> [<dir>]
```

| Argument or option | Meaning |
|--------------------|---------|
| `<name>` | Project name: lowercase letters, digits, hyphens and dots, 2 to 51 characters, starting with a letter. A dot must sit between other characters: `mywebsite.com` is fine, `site.` and `my..site` are refused. |
| `<dir>` | The folder to create. Default: `./<name>`. |
| `--autopilot` | Add the stack's preset and print one plan; ask once before anything is created. |
| `--stack python\|node` | The stack for autopilot. Without it, autopilot asks (in a terminal) or stops. |
| `--assistants <list>` | Comma-separated assistants. `claude` adds `CLAUDE.md` with the line `@AGENTS.md`. Without it, a terminal gets a question and a script gets no `CLAUDE.md`. |

Exit status: `0` created, or nothing changed because you answered no or there is no terminal for autopilot; `2` the folder already holds
code, a build file or history; `1` any other error. A failed run removes the folder it created.

Guide: [Create a project]({{< relref "docs/developer-guide/create-a-project" >}}).

## `xaden project adopt`

Adds Xaden to the repository you are in, on a new branch and worktree. Run it inside a git clone.

```text
xaden project adopt [--scan | --plan] [--yes] [--assistants <list>] [--mode <mode>]
            [--check <kind>=<command>]... [--preset | --no-preset] [--skip-hooks] [--skip-ci]
            [--commit-convention <conventional|other>]
```

| Option | Meaning |
|--------|---------|
| `--scan` | Report what the repository has: stacks, test runner (npm, pytest, `unittest`, make and others), linters, type checker, dependency audit, security linter, and the kinds of checks it lacks. Changes nothing. |
| `--plan` (alias `--dry-run`) | Print the exact diff and the file list. Changes nothing. |
| `--yes` | Apply the plan without the question. Use it in scripts. |
| `--assistants <list>` | Comma-separated assistants. Default: pre-selected from what the scan finds, confirmed by you. |
| `--mode advisory\|changed-files\|strict` | Mode of the checks. Default: `changed-files`. |
| `--check <kind>=<command>` | Name a check command the scan did not find, for example `--check test="make verify"`. Repeatable. |
| `--preset`, `--no-preset` | Add Xaden's preset for Python or Node as a separate commit, or never. Without either, a terminal gets a question. |
| `--skip-hooks`, `--skip-ci` | Do not chain into the git hooks, or do not add the workflow. |
| `--commit-convention conventional\|other` | Overrides what the scan reads from the history. Without it the scan shows its evidence, for example `conventional (3 of 3 subjects)`. |

A new adoption expects `audit` for a Python or Node repository and `security` for Python (`expect` in `xaden/xaden.conf`): until a command maps them they are gaps. See [Configuration]({{< relref "docs/reference/configuration" >}}).

Without a terminal and without `--yes`, `adopt` stops after the plan. It creates the branch `chore/adopt-xaden` in the folder
`<repo>-adopt-xaden`; in a repository without commits it works in place.

Exit status: `0` done or nothing changed; `1` error (not a git repository, already adopted, branch or folder exists); `4` the hook manager or
CI system is not supported.

Guide: [Add Xaden to a repository]({{< relref "docs/developer-guide/add-xaden-to-a-repository" >}}).

## `xaden project remove`

Takes Xaden out of the working tree of an adopted repository.

```text
xaden project remove [--yes]
```

Deletes `xaden/` and undoes exactly the paths listed in `xaden/footprint.txt`. It commits nothing. `--yes` skips the question; without a
terminal and without `--yes` it changes nothing.

Exit status: `0` removed or nothing changed; `1` Xaden is not adopted here.

Guide: [Uninstall]({{< relref "docs/admin-guide/uninstall" >}}).

## `xaden project setup`

Chains Xaden's checks into the git hooks of this clone and reports missing tools.

```text
xaden project setup
```

Run it once per clone, because git does not share hooks. It keeps what your hooks already do and is safe to run again. Hooks that are files of
the repository (husky) need no setup.

Guide: [Join a project]({{< relref "docs/developer-guide/join-a-project" >}}).

## `xaden core doctor`

Compares the installed Xaden with the one the project pins. Reads two files and uses no network.

```text
xaden core doctor
```

Run it inside a project. Prints `installed X, project pinned Y` and checks the installed copy against the pinned checksum.

Exit status: `0` the pinned version is available and matches; `1` it is missing or does not match.

Guide: [Pin one Xaden version per project]({{< relref "docs/admin-guide/pin-one-version-per-project" >}}).

## `xaden core fetch`

Installs a pinned Xaden version that is missing on this machine.

```text
xaden core fetch <version>
```

The version must be the one `xaden/xaden.conf` pins. It shows version, source and checksum, then asks `Download and install Xaden <version> now? [y/N]`.
Only a yes downloads. The download is installed only if it matches the pinned checksum and, when a signature exists, the signature. Versions go to
`~/.local/share/xaden/versions`.

Exit status: `0` installed or already installed; `1` you answered no; `3` no terminal, nothing downloaded; `5` checksum mismatch; `6` signature mismatch.

Guide: [Pin one Xaden version per project]({{< relref "docs/admin-guide/pin-one-version-per-project" >}}).

## `xaden project pin`

Moves the project to another Xaden version on a branch for a pull request, or looks for a newer release.

```text
xaden project pin --check
xaden project pin [<version>]
```

| Form | Meaning |
|------|---------|
| `--check` | Ask, then look up the newest release on github.com and report it. Changes nothing. |
| `<version>` | Create the branch `chore/upgrade-xaden-<version>` in a folder next to the project, bump version and checksum in `xaden/xaden.conf`, regenerate `xaden/RULES.md`, update the workflow, bring the command files up to date, and show the diff and the changelog entries. A command file you edited stays as it is and the new text is written next to it as `<file>-dist`. When your CI workflow differs from the one the new version generates (for example it lacks the step that records the pinned checksum, which `require-signature = true` needs on a fresh runner), the new workflow is written next to yours as `.github/workflows/xaden.yml-dist` and `pin` prints the `diff` command; your workflow is never replaced. |
| (no version) | Look up the newest release first, as `--check` does, then pin it. |

Asks before any network access and before downloading a version that is not installed. A signed release pins the signed checksum; otherwise the
checksum of the download is pinned and Xaden says so.

Exit status: `0` done; `1` you answered no or an error; `3` no terminal, nothing looked up or downloaded; `5` checksum mismatch; `6` signature mismatch.

## `xaden project rules`

Regenerates `xaden/RULES.md` from the pinned Xaden version.

```text
xaden project rules
```

Use it when `xaden project check` reports that the rules file does not match the pinned version. Review the diff and commit it.

## `xaden core ignore-list`

Prints the paths Xaden owns in a repository, one per line, for `.dockerignore`, `.npmignore` and archive excludes.

```text
xaden core ignore-list
```

Prints `xaden/`, `AGENTS.md` and, when the file exists, `CLAUDE.md`. Changes no file.
## `xaden project persona`

Creates a user persona from the template.

```text
xaden project persona new "<name>"
```

The name is one line of at most 60 characters without `/`, `\`, `&` or `:`. Prints the path of the new file. Three to five personas keep the
checks focused.

## `xaden project release`

Cuts a release: checks, stamps `VERSION` and `CHANGELOG.md`, commits and tags locally. It never pushes.

```text
xaden project release <major|minor|patch>
```

Needs a clean working tree, a `VERSION` file and a `CHANGELOG.md` with an `Unreleased` section. It refuses to continue while a check fails, a required
tool is missing, or a requirement, `SECURITY.md` or `xaden/threat-model.md` has an unfilled `TODO` marker. A failed step restores the files.

Guide: [Release a version]({{< relref "docs/developer-guide/release-a-version" >}}).

## `xaden project add-preset`

Adds Xaden's preset for a stack to an adopted project.

```text
xaden project add-preset <python|node>
```

Writes the preset's configuration files at the repository root (never over a file you have), maps the check commands in `xaden/xaden.conf`
and prints the command that installs the tools. Python: `ruff.toml`, `mypy.ini`, `requirements-dev.txt`. Node: `eslint.config.mjs`. It maps the kinds that have no command yet: `lint`, `typecheck` and `test`, and also `audit` (`pip-audit`, or `npm audit --audit-level=high` for Node) and, for Python, `security` (`bandit -q -r . -x ./.venv,./node_modules,./tests`), each with `findings-status = 1`. `expect` is not changed.

Guide: [Check modes and baselines]({{< relref "docs/developer-guide/check-modes-and-baselines" >}}).
## `xaden project check`

Runs the project's checks. Shortcut: `xaden check` does the same, with the same options and exit codes.

```text
xaden project check [--staged] [--strict]
```

| Option | Meaning |
|--------|---------|
| (none) | The full run: all files, the commands in `xaden.conf`, requirements, traceability, secret scan and workflow lint. |
| `--staged` | The pre-commit subset: staged files only, offline. |
| `--strict` | A missing tool is a failure instead of a skipped check. CI uses it. `missing-tools = fail` in `xaden/xaden.conf` does the same for every run. |

The full run also prints `NOT COVERED:` for each audit Xaden knows for your stack and nothing maps; see [Configuration]({{< relref "docs/reference/configuration" >}}).

Every run ends with a summary of passed, failed and skipped checks. A run with skipped checks ends with a warning. How findings are judged
is set by the mode; see [Configuration]({{< relref "docs/reference/configuration" >}}).

Exit status: `0` no check failed (skips included, with a warning); `1` a check failed.

## `xaden project req`

Looks up and creates requirements. Shortcut: `xaden req` does the same, with the same options and exit codes.

```text
xaden project req list [--epic <epic>] [--status <status>]
xaden project req show REQ-nnn [--brief]
xaden project req for <path>...
xaden project req find <word>...
xaden project req new <epic> <job|quality> "<title>"
xaden project req index
```

| Subcommand | Meaning |
|------------|---------|
| `list` | One line per requirement: ID, status, priority, title. `--epic` and `--status` narrow the list; an unknown status is refused. |
| `show REQ-nnn` | The file of one requirement. `--brief` prints the ID, status, title, the job or quality goal and the acceptance criteria only. |
| `for <path>...` | The requirements whose optional `paths:` front-matter line covers one of the files or folders. An entry ending in `/` covers the folder, an entry with `*`, `?` or `[` is a glob over the whole path (a `*` also crosses `/`), anything else is one file. A requirement without `paths:` never matches. |
| `find <word>...` | The requirements whose title or text holds every word, ignoring case, one line each. |
| `new <epic> <job\|quality> "<title>"` | Creates the next requirement as a draft and refreshes the index. The epic is lowercase words with hyphens. |
| `index` | Rewrites the generated `INDEX.md`, which lists only requirements that are not `done` or `dropped` and counts the others per epic, and `INDEX-full.md`, the full table that no tool imports, so the files an assistant loads stay small. |

`xaden project check` warns, and does not fail, about a `paths:` entry that matches no file or folder, because a stale entry hides its requirement.

## `xaden check`

Shortcut of [`xaden project check`]({{< relref "docs/reference/commands-project#xaden-project-check" >}}): the same options, output and exit codes.

## `xaden req`

Shortcut of [`xaden project req`]({{< relref "docs/reference/commands-project#xaden-project-req" >}}): the same subcommands, output and exit codes.

## `xaden version`

Prints the installed Xaden version, for example `0.3.0`. It is an alias of `xaden core version`.

```text
xaden version
```

## `xaden help`

Prints the list of namespaces and daily commands. The commands of one namespace: `xaden core help`, `xaden project help` and `xaden aidd help`
(also `-h` and `--help`). `xaden help` takes no namespace: `xaden help core` fails as an unknown command.

```text
xaden help
```

## Spellings of Xaden 0.5 and earlier

The site documents the newest Xaden on `main`. The release the site pins, 0.5, still has the commands below at the top level; from the next release
they carry the namespace named in each entry, with the same options and exit status.

## `xaden adopt`

Xaden 0.5 and earlier. From the next release: `xaden project adopt`.

## `xaden create`

Xaden 0.5 and earlier. From the next release: `xaden project create`.

## `xaden doctor`

Xaden 0.5 and earlier. From the next release: `xaden core doctor`.

## `xaden fetch`

Xaden 0.5 and earlier. From the next release: `xaden core fetch`.

## `xaden ignore-list`

Xaden 0.5 and earlier. From the next release: `xaden core ignore-list`.

## `xaden persona`

Xaden 0.5 and earlier. From the next release: `xaden project persona`.

## `xaden preset`

Xaden 0.5 and earlier. From the next release: `xaden project add-preset`.

## `xaden release`

Xaden 0.5 and earlier. From the next release: `xaden project release`.

## `xaden remove`

Xaden 0.5 and earlier. From the next release: `xaden project remove`.

## `xaden rules`

Xaden 0.5 and earlier. From the next release: `xaden project rules`.

## `xaden setup`

Xaden 0.5 and earlier. From the next release: `xaden project setup`.

## `xaden upgrade`

Xaden 0.5 and earlier. From the next release: `xaden core upgrade`.

---
title: "Project commands"
weight: 10
description: "core, project, create, adopt, remove, version and help."
---

Commands that create a project, add Xaden to a repository, take it out again, and report the version. They work from any folder unless
the entry says otherwise.

Commands are grouped by what they act on: `xaden core` acts on Xaden itself, `xaden project` on one project and the Xaden version it uses.
The commands for daily work (`check`, `req`, `context`, `prompt`, `doc`, `aidd`, `verify-commits`, `hook`) have no namespace, because git hooks, CI
workflows and the rules every assistant reads call them. The old top-level spellings of the moved commands (`xaden create`, `xaden pin`,
`xaden upgrade`, ...) are unknown.

## `xaden core`

```text
xaden core upgrade [--check [--if-due]] [<version>]
xaden core version
```

`upgrade` updates Xaden itself on this machine, `version` prints the installed version. Without a command, `xaden core` prints this list and
exits with status `2`. Details: [`xaden core upgrade`]({{< relref "docs/reference/commands-team" >}}#xaden-core-upgrade).

## `xaden project`

```text
xaden project <create|adopt|remove|pin|fetch|doctor|rules|preset|setup|release|persona|ignore-list> [<arguments>]
```

The commands that act on one project and the Xaden version it uses; each entry in this Reference names its full spelling. Without a
command, `xaden project` prints the list and exits with status `2`. A project that pins an older Xaden than the one that introduced these
names hands the command over as typed and that version does not know it: run `xaden project pin` first.

## `xaden project create`

Creates a project in the `xaden/` layout, with its own git repository, hooks, a CI workflow and a first commit on `main`.

```text
xaden project create [--assistants <list>] <name> [<dir>]
xaden project create --autopilot [--stack python|node] [--assistants <list>] <name> [<dir>]
```

| Argument or option | Meaning |
|--------------------|---------|
| `<name>` | Project name: lowercase letters, digits and hyphens, 2 to 51 characters, starting with a letter. |
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

## `xaden version`

Prints the installed Xaden version, for example `0.3.0`. `xaden core version` does the same.

```text
xaden version
```

## `xaden help`

Prints the list of commands. `xaden help core` and `xaden help project` print one namespace.

```text
xaden help [core|project]
```

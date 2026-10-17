---
title: "Project commands"
weight: 10
description: "new, adopt, remove, update, version and help."
---

Commands that create a project, add Xaden to a repository, take it out again, and report the version. They work from any folder unless
the entry says otherwise.

## `xaden create`

Creates a project in the `xaden/` layout, with its own git repository, hooks, a CI workflow and a first commit on `main`.

```text
xaden create [--assistants <list>] <name> [<dir>]
xaden create --autopilot [--stack python|node] [--assistants <list>] <name> [<dir>]
xaden create --classic <name> [<dir>]
```

| Argument or option | Meaning |
|--------------------|---------|
| `<name>` | Project name: lowercase letters, digits and hyphens, 2 to 51 characters, starting with a letter. |
| `<dir>` | The folder to create. Default: `./<name>`. |
| `--autopilot` | Add the stack's preset and print one plan; ask once before anything is created. |
| `--stack python\|node` | The stack for autopilot. Without it, autopilot asks (in a terminal) or stops. |
| `--assistants <list>` | Comma-separated assistants. `claude` adds `CLAUDE.md` with the line `@AGENTS.md`. Without it, a terminal gets a question and a script gets no `CLAUDE.md`. |
| `--classic` | Create a project that keeps its own copy of the scripts, prompts and guides (update it with `xaden update`). |

Exit status: `0` created, or nothing changed because you answered no or there is no terminal for autopilot; `2` the folder already holds
code, a build file or history; `1` any other error. A failed run removes the folder it created.

Guide: [Create a project]({{< relref "docs/developer-guide/create-a-project" >}}).

## `xaden adopt`

Adds Xaden to the repository you are in, on a new branch and worktree. Run it inside a git clone.

```text
xaden adopt [--scan | --plan] [--yes] [--assistants <list>] [--mode <mode>]
            [--check <kind>=<command>]... [--preset | --no-preset] [--skip-hooks] [--skip-ci]
```

| Option | Meaning |
|--------|---------|
| `--scan` | Report what the repository has. Changes nothing. |
| `--plan` (alias `--dry-run`) | Print the exact diff and the file list. Changes nothing. |
| `--yes` | Apply the plan without the question. Use it in scripts. |
| `--assistants <list>` | Comma-separated assistants. Default: pre-selected from what the scan finds, confirmed by you. |
| `--mode advisory\|changed-files\|strict` | Mode of the checks. Default: `changed-files`. |
| `--check <kind>=<command>` | Name a check command the scan did not find, for example `--check test="make verify"`. Repeatable. |
| `--preset`, `--no-preset` | Add Xaden's preset for Python or Node as a separate commit, or never. Without either, a terminal gets a question. |
| `--skip-hooks`, `--skip-ci` | Do not chain into the git hooks, or do not add the workflow. |

Without a terminal and without `--yes`, `adopt` stops after the plan. It creates the branch `chore/adopt-xaden` in the folder
`<repo>-adopt-xaden`; in a repository without commits it works in place.

Exit status: `0` done or nothing changed; `1` error (not a git repository, already adopted, branch or folder exists); `4` the hook manager or
CI system is not supported.

Guide: [Add Xaden to a repository]({{< relref "docs/developer-guide/add-xaden-to-a-repository" >}}).

## `xaden remove`

Takes Xaden out of the working tree of an adopted repository.

```text
xaden remove [--yes]
```

Deletes `xaden/` and undoes exactly the paths listed in `xaden/footprint.txt`. It commits nothing. `--yes` skips the question; without a
terminal and without `--yes` it changes nothing.

Exit status: `0` removed or nothing changed; `1` Xaden is not adopted here.

Guide: [Uninstall]({{< relref "docs/admin-guide/uninstall" >}}).

## `xaden update`

Brings a project created with `xaden create --classic` to the installed Xaden version.

```text
xaden update [--apply]
```

Without `--apply` it is a dry run that lists what would change. With `--apply` it stages the changes in git. Run it inside the project. In a
project with an `xaden/` folder it stops and points to `xaden upgrade`.

Guide: [Update a classic project]({{< relref "docs/admin-guide/update-a-classic-project" >}}).

## `xaden version`

Prints the installed Xaden version, for example `0.3.0`.

```text
xaden version
```

## `xaden help`

Prints the list of commands.

```text
xaden help
```

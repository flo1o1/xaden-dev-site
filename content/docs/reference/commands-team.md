---
title: "Team commands"
weight: 30
description: "setup, doctor, fetch, upgrade, update-check, rules, hook and ignore-list."
---

Commands for keeping a team on the same Xaden version, the same hooks and the same rules. They work inside a project that adopted Xaden.

## `xaden setup`

Chains Xaden's checks into the git hooks of this clone and reports missing tools.

```text
xaden setup
```

Run it once per clone, because git does not share hooks. It keeps what your hooks already do and is safe to run again. Hooks that are files of
the repository (husky) need no setup.

Guide: [Join a project]({{< relref "docs/developer-guide/join-a-project" >}}).

## `xaden doctor`

Compares the installed Xaden with the one the project pins. Reads two files and uses no network.

```text
xaden doctor
```

Prints `installed X, project pinned Y` and checks the installed copy against the pinned checksum.

Exit status: `0` the pinned version is available and matches; `1` it is missing or does not match.

Guide: [Pin one Xaden version per project]({{< relref "docs/admin-guide/pin-one-version-per-project" >}}).

## `xaden fetch`

Installs a pinned Xaden version that is missing on this machine.

```text
xaden fetch <version>
```

The version must be the one `xaden/xaden.conf` pins. It shows version, source and checksum, then asks `Download and install Xaden <version> now? [y/N]`.
Only a yes downloads. The download is installed only if it matches the pinned checksum and, when a signature exists, the signature. Versions go to
`~/.local/share/xaden/versions`.

Exit status: `0` installed or already installed; `1` you answered no; `3` no terminal, nothing downloaded; `5` checksum mismatch; `6` signature mismatch.

Guide: [Pin one Xaden version per project]({{< relref "docs/admin-guide/pin-one-version-per-project" >}}).

## `xaden upgrade`

Moves the project to a newer Xaden version on a branch for a pull request, or looks for a newer release.

```text
xaden upgrade --check
xaden upgrade [<version>]
```

| Form | Meaning |
|------|---------|
| `--check` | Ask, then look up the newest release on github.com and report it. Changes nothing. |
| `<version>` | Create the branch `chore/upgrade-xaden-<version>` in a folder next to the project, bump version and checksum in `xaden/xaden.conf`, regenerate `xaden/RULES.md`, update the workflow, and show the diff and the changelog entries. |
| (no version) | Look up the newest release first, as `--check` does, then upgrade to it. |

Asks before any network access and before downloading a version that is not installed. A signed release pins the signed checksum; otherwise the
checksum of the download is pinned and Xaden says so.

Exit status: `0` done; `1` you answered no or an error; `3` no terminal, nothing looked up or downloaded; `5` checksum mismatch; `6` signature mismatch.

## `xaden update-check`

Looks for a newer Xaden and for outdated dependencies. It only reports; it never installs or changes anything.

```text
xaden update-check [--if-due|--now]
```

Checks now, whatever the interval, and prints the result. The check is off by default (`update-check = off` in `xaden/xaden.conf`) and the command
refuses while it is off; `--now` looks anyway. `--if-due` checks only when the interval has passed, prints nothing and exits `0` when the network is
down. The `XADEN_UPDATE_CHECK` environment variable takes the same values and overrides the project setting on your machine.

The one network request goes to the GitHub release API. The result is cached in the repository's git folder and never committed.

Guide: [Check for updates]({{< relref "docs/admin-guide/check-for-updates" >}}).

## `xaden rules`

Regenerates `xaden/RULES.md` from the pinned Xaden version.

```text
xaden rules
```

Use it when `xaden check` reports that the rules file does not match the pinned version. Review the diff and commit it.

## `xaden hook`

Runs a git hook. Git calls it from the hooks that `xaden adopt`, `xaden create` and `xaden setup` install; you do not run it by hand.

```text
xaden hook pre-commit
xaden hook commit-msg <message-file>
```

`pre-commit` runs the staged checks. `commit-msg` checks the message against the commit convention in `xaden/xaden.conf`. In a clone whose
branch does not carry Xaden yet, it does nothing.

## `xaden ignore-list`

Prints the paths Xaden owns in a repository, one per line, for `.dockerignore`, `.npmignore` and archive excludes.

```text
xaden ignore-list
```

Prints `xaden/`, `AGENTS.md` and, when the file exists, `CLAUDE.md`. Changes no file.

---
title: "Team commands"
weight: 30
description: "upgrade, update-check, aidd, hook and verify-commits."
---

Commands for keeping a team on the same Xaden version, the same hooks and the same rules. They work inside a project that adopted Xaden.

## `xaden core upgrade`

Updates Xaden itself on your machine. It never moves a project.

```text
xaden core upgrade --check [--if-due]
xaden core upgrade [<version>]
```

| Form | Meaning |
|------|---------|
| `--check` | Ask, then look up the newest release on github.com and report it. Inside a project it also lists the outdated npm and pip dependencies and marks a newest version with a higher major number `(major)`. Looks now, whatever the `update-check` setting says. Changes nothing. |
| `--check --if-due` | The quiet form for scripts: checks only when the `update-check` interval has passed, writes the cache, prints nothing and exits `0` when the network is down. Off means no check. |
| (no version) | Look up the newest release, show version, source and checksum, ask, download, verify signature and checksum, install it into `~/.local/share/xaden/versions/<version>` and switch the `current` link to it. |
| `<version>` | The same for that version. Inside a project that adopted Xaden it still installs on your machine only; the project stays where it is, and Xaden names `xaden project pin <version>` for moving it. |

The `xaden` command links to `current`, so it never changes. A failed download or check leaves the old version active. Older versions stay, because
projects that pin them use them. A Xaden that runs from a git clone is not touched; the command names `git -C <folder> pull`. A Xaden installed
before this layout existed asks you to install once with the one command.

Exit status: `0` done; `1` you answered no or an error; `3` no terminal, nothing looked up or downloaded; `5` checksum mismatch; `6` signature mismatch.

Guide: [Update Xaden]({{< relref "docs/admin-guide/update-xaden" >}}).

## `xaden update-check`

Only in Xaden 0.5 and earlier; it is gone from `main` and from the next release. Use `xaden core upgrade --check` (look now) or `xaden core upgrade --check --if-due` (quiet, interval). The setting `update-check` and the `XADEN_UPDATE_CHECK` environment variable are unchanged.

## `xaden aidd`

`aidd` is a namespace of its own, not part of `project`; `xaden aidd help` lists its commands.

Switches the [AI-Driven Dev framework](https://github.com/ai-driven-dev/framework) (MIT) on or off in a project, at a pinned version. The framework is an optional add-on: its skills and agents take a task from spec to review, and Xaden stays the layer that sets the rules and runs the checks. Where a framework skill and Xaden's rules disagree, Xaden's rules win.

```text
xaden aidd enable [--ai <ids>]
xaden aidd status
xaden aidd disable
xaden aidd pin <cli-version> <release>
```

| Form | Meaning |
|------|---------|
| `enable` | Show the exact command, ask, then check that npm and GitHub still answer the pin (`aidd-integrity`, `aidd-commit`) and run the framework's installer (`@ai-driven-dev/cli`, through `npx`) at the pinned CLI version and release. It writes `.aidd/` and the settings of the assistants, adds a block marked `xaden:aidd` to `AGENTS.md`, and records `aidd-cli`, `aidd-release`, `aidd-integrity`, `aidd-commit` and `aidd-assistants` in `xaden/xaden.conf`. `--ai claude,cursor` chooses the assistants; without it Xaden uses the ones in `assistants`. |
| `status` | Print the pin, its integrity and commit, next to what is installed. Exit status `1` when an installed plugin does not come from the pinned release. |
| `disable` | Ask, check the pin like `enable` does, then run the framework's own `clean`, remove the block from `AGENTS.md` and the pin settings. A marketplace registration in your Claude Code user settings stays, as it does with the framework's own `clean`. |
| `pin` | Ask, read the integrity of the new CLI from npm and the commit of the release from GitHub, then create the branch `chore/pin-aidd-<release>` in a folder next to the project, run the installer there at the new pin, commit (with both values recorded), and print a link to the framework's changes between the two releases. Nothing else moves the pin. |

Needs Node 22.12 or later, `git` and `npx`, only for the framework's installer; Xaden itself needs none of them for this. The project must have adopted Xaden. Xaden never uses "latest": `enable` stops before it installs when the pinned CLI cannot be held to a release (it asks that of the CLI only after your yes, because running it downloads it through `npx`), and removes the installation again when a plugin does not come from the pinned release.

Asks before every download and needs a terminal, so a script or an assistant cannot switch it on for you. Until you say yes, the framework's CLI is neither downloaded nor started.

Exit status: `0` done, or nothing to do; `1` you answered no, nobody could be asked, a prerequisite is missing, the installer failed, or the pin did not hold.

The Developer Guide page "Use the AIDD framework" explains the steps; it comes with the next Xaden release.

## `xaden hook`

Runs a git hook. Git calls it from the hooks that `xaden project adopt`, `xaden project create` and `xaden project setup` install; you do not run it by hand.

```text
xaden hook pre-commit
xaden hook commit-msg <message-file>
```

`pre-commit` runs the staged checks. `commit-msg` checks the message against the commit convention in `xaden/xaden.conf`. In a clone whose
branch does not carry Xaden yet, it does nothing.

## `xaden verify-commits`

Checks the messages of commits that exist already, with the rules of the commit hook. The workflow that `xaden project adopt` writes runs it, because a git hook can be skipped (`git commit --no-verify`, a clone without `xaden project setup`, an unattended assistant) and CI cannot.

```text
xaden verify-commits --ci
xaden verify-commits <revision-range>
```

`--ci` derives the range from the variables the workflow passes: `EVENT_NAME`, `BASE_REF`, `BEFORE_SHA` and `DEFAULT_BRANCH`. For a pull request that is every commit since the target branch, for a push every commit since the previous tip. A range it cannot derive or read fails; it is never read as empty. In an adopted project, a first push or a force-push of the default branch checks only the commits after the one that added `xaden/xaden.conf`, so history from before the adoption never fails the step. Merge commits are skipped; every commit they bring in is checked.

The command needs the full history. In a shallow checkout, or when git cannot list the range, it exits with status `2` and names `fetch-depth: 0`, whatever the commit convention. Status `1` means a commit failed the checks.

With `commit-convention = conventional` a wrong format, a `feat` without `Refs: REQ-nnn`, a `fix` without a requirement ID or `none`, or an unknown `REQ-nnn` or `CC-nn` fails the command and the log names the commit. With `other` the same findings are warnings and the exit status is `0`; a run that could not read its range still exits with `2`. A workflow from before this command exists gets the step when you run [`xaden project pin`]({{< relref "docs/reference/commands-project#xaden-project-pin" >}}).

The command works in a project that adopted Xaden.


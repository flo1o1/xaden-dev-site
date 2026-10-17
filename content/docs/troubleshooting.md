---
title: "Troubleshooting"
weight: 6
description: "Symptoms, causes and fixes, by area."
---

Find your symptom, read the cause, apply the fix. Exit codes are listed in [Exit codes and environment]({{< relref "docs/reference/exit-codes-and-environment" >}}).

## Install and PATH

### `xaden: command not found`

**Cause:** `~/.local/bin` is not on your `PATH`.
**Fix:** add `export PATH="$HOME/.local/bin:$PATH"` to `~/.bashrc` or `~/.zshrc` and open a new terminal. Check with `xaden version`.

### The installer says a file named `xaden` exists and is not this checkout's

**Cause:** another file or link of that name is in the folder. The installer never overwrites it.
**Fix:** remove or rename that file, then run `install.sh` again. To move the link to a newer zip extraction, run `--uninstall` from the old folder first ([Update Xaden]({{< relref "docs/admin-guide/update-xaden" >}})).

### The checks end with INCOMPLETE

**Cause:** a tool is missing: shellcheck, gitleaks or semgrep. A skipped check is never counted as passed.
**Fix:** install the tool ([Requirements and platforms]({{< relref "docs/admin-guide/requirements-and-platforms" >}})). CI and releases treat a missing tool as a failure.

### The messages show strange symbols

**Cause:** your terminal or log does not render the signs.
**Fix:** set `XADEN_PLAIN=1`.

## Creating and adopting

### `xaden adopt` says this is not a git repository

**Fix:** run it inside a clone, or run `git init` first.

### `xaden adopt` stopped after the plan and did not ask

**Cause:** there is no terminal (a script, a CI job, some editors). Nothing was changed.
**Fix:** run the command it prints, `xaden adopt --yes`, with the options you used.

### `xaden adopt` exits with code 4

**Cause:** your hook manager or CI system is not supported.
**Fix:** the message names the manual step. Adopt without that part with `--skip-hooks` or `--skip-ci`.

### The branch or the folder already exists

**Cause:** an earlier adoption left `chore/adopt-xaden` or `<repo>-adopt-xaden`.
**Fix:** finish it, or remove it with `git worktree remove <folder>` and `git branch -D chore/adopt-xaden`.

### `xaden create --autopilot` exits with code 2

**Cause:** the folder already holds code, a build file or history.
**Fix:** run `xaden adopt` inside it, or choose another name.

## Checks and modes

### A gap: no `test` check is configured

**Cause:** the repository has no test command that Xaden knows. In `strict` mode a gap is an error; otherwise it is a warning.
**Fix:** add `check.test = <command>` to `xaden/xaden.conf`, or add Xaden's preset: `xaden preset python` or `xaden preset node`.

### `xaden check` says `xaden/RULES.md` does not match

**Cause:** the rules file was edited by hand, or another Xaden version generated it.
**Fix:** run `xaden doctor` to see the versions. If they match, run `xaden rules` and commit the result.

### `xaden check` fails on a finding you did not cause

**Cause:** the finding is not in the baseline and is in a file your change touches (`changed-files`), or anywhere (`strict`).
**Fix:** fix it. If it existed before Xaden was adopted, ask the team whether it belongs in the baseline; letting a baseline grow is an approval point.

### A warning says baselined findings are fixed

**Cause:** findings in the baseline no longer occur, and this run could not shorten the file (CI, or the pre-commit hook).
**Fix:** run `xaden check` on your machine, not in CI, and commit the smaller baseline.

### A commit is rejected: unknown requirement, or a `feat` without `Refs:`

**Cause:** the commit cites a requirement that does not exist, or a `feat` commit has no `Refs: REQ-nnn` trailer.
**Fix:** look the requirement up with `xaden req list`, or create it with `xaden req new`. The trailer must be in the last paragraph of the message.

## Versions and downloads

### A command asks `Download and install Xaden <version> now?`

**Cause:** the project pins a Xaden version that is not installed on this machine.
**Fix:** read the version, source and checksum it shows. Answer `y` to install, or press Enter to decline.

### A commit in an IDE fails with exit code 3

**Cause:** the pinned Xaden version is missing, and the IDE has no terminal to ask you in. Nothing was downloaded.
**Fix:** run the `xaden fetch <version>` that the message shows, in a terminal.

### A download fails with exit code 5

**Cause:** the archive does not match the checksum in `xaden/xaden.conf`, or the checksum differs from the signed one. Nothing was installed.
**Fix:** do not work around it. Check the version number, and ask whoever pinned the version.

### A download fails with exit code 6

**Cause:** the signature of the release does not verify against the keys in `release-signers`. Nothing was installed.
**Fix:** treat it as an attack until proven otherwise. Compare the key in `release-signers` with the one published on this site ([Verify releases]({{< relref "docs/admin-guide/verify-releases" >}})).

### `xaden check` says this is one Xaden version and the project pins another

**Fix:** run `xaden doctor`, then `xaden fetch <version>` in a terminal.

## Hooks and CI

### The hooks do not run in a teammate's clone

**Cause:** hooks that live in `.git` are not shared. The same happens after `pre-commit install` rewrites the hook.
**Fix:** run `xaden setup` once in each clone.

### A hook prints `xaden not found`

**Cause:** the command is not on the `PATH` of the program that runs git (an IDE, for example). The check is skipped.
**Fix:** make `~/.local/bin` part of that program's `PATH`, or commit from a terminal. CI re-runs the checks either way.

### The CI job fails at "Install Xaden"

**Cause:** the downloaded Xaden does not match `XADEN_CHECKSUM` in `.github/workflows/xaden.yml`, or the version tag does not exist.
**Fix:** the version and checksum in the workflow must equal `version` and `checksum` in `xaden/xaden.conf`. `xaden upgrade` updates both.

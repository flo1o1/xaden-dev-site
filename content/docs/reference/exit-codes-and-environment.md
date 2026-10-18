---
title: "Exit codes and environment"
weight: 60
description: "What the exit codes mean, and which environment variables change Xaden's behavior."
---

## Exit codes

| Code | Meaning | Commands |
|------|---------|----------|
| 0 | Done, or every check passed. A run with skipped checks also exits 0 and ends with a warning, unless `--strict` is set. Declining a question also exits 0 where nothing was started. | all |
| 1 | A check failed, a question was answered with no, or the command hit an error. | all |
| 2 | The folder already holds code, a build file or history. | `create --autopilot`, `create` |
| 3 | Nothing was downloaded or looked up because nobody could be asked. The message names the command to run in a terminal. | `fetch`, `pin`, `upgrade`, any project command whose pinned version is missing |
| 4 | The hook manager or CI system is not supported. The message names the manual step. | `adopt` |
| 5 | A download does not match the pinned checksum. Nothing was installed. | `fetch`, `pin`, `upgrade` |
| 6 | The signature of a release does not verify, or `require-signature = true` is set and no signature can be verified. Nothing was installed. | `fetch`, `pin`, `upgrade` |

## Messages

Every message Xaden prints is one of four kinds.

| Kind | Sign | Plain text | Stream |
|------|------|-----------|--------|
| Question (waits for an answer) | 🐉 | `[?]` | output; the last line, after a separator line, with the default (`[y/N]`) |
| Warning (the run continues) | ⚠️ | `WARNING:` | error output |
| Error (the run stops) | 🔥 | `ERROR:` | error output, exit status 1 |
| Success | ✅ | `OK:` | output |

Only an explicit yes answers a question; anything else, including no answer, is no. Without a terminal nothing is asked.

## Environment variables

| Variable | Effect |
|----------|--------|
| `XADEN_PLAIN=1` | Plain text instead of signs. Plain text is also used when `CI` is set, when output is not a terminal, and without a UTF-8 locale. |
| `XADEN_HOME` | The parent folder of the installed versions. Default: `${XDG_DATA_HOME:-~/.local/share}/xaden`. |
| `XADEN_UPDATE_CHECK` | Overrides `update-check` from `xaden/xaden.conf` on this machine: `off`, or an interval such as `12h`, `1d`, `7d`. |
| `EVENT_NAME`, `BASE_REF`, `BEFORE_SHA` | Set by the CI workflow for the check step: `push` or `pull_request`, the target branch of a pull request, and the previous tip of a push. In `changed-files` mode they say which files the change touches; without them in CI the run checks all files. |
| `STRICT=1` | The same as `xaden check --strict`. |
| `XADEN_RELEASES_URL`, `XADEN_ASSETS_URL`, `XADEN_LATEST_URL` | Where releases, signatures and the newest-release answer come from, for mirrors. A download is still checked against the pinned checksum and the signature. |

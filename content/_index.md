---
title: "Xaden"
---

## What?

Xaden is a starter for AI-assisted coding. One command creates a project that already has the
rules, checks and requirement files an AI coding assistant needs to stay on track. It works with
Claude Code, Aider, Cline, Continue, Cursor, Codex, Copilot, ChatGPT and local models
([README](https://github.com/flo1o1/xaden/blob/v0.2.2/README.md)).

This is what creating a project looks like with Xaden 0.2.2 (the path is shortened):

```text
$ scripts/new-project.sh my-app
==> check mode: staged
==> requirements format
requirements OK (1)
==> documentation structure
docs OK (structure only; content not verified)
==> requirement traceability
traceability OK
==> shellcheck
==> secret scan (gitleaks)
==> SAST (semgrep, local rules)
==> workflows: actionlint
==> workflows: zizmor
No findings to report. Good job! (2 suppressed)
==> summary: 8 passed, 0 failed, skipped: none
==> all checks passed
==> created my-app at ~/code/my-app
Next: open the folder in your LLM tool, then run the 'kickoff' prompt (prompts/kickoff.md).
```

## So what?

Assistants invent rules, drift from what you asked for, skip checks and sometimes leak secrets.
Xaden answers with a few things you can verify:

- **One rule set for every assistant.** `AGENTS.md` holds the rules; Claude Code imports it and other
  tools get pointer files ([AGENTS.md](https://github.com/flo1o1/xaden/blob/v0.2.2/template/AGENTS.md)).
- **No invented rules or requirements.** Rules and requirements have numbers (`CC-nn`, `REQ-nnn`),
  and the commit hook rejects a commit that cites an unknown one
  ([Getting started]({{< relref "docs/getting-started" >}})).
- **Checks that do not depend on the assistant.** `scripts/check.sh` runs shellcheck, gitleaks for
  secrets, semgrep and the linters of your stack in a git hook and in CI
  ([Security checklist]({{< relref "docs/security" >}})).
- **Code traced to requirements.** Each requirement is a file written as a job to be done, with
  acceptance criteria that become tests; a requirement is only `done` when a test cites it
  ([template/AGENTS.md](https://github.com/flo1o1/xaden/blob/v0.2.2/template/AGENTS.md)).
- **A security review prompt** based on the OWASP Web Security Testing Guide that works with any
  model ([Security checklist]({{< relref "docs/security" >}})).

Xaden is not for you if you want a framework or a library: it generates no application code.
It is not for you if you work on native Windows without WSL, because the scripts are bash
([Getting started]({{< relref "docs/getting-started" >}})). And it asks you to approve requirements, so it
is a poor fit if you want the assistant to decide everything alone.

## Now what?

You need Linux or macOS, plus git, bash, awk, sed, tar, grep and cksum, which are normally already
installed. On Windows use WSL (recommended) or Git Bash; both are untested, and native PowerShell is
not supported. An AI coding tool is optional to start; Claude Code is recommended.

```bash
git clone https://github.com/flo1o1/xaden.git && cd xaden
scripts/new-project.sh my-app
```

[Read Getting started]({{< relref "docs/getting-started" >}}): the `xaden` command, kickoff, building
features and releasing.

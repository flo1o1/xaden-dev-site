Your repository keeps its build, its tests and its CI. Xaden is added beneath it in one pull request
that your team reviews. The example assumes your repository is `~/code/shop`.

```bash
cd ~/code/shop
xaden adopt
```

- `cd ~/code/shop`: goes to your repository.
- `xaden adopt`: reads the repository and reports its language, test and lint commands, CI, git hooks and existing `AGENTS.md`. Then it prints exactly which files it would create or touch and asks whether to apply the plan on a new branch. Nothing is written before you answer yes, and it asks before it downloads anything.

To look without being asked, add `--dry-run`: it stops after the plan. Without a terminal, in a script or a CI job, it stops there too and prints the command that applies the plan, `xaden adopt --yes`.

### What it adds

- A visible folder `xaden/` with your requirements, personas and security reviews as plain Markdown, plus one settings file that pins the Xaden version.
- A short marked block in `AGENTS.md` that points to the rules. Text you wrote there stays untouched. `CLAUDE.md` is created only if you use Claude Code.
- Hooks and CI checks next to the ones you already have. Your own test and lint commands are reused. If a tool is missing, Xaden offers a preset as a separate step and adds nothing unless you accept.

### Existing code never blocks you

Findings that are already there are recorded in a baseline that can only shrink. You choose how strict
the checks are: warn only, hold changed files to the rules, or hold everything.

### Check and teach the assistant

```bash
xaden check
```

- `xaden check`: runs all checks on the adopted project and ends with a summary of what passed, failed or was skipped.

Then start your assistant and run `/kickoff`. Describe what the project already does instead of a new
idea. It asks questions and writes the requirements, the threat model and the architecture notes, and
you approve them. Review what it writes, because it describes code you know better than it does.

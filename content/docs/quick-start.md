---
title: "Quick start"
weight: 1
---

From nothing to your first feature in a few commands. You need Linux or macOS with git and bash. On
Windows use WSL (untested). Details for every step are on the [Admins](/docs/admins/) and
[Developers](/docs/developers/) pages.

## 1. Install the xaden command

```bash
git clone https://github.com/flo1o1/xaden.git ~/.xaden
~/.xaden/scripts/install.sh
```

- `git clone ...`: downloads Xaden into the hidden folder `.xaden` in your home directory. Keep that folder, because the `xaden` command runs from it.
- `~/.xaden/scripts/install.sh`: creates one link, `~/.local/bin/xaden`, pointing into that folder. It changes nothing else and never replaces a different file of that name.

If `~/.local/bin` is not on your `PATH`, the script says so. Add this line to `~/.bashrc` (bash) or
`~/.zshrc` (zsh) and open a new terminal:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

This puts `~/.local/bin` in front of the folders your shell searches for commands, so it finds `xaden`.

## 2. Create a project

```bash
xaden create my-app
cd my-app
```

- `xaden create my-app`: creates the folder `my-app` in the current directory from Xaden's template (only files git tracks there), starts a git repository in it, switches on the git hooks and makes the first commit, on which the pre-commit checks run. If anything fails, it removes the half-created folder.
- `cd my-app`: moves your terminal into the new project.

## 3. Kick off

With Claude Code, start it in `my-app` and run:

```text
/kickoff <your idea>
```

With another tool, open the folder and ask it to follow `prompts/kickoff.md`. The assistant asks
questions and you approve the requirements and the stack.

## 4. Build a feature

```text
/feature <what users can do afterwards>
```

The assistant links the work to a requirement, writes the test first and runs the checks. Run them
yourself at any time, from anywhere inside the project:

```bash
xaden check
```

- `xaden check`: runs the project's static analysis (shellcheck, gitleaks for secrets, semgrep and the linters of your stack) and ends with a summary of what passed, failed or was skipped.

## 5. Release

```text
/release
```

The assistant proposes a version, you confirm, and the release is checked and tagged locally.

## Update

```bash
git -C ~/.xaden pull
xaden update
```

- `git -C ~/.xaden pull`: fetches the newest Xaden into the `~/.xaden` folder without leaving your project.
- `xaden update`: run inside your project, it only lists what the newer Xaden would change. Add `--apply` to stage those changes in git, and review them with `git diff --cached` before you commit.

---
title: "Quick start"
weight: 1
description: "From nothing to your first checked feature, in five steps."
---

By the end of this page you have a project whose first feature passed Xaden's checks. You need Linux or
macOS with git and bash. On Windows use WSL (untested). Already have a repository? Skip to
[Add Xaden to a repository]({{< relref "docs/developer-guide/add-xaden-to-a-repository" >}}). Every step links to the guide page with the details.

## 1. Install the xaden command

```bash
git clone https://github.com/flo1o1/xaden-dev.git ~/.xaden
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
Check it with `xaden version`; it prints the installed version. Details: [Install Xaden]({{< relref "docs/admin-guide/install-xaden" >}}).

## 2. Create your project

```bash
xaden create my-app
cd my-app
```

- `xaden create my-app`: creates the folder `my-app` in the current directory with its own git repository, the folder `xaden/` for requirements and rules, git hooks that run the checks, a CI workflow, and a first commit. If anything fails, it removes the half-created folder.
- `cd my-app`: moves your terminal into the new project.

Want the recommended checks for a stack without choosing each tool? Use `xaden create --autopilot --stack python my-app`
(or `--stack node`). It prints one plan and asks once. Details: [Create a project]({{< relref "docs/developer-guide/create-a-project" >}}).

## 3. Tell your assistant what to build

Open your assistant in `my-app`. Choose it in the list under the page title (Claude Code, ChatGPT Codex, GitHub Copilot, Mistral Vibe or Other); this page and the guides then show the commands for your tool. Start with:

{{< prompt "xaden-kickoff" "kickoff" "My idea" "<your idea>" >}}

The assistant asks questions. You approve the requirements, the stack and the threat model. Then it builds a minimal
skeleton that runs. Details: [Kick off with your assistant]({{< relref "docs/developer-guide/kick-off-with-your-assistant" >}}).

## 4. Build your first feature

{{< prompt "xaden-feature" "feature" "Feature" "<what users can do afterwards>" >}}

The assistant links the work to a requirement, writes the test first, runs the checks and commits. Run
the checks yourself at any time, from anywhere inside the project:

```bash
xaden check
```

- `xaden check`: runs the project's checks and ends with a summary of what passed, failed or was skipped.

A run that skipped a check ends with a warning, not a success sign. Install the missing tool and run it again.
Details: [Build features]({{< relref "docs/developer-guide/build-features" >}}).

## 5. Release when you decide to

```bash
xaden release minor
```

- `xaden release minor`: checks everything, stamps the version and the changelog, and tags locally. It never pushes. You push when you are ready.

Details: [Release a version]({{< relref "docs/developer-guide/release-a-version" >}}).

## Where to go next

- Stuck on a step? See [Troubleshooting]({{< relref "docs/troubleshooting" >}}).
- Using a chat window or a local model? See [Other assistants and local models]({{< relref "docs/developer-guide/other-assistants-and-local-models" >}}).
- Working in a team? Read [Pin one Xaden version per project]({{< relref "docs/admin-guide/pin-one-version-per-project" >}}).
- Updating Xaden later? See [Update Xaden]({{< relref "docs/admin-guide/update-xaden" >}}).

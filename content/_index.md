---
title: "Xaden"
description: "Xaden is an open source starter that keeps AI coding assistants within rules, checks and requirements."
hero:
  eyebrow: "Open source · MIT"
  title: "Your AI writes fast. Xaden keeps it honest."
  lead: "One command creates a project with the rules, checks and requirements every AI assistant follows."
  command: |-
    git clone https://github.com/flo1o1/xaden.git ~/.xaden &&
    ~/.xaden/scripts/install.sh &&
    export PATH="$HOME/.local/bin:$PATH" &&
    xaden create my-app
  note: "This downloads Xaden into ~/.xaden, links the xaden command into ~/.local/bin, makes that folder available in this terminal and creates the project my-app in the current folder. Linux and macOS; on Windows use WSL."
  primary: "Quick start"
  secondary: "View on GitHub"
benefits:
  - name: "The Code"
    title: "One rule set"
    text: "Claude Code, Aider, Cline, Cursor, Codex or a local model: all read the same rules."
    link: "/docs/developers#create-your-project"
  - name: "The Trial"
    title: "Checks nobody skips"
    text: "shellcheck, gitleaks, semgrep and your linters run in a git hook and in CI."
    link: "/docs/security#on-every-commit-and-in-ci-automatic-checks"
  - name: "The Ledger"
    title: "Requirements first"
    text: "Every feature traces to a numbered requirement and a test."
    link: "/docs/developers#build-features"
  - name: "The Watch"
    title: "Security review built in"
    text: "An OWASP-based review prompt that works with any model."
    link: "/docs/security#before-a-release-a-security-review"
steps_title: "From zero to first feature"
steps:
  - title: "Copy and run"
    text: "Clone Xaden and create your project in one command."
  - title: "Kick off"
    text: "Tell your assistant your idea. It asks, you approve the requirements."
  - title: "Build and release"
    text: "Feature by feature, checked on every commit, tagged with SemVer."
roles_title: "Pick your path"
roles:
  - name: "Admins"
    title: "Set up, update, secure"
    text: "Prerequisites, the xaden command, updates and security."
    link: "/docs/admins"
  - name: "Developers"
    title: "Build with it"
    text: "Create a project, build features, release, join a project."
    link: "/docs/developers"
---

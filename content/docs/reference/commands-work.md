---
title: "Work commands"
weight: 20
description: "prompt, context and doc."
---

Commands for daily work inside a project. Run them from any folder below the project's top. In a project that adopted Xaden they run the
installed Xaden version that `xaden/xaden.conf` pins.

## `xaden prompt`

Prints a task prompt for your assistant to follow.

```text
xaden prompt <name>
```

`<name>` is one of `kickoff`, `feature`, `bugfix`, `refactor`, `code-review`, `security-review`, `release`, `requirements-update`, `persona`
or `documentation`. A file of the same name in `xaden/prompts/` replaces the default. An unknown name is an error.

Guide: [Build features]({{< relref "docs/developer-guide/build-features" >}}).

## `xaden context`

Prints the rule IDs, the number of requirements by status, and the `CONTEXT CHECK` fingerprint that an assistant quotes in its first reply.

```text
xaden context
```

## `xaden doc`

Prints a guide that Xaden ships.

```text
xaden doc <clean-code|security|optional-tools|local-llm|rules-<topic>>
```

`rules-<topic>` prints one section of the rules that moved out of the always-loaded rules file: `rules-checks`, `rules-docs`, `rules-findings`, `rules-git`, `rules-requirements`, `rules-security` or `rules-working-style`. `xaden/RULES.md` names the one to read before a task; a classic project has the same text in `docs/rules/`.


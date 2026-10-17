---
id: REQ-022
type: job
epic: experience
priority: should
status: approved
updated: 2026-10-17
---

# Developers see the commands of their own assistant

## Job

When I read the docs with my own AI coding assistant, I want to pick it once and see the commands that work in it on every page, so I do not have to translate `/feature` or `xaden prompt feature` to my tool myself.

## Acceptance criteria

- Given a docs page with commands that differ per assistant, when it is opened with JavaScript, then a picker under the title offers Claude Code, ChatGPT Codex, GitHub Copilot, Mistral Vibe and Other, and the page shows only the commands of the chosen one
- Given nothing was chosen, or JavaScript is off, then the page shows the Claude Code commands and no picker
- Given the choice "Other", then the page shows the `xaden prompt <name>` commands
- Given a choice, when another docs page is opened later in the same browser, then that page shows the same assistant (kept in the browser's `localStorage`, never sent anywhere)
- Given a link that ends in `#assistant=chatgpt-codex` (or claude-code, github-copilot, mistral-vibe, other), when it is opened, then the page shows that assistant, and the choice is kept
- Given ChatGPT Codex, GitHub Copilot or Mistral Vibe, then the command is followed by a note that the project needs their command files, and how to get them (`--assistants`, `xaden adopt`)
- Given the pages generated from the Xaden release, then `scripts/sync-docs.sh` turns the per-assistant commands of the guides into the same blocks, and fails when a known place no longer matches (the guides changed their wording)
- Given the site check, then it fails when a page that offers the picker lacks the commands of one assistant, or when the build holds an inline script or another origin (REQ-011, REQ-012)
- Given the Quick start, then its steps 3 and 4 use the picker

## Notes

- Raw HTML stays off (REQ-006); the blocks come from Hugo shortcodes written by the site.
- The choice is a preference of the visitor, no personal data. Privacy notice and threat model say so.

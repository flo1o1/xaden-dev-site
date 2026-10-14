---
id: REQ-018
type: job
epic: visitor-journey
priority: should
status: approved
updated: 2026-10-13
---

# Visitors can try Xaden by copying one command

## Job

When I am curious about Xaden and have a terminal open, I want to copy one command from the home page and run it, so I can see a working Xaden project within a minute without reading documentation first.

## Acceptance criteria

- Given the home page, then the first screen shows one command with a copy button, and the command installs the `xaden` command from a fresh clone and creates a project with `xaden create`
- Given the copy button, when pressed, then the command is on the clipboard and the button says so
- Given JavaScript disabled, then the command is still shown and can be selected and copied by hand
- Given every code block on the docs pages, then it has a copy button too
- Given the home page, then it carries no more text than a hero, four short benefit blocks, three steps and two entry points to the docs
- Given the hero button "Quick start", when followed, then it opens a Quick start page that leads from the clone to the first feature in a few commands, each with a copy button, and links to the Admins and Developers pages for details
- Given any shell code block on the site, then it holds only commands, with no comments, so a copied block can be pasted into a terminal as is, and what each command does is explained in the text next to the block
- Given the pages the site writes itself (home, Quick start), then they use the `xaden` command, not the `scripts/*.sh` paths

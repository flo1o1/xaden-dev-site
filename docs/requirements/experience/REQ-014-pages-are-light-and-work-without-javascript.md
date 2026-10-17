---
id: REQ-014
type: quality
epic: experience
priority: should
status: approved
updated: 2026-10-13
---

# Pages are light and work without JavaScript

## Quality goal

Every page works with JavaScript disabled, and scripts are optional enhancements only (the copy buttons, the pointer shadows and the assistant picker; without JavaScript the docs show the Claude Code commands, REQ-022), and the home page transfers at most 250 KB including fonts and logo (raised from 100 KB when the Empyrean design added fonts and the logo)

## Acceptance criteria

- Given JavaScript disabled, when any page is opened, then all content and navigation work
- Given the home page, when loaded with an empty cache, then no more than 250 KB are transferred

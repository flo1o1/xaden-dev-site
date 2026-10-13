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

Every page works with JavaScript disabled, and the home page transfers at most 100 KB (threshold proposed; confirm after the first build).

## Acceptance criteria

- Given JavaScript disabled, when any page is opened, then all content and navigation work
- Given the home page, when loaded with an empty cache, then no more than 100 KB are transferred

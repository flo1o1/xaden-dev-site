---
id: REQ-011
type: quality
epic: trust
priority: must
status: approved
updated: 2026-10-13
---

# The site sets no cookies and makes no third-party requests

## Quality goal

Visiting any page sets zero cookies, loads zero resources from another origin and uses no analytics; outbound links are plain links on an allow-list.

## Acceptance criteria

- Given the built site, when scanned, then it contains no reference to another origin except allow-listed plain links, and CI fails otherwise
- Given any page loaded in a browser, then no cookie or local storage entry is created
- Given the fonts, then they are served from the site itself

---
id: REQ-006
type: job
epic: delivery
priority: must
status: approved
updated: 2026-10-13
---

# Documentation on the site always matches the latest released Xaden

## Job

When I publish a Xaden release, I want to rebuild the site from that release's documentation, so I can be sure visitors never read outdated instructions.

## Acceptance criteria

- Given a new Xaden release, when it is published, then a site build starts and renders the docs from the release tarball
- Given the built site, then every docs page shows the Xaden version and the build date
- Given a missing or unreadable source file, when the build runs, then the build fails and nothing is published
- Given unreleased changes in the Xaden repository, then they never appear on the site

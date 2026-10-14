---
id: REQ-006
type: job
epic: delivery
priority: must
status: in-progress
updated: 2026-10-13
---

# Documentation on the site always matches the latest released Xaden

## Job

When I publish a Xaden release, I want to rebuild the site from that release's documentation, so I can be sure visitors never read outdated instructions.

## Acceptance criteria

- Given a new Xaden release, when it is published, then the pinned version in `XADEN_DOCS_VERSION` is bumped by a reviewed change and the build renders the docs from that release's tarball
- Given a new Xaden release tag, then within 24 hours a pull request that bumps `XADEN_DOCS_VERSION` is open without anyone starting a job by hand, and a person merges it after CI passed
- Given the built site, then every docs page shows the Xaden version and the release date (not the build date, so builds stay reproducible, REQ-008)
- Given a missing or unreadable source file, when the build runs, then the build fails and nothing is published
- Given unreleased changes in the Xaden repository, then they never appear on the site
- Given a maintainer with a local Xaden checkout, when they run `XADEN_SOURCE=<checkout> scripts/sync-docs.sh`, then the docs of that checkout render into the git-ignored `content/docs/` for a local preview and the run says so
- Given `CI` is set, when `XADEN_SOURCE` is set, then `scripts/sync-docs.sh` refuses to run, so a deployed build always renders a release tarball
- Given a path that is not a Xaden checkout, when `XADEN_SOURCE` names it, then `scripts/sync-docs.sh` fails and renders nothing

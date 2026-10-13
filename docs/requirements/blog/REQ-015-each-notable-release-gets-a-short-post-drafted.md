---
id: REQ-015
type: job
epic: blog
priority: could
status: approved
updated: 2026-10-13
---

# Each notable release gets a short post drafted from the changelog (second step)

## Job

When I release a minor or major version, or a significant patch, I want to get a post drafted from the changelog entry, so I can tell readers what changed without writing it from scratch.

## Acceptance criteria

- Given a minor or major release, when it is published, then a draft post is generated from the CHANGELOG.md entry by a template, without an LLM
- Given the draft, then it contains what changed, why it matters, upgrade steps with breaking changes first, and a link to CHANGELOG.md in the Xaden repository
- Given a patch release, then a draft is generated only when the release is marked significant
- Given a generated draft, then it arrives as a reviewable commit and is never published without review

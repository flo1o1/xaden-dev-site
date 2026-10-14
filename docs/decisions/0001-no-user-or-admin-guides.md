# 0001. No user guide and no admin guide

- Status: accepted
- Date: 2026-10-14
- Requirements: REQ-002, REQ-006

## Context

The Xaden scaffold gives every project `docs/user-guide.md` and `docs/admin-guide.md`, and its checks
expect them. This project is a static website. Its visitors need no user guide beyond the site itself,
and there is no service to administer: no process, database or port. The two guides were unfilled
templates describing things that do not exist.

## Decision

The project has neither guide. How to build and run the site is in `README.md`, the security side is in
`SECURITY.md` and `docs/threat-model.md`, and the site content is the user documentation. This file is the
opt-out marker: while it exists, `scripts/check-docs.sh` skips the guide checks and `scripts/release.sh`
skips stamping the guides.

## Consequences

- `scripts/check-docs.sh`, `scripts/release.sh` and `AGENTS.md` section 8 differ from the scaffold's
  versions. A scaffold update will report conflicts in those files; keep these changes.
- `SECURITY.md` and `docs/threat-model.md` stay checked for unfilled TODO markers.
- To bring the guides back, restore them from the scaffold template and delete this file.

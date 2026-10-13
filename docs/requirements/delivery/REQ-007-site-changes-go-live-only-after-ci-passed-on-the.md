---
id: REQ-007
type: job
epic: delivery
priority: must
status: in-progress
updated: 2026-10-13
---

# Site changes go live only after CI passed on the exact commit

## Job

When I change the site, I want to deploy only from a green commit on main, so I can be sure a broken page never reaches visitors.

## Acceptance criteria

- Given a commit on main, when CI has not passed on it, then it is not deployed and the push is rejected by the main-branch ruleset
- Given the deploy job, then its token has only the permissions it needs
- Given the deployed site, then it is served at xaden.dev with HTTPS enforced

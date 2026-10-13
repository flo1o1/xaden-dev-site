---
id: REQ-012
type: quality
epic: trust
priority: must
status: in-progress
updated: 2026-10-13
---

# The site is hardened as far as GitHub Pages allows, and says where it is not

## Quality goal

Every page carries a strict Content-Security-Policy (as a meta tag, because GitHub Pages cannot set response headers) and no inline script; header-only protections that are unavailable are named in the threat model.

## Acceptance criteria

- Given any page, then it has a Content-Security-Policy meta tag that forbids inline script and non-self origins
- Given the built site, when scanned, then it contains no inline script
- Given the threat model of the site repository, then it lists the missing header protections (for example frame-ancestors, Permissions-Policy) as accepted limits
- Given the site dependencies (Hugo, theme), then they follow the dependency policy of the Xaden template

---
id: REQ-009
type: job
epic: trust
priority: must
status: approved
updated: 2026-10-13
---

# Security researchers find a standard contact for vulnerability reports

## Job

When I find a vulnerability in Xaden or its site, I want a standard machine-readable contact, so I can report it privately.

## Acceptance criteria

- Given /.well-known/security.txt, then it follows RFC 9116 with Contact, Expires, Canonical, Policy (the scaffold's SECURITY.md) and Preferred-Languages: en
- Given the Expires field, then it is at most one year ahead, and the build fails when fewer than 60 days remain
- Given the Contact field, then it matches the address on the About page

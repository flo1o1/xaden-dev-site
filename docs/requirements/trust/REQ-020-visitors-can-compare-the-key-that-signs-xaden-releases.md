---
id: REQ-020
type: job
epic: trust
priority: should
status: approved
updated: 2026-10-16
---

# Visitors can compare the key that signs Xaden releases

## Job

When I verify a Xaden release, I want the public signing key and its fingerprint on the official site, so I can compare it with the key shipped in the download and spot a swapped one.

## Acceptance criteria

- Given the About page, then it shows the public release signing key (type, key, label) and its SHA256 fingerprint
- Given the key, then it is identical to the line in `release-signers` of the Xaden repository
- Given a key change, then the page and the repository change in the same release

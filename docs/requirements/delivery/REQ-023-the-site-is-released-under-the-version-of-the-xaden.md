---
id: REQ-023
type: job
epic: delivery
priority: must
status: approved
updated: 2026-10-17
---

# The site is published from a version tag that matches the Xaden release, and a fix can be published again

## Job

When I release Xaden, or need to fix something on the site, I want the site to be published only from a version tag, so I can release it together with Xaden and still correct a typo without a new Xaden version.

## Acceptance criteria

- Given the file `VERSION`, then it holds `X.Y.Z` (the Xaden release the docs describe) or `X.Y.Z-NNNN` (a re-publish with a four-digit sequence), and `scripts/sync-docs.sh` renders the docs of the Xaden tag `vX.Y.Z`
- Given `scripts/release-site.sh X.Y.Z` on a branch, when the Xaden tag `vX.Y.Z` exists on GitHub and `X.Y.Z` is higher than the current version, then it sets `VERSION`, stamps the `Unreleased` changelog section, renders the docs and makes one commit, and it never pushes or tags
- Given `scripts/release-site.sh republish`, then `VERSION` gets the next sequence of the current Xaden version (`0.4.0` becomes `0.4.0-0001`, `0.4.0-0001` becomes `0.4.0-0002`) with the same stamp and commit
- Given a pushed tag `vX.Y.Z` or `vX.Y.Z-NNNN`, when its commit is on `main`, the tag equals `v` plus `VERSION` and it is the highest tag (compared by X, Y, Z, then the sequence, with no sequence lowest), then CI checks the site and the `deploy` job publishes it
- Given a tag that is not the highest, whose commit is not on `main`, or that differs from `VERSION`, then the deploy fails and nothing is published
- Given a push to `main` or a pull request, then nothing is deployed
- Given the `github-pages` environment, then it accepts deployments from tags `v*` only
- Given the repository, then it has no scheduled workflow that opens documentation pull requests and no `DOCS_BUMP_TOKEN` secret

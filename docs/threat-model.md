# xaden-dev-site — Threat model

Read before every security-relevant change, and updated when a change adds an entry point, a data type,
a dependency on an external service or a new deployment target. Keep it short and true;
"unknown" is a valid answer that the user must resolve.

**Last reviewed:** 2026-10-14, first version, written for the launch of https://xaden.dev.

## System summary

A static website (Hugo) for the open source project Xaden: a home page, documentation rendered from
a Xaden release, About, imprint and privacy notice. Visitors are developers who read the pages and copy
install commands into a terminal. It is built by GitHub Actions and served by GitHub Pages at
https://xaden.dev. There is no server code, database, login, form or comment function.

## Assets

- **Integrity of the pages**, above all the install commands: a visitor copies them into a terminal,
  so a tampered command is a compromise of that visitor's machine.
- **Control of the domain `xaden.dev`**, the GitHub repository and the deployment.
- **Reputation** of the project and its owner.
- Availability matters little: the site is documentation, and the sources live on GitHub.

## Sensitive data

- The site stores no personal data. Visitor IP addresses are processed by GitHub Pages as the host
  (see the privacy notice); the owner has no access to them.
- Messages sent to hello@xaden.dev sit in the mailbox at Netcup (sender address and content). They are
  used only to answer and deleted when the matter is closed.
- No credentials are stored in the repository. The only repository secret is listed in `SECURITY.md`.

## Entry points

- Visitors request static files over HTTPS. There are no parameters, forms or uploads.
- Pull requests and pushes to the repository (changes to the site code and content).
- The Xaden release archive that `scripts/sync-docs.sh` downloads and renders into the documentation.
- The daily `bump-docs` workflow, which opens a pull request when a newer Xaden release exists.
- Email to hello@xaden.dev.

## Trust boundaries

- Xaden release archive (text the site did not write) to the built pages. Raw HTML in Markdown is
  switched off, and the site check fails on inline scripts, foreign origins and internal references.
- A pull request to `main`. The ruleset on `main` requires the `check` job to pass, and only a person
  merges.
- GitHub Actions to GitHub Pages. Only the deploy job holds the Pages permissions.
- DNS at Netcup to visitors: whoever controls the records controls what `xaden.dev` serves.

## Attackers and capabilities

- **Anonymous visitor**: can only read static files. There is nothing to log in to or submit.
- **Author of a pull request**: could propose malicious content or workflow changes. Nothing reaches
  `main` without passing CI and being merged by the owner.
- **Compromised upstream or CI dependency** (the Xaden release, an action, Hugo, Tailwind): could inject
  content or code at build time.
- **Attacker with access to the owner's GitHub or Netcup account**: could change the site or the DNS.
- **Network attacker**: could try to alter pages in transit; HTTPS is enforced.

## Deployment assumptions

- Hosting is GitHub Pages with the Actions source. GitHub terminates TLS and serves the files from its
  CDN. HTTPS is enforced and the certificate is issued by GitHub.
- DNS and the mailbox are at Netcup. The domain is not yet verified in the GitHub account, which would
  stop another GitHub user from claiming `xaden.dev` if the Pages site were ever removed.
- Nobody has shell access to a server, because there is none. Secrets are held by GitHub and listed in
  `SECURITY.md`. There are no backups beyond the git history.
- The GitHub Pages response headers cannot be changed (see Accepted risks).

## Security baseline

Verification standard: OWASP ASVS (what to build), OWASP WSTG (how to test it).

- ASVS level: L1: public static content, no accounts and no sensitive data.
- Not applicable areas: no logins, sessions, access control, forms, uploads, database, API or server-side code, so authentication, session, CSRF, injection and file-handling requirements do not apply. What remains is transport security, content security policy, dependency and build integrity, and privacy.

## Threats and mitigations

| Threat | Asset | Mitigation | Requirement / test |
|--------|-------|------------|--------------------|
| A visitor copies a tampered install command | Visitors' machines, reputation | `main` accepts only commits that passed CI; only the deploy job publishes and only from `main`; commands point to github.com/flo1o1/xaden; the owner reviews every pull request | REQ-007; ruleset on `main` |
| Hostile or broken text in a Xaden release is rendered into the docs | Integrity of the pages | Raw HTML is off; version bumps arrive as a pull request that renders and checks the new docs; the check fails on inline script, foreign origins, rule IDs and script paths | REQ-006, REQ-012; `scripts/check-site.sh` |
| A page loads something from another site or tracks visitors | Visitor privacy | Policy `default-src 'none'` with only same-origin script, style, font and image; fonts self-hosted; the check fails on any other origin | REQ-011; `scripts/check-site.sh` |
| Script injection into a page | Visitors | No user input exists; `script-src 'self'` forbids inline script; the check fails on an inline script or event handler | REQ-012; `scripts/check-site.sh` |
| A compromised GitHub Action, Hugo or Tailwind build | Integrity of the pages | Actions pinned by commit hash; Hugo and Tailwind pinned with checksums; deploy job has only the Pages permissions; actionlint and zizmor run on the workflows | REQ-008; `scripts/check.sh` |
| The docs token leaks | Repository content | Fine-grained token for this repository only; it can only open pull requests, which a person merges | `SECURITY.md` |
| DNS or registrar account is taken over | Control of `xaden.dev` | Owner keeps the Netcup account secure; GitHub domain verification is still to do | Accepted risk below |
| The reporting contact stops working | Vulnerability reports | `security.txt` has an expiry date and the build fails when it is less than 60 days away | REQ-009; `scripts/check-site.sh` |

## Accepted risks

Accepted by the owner (Florian Auer), 2026-10-14:

- **Missing response headers.** GitHub Pages does not let the site set headers. Checked on
  2026-10-14, the responses carry none of these: `Strict-Transport-Security`, `X-Content-Type-Options`,
  `X-Frame-Options` or a CSP `frame-ancestors`, `Referrer-Policy`, `Permissions-Policy`. The
  Content-Security-Policy is a `<meta>` tag, which cannot express `frame-ancestors`, `sandbox` or
  `report-uri`. Consequences: the site could be framed by another site (it has no state-changing
  actions to abuse), and a first visit over plain HTTP is only protected by GitHub's redirect.
  GitHub also adds `Access-Control-Allow-Origin: *`, which is harmless for public static files.
  Moving to a host that sets headers would remove this risk.
- **Domain not yet verified in GitHub.** Until it is, a takeover after an accidental removal of the
  Pages site is possible. To do: verify `xaden.dev` in the GitHub account settings.
- **One person.** The owner is the only maintainer, reviewer and incident contact.

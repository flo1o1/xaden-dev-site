# Security policy — xaden-dev-site

## Supported versions

Only the site as published at https://xaden.dev (the latest commit on `main`). There are no older versions to patch.

## Reporting a vulnerability

Please do **not** open a public issue for security problems.

- Contact: [hello@xaden.dev](mailto:hello@xaden.dev). The same address is in <https://xaden.dev/.well-known/security.txt>.
- Include: affected version, steps to reproduce, impact, and whether it is already public.
- Response: you get an acknowledgement within 7 days, and an update when the problem is confirmed
  and again when it is fixed. This is a one-person open source project, so there is no 24/7 cover.

We credit reporters in the changelog unless they prefer to stay anonymous.

## Secret rotation

When a secret (API key, password, token, signing key, certificate) may have leaked —
committed to git, printed in a log, sent to a third party, or held by someone who left:

1. Create a new secret in the issuing system; deploy it; confirm the software works with it.
2. Revoke the old secret. Removing it from git history is not enough: assume it is known.
3. Check the issuing system's logs for use of the old secret since the suspected leak.
4. Record what happened, when, and what was rotated (see incident response below).

The site is static and holds almost no secrets. All of them are rotated by the owner:

| Secret | Where it is issued | What it can do |
|--------|--------------------|----------------|
| `DOCS_BUMP_TOKEN` (repository secret) | GitHub, fine-grained token for this repository only (Contents and Pull requests read/write) | Lets the daily docs workflow open a pull request. A person still has to merge it. |
| `GITHUB_TOKEN` of a workflow run | GitHub, created per run | Short-lived. Only the deploy job may write to Pages. |
| GitHub account of the owner | GitHub | Can change the repository, its settings and the deployment. |
| Netcup account of the owner | Netcup | Controls the DNS records and the mailbox of `xaden.dev`. |

## Incident response basics

1. **Contain**: revoke exposed credentials, disable the affected feature or take the service
   offline if data is at risk.
2. **Preserve evidence**: keep logs and affected systems unchanged where possible; note times.
3. **Assess**: which data and users are affected, since when, by which entry point.
4. **Fix**: regression test first, then the fix; run the security review; release.
5. **Notify**: affected users and, where the law requires it, authorities within the legal
   deadline (e.g. GDPR: 72 hours for personal-data breaches).
6. **Learn**: add a requirement, test or semgrep rule so the same mistake is caught next time;
   update `docs/threat-model.md`.

The owner, Florian Auer, decides and is the contact: [hello@xaden.dev](mailto:hello@xaden.dev). If the site itself
is the problem, the fastest way to contain it is to disable the Pages deployment in the repository
settings (Settings, Pages, unpublish) and to revert the last commit on `main`.

## Supply chain

Dependency rules, accepted vulnerabilities and optional SBOM/provenance guidance:
`docs/security.md` (section Dependencies) and `docs/security-exceptions.md`.

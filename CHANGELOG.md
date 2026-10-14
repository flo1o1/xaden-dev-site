# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) · Versioning: [SemVer](https://semver.org/).

## [Unreleased]

### Added
- A daily workflow (`bump-docs.yml`, also startable by hand) opens a pull request that moves `XADEN_DOCS_VERSION` to the newest Xaden release tag; CI checks it and you merge it. It needs the repository secret `DOCS_BUMP_TOKEN`.
- `scripts/sync-docs.sh` renders Getting started, Security, Optional tools and Local LLM into the docs from the Xaden release in `XADEN_DOCS_VERSION` (pinned, v0.2.2); each page shows the version and release date; CI runs it before the build.
- Project created from the Xaden scaffold.
- Hugo site skeleton with the Nightfall theme (dark, no JavaScript, self-hosted fonts), pages Home, Docs and About, a 404 page and `security.txt`; `scripts/check-site.sh` builds it and fails on other origins, inline script, a missing Content-Security-Policy or a `security.txt` that expires within 60 days; CI installs pinned, checksum-verified Hugo and Dart Sass.

# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) · Versioning: [SemVer](https://semver.org/).

## [Unreleased]

### Added
- `scripts/sync-docs.sh` renders Getting started, Security, Optional tools and Local LLM into the docs from the Xaden release in `XADEN_DOCS_VERSION` (pinned, v0.2.2); each page shows the version and release date; CI runs it before the build.
- Site content: Home (What, So what, Now what with real output of `new-project.sh`), docs landing page by task, About, imprint, privacy notice, a 404 page with links, and a footer with imprint, privacy and contact.
- Redesign: short home page (hero with a copyable one-line install, four benefit blocks, three steps), docs split by role into Admins and Developers with a sidebar, one page per task (`scripts/sync-docs.sh` splits Getting started), copy buttons on every code block, the logo in the header, favicon and hero, colors taken from the logo, dark fantasy artwork. `scripts/build-css.sh` builds the stylesheet.
- Project created from the Xaden scaffold.
- Hugo site skeleton with its own theme `themes/xaden` (dark, self-hosted fonts, one optional script for copy buttons), pages Home, Docs and About, a 404 page and `security.txt`; `scripts/check-site.sh` builds it and fails on other origins, inline script, a missing Content-Security-Policy or a `security.txt` that expires within 60 days; CI installs pinned, checksum-verified Hugo and Tailwind CSS CLI.

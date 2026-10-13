# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) · Versioning: [SemVer](https://semver.org/).

## [Unreleased]

### Added
- `scripts/sync-docs.sh` renders Getting started, Security, Optional tools and Local LLM into the two role pages from the Xaden release in `XADEN_DOCS_VERSION` (pinned, v0.2.2); each page shows the version and release date; CI runs it before the build.
- Site content: Home (What, So what, Now what with real output of `new-project.sh`), docs landing page by task, About, imprint, privacy notice, a 404 page with links, and a footer with imprint, privacy and contact.
- Redesign: short home page (hero with a copyable one-line install, four benefit blocks, three steps), docs as one page each for Admins and Developers with a table of contents (`scripts/sync-docs.sh` splits Getting started into their sections), copy buttons on every code block, the logo in the header, favicon and hero, colors taken from the SVG logo, dark fantasy artwork with large overlapping dragon scales in the hero, on the logo side only, so text always sits on a plain background. `scripts/build-css.sh` builds the stylesheet.
- Docs menu with Quick start, Admins and Developers; a hand-written Quick start page that uses the `xaden` command and explains every command below its code block; code blocks hold commands only (comments from the Xaden docs move into a list under the block); the "Edit on GitHub" links are gone; rule IDs, section references and repository paths are removed from the docs, and the site check fails if one comes back.
- Project created from the Xaden scaffold.
- Hugo site skeleton with its own theme `themes/xaden` (dark, self-hosted fonts, one optional script for copy buttons), pages Home, Docs and About, a 404 page and `security.txt`; `scripts/check-site.sh` builds it and fails on other origins, inline script, a missing Content-Security-Policy or a `security.txt` that expires within 60 days; CI installs pinned, checksum-verified Hugo and Tailwind CSS CLI.

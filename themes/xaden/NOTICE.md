# Xaden theme

Layout structure and Tailwind approach derived from Hugoplate v3.5.1 (https://github.com/zeon-studio/hugoplate,
MIT, commit 2f5a454ee708f5f2666414af9ef48df65570752a, see LICENSE.hugoplate). Everything that
needs a third party at build or view time was removed on purpose (REQ-011, REQ-012, REQ-014):
the 25 Hugo modules, Google Fonts, analytics, search, PWA, cookie consent and the theme switcher.

Fonts (SIL Open Font License 1.1), self-hosted from the npm packages @fontsource/cinzel 5.3.0
and @fontsource-variable/inter (latest on 2026-10-13): static/fonts/.
The logo is the Xaden logo (static/img/xaden.png, favicon and touch icon are resized copies).
The CSS is built by Hugo with the standalone Tailwind CSS CLI (see .github/workflows/ci.yml for the pinned version).

# Xaden theme

Layout structure and Tailwind approach derived from Hugoplate v3.5.1 (https://github.com/zeon-studio/hugoplate,
MIT, commit 2f5a454ee708f5f2666414af9ef48df65570752a, see LICENSE.hugoplate). Everything that
needs a third party at build or view time was removed on purpose (REQ-011, REQ-012, REQ-014):
the 25 Hugo modules, Google Fonts, analytics, search, PWA, cookie consent and the theme switcher.

Fonts (SIL Open Font License 1.1), self-hosted from the npm packages @fontsource/cinzel 5.3.0
and @fontsource-variable/inter 5.3.0: static/fonts/. The OFL text and copyright lines of both packages are
served next to the fonts (static/fonts/LICENSE-cinzel.txt, LICENSE-inter.txt) and credited on /about/credits/.
The logo is the Xaden logo (static/img/xaden.png; favicon and touch icon are PNG renderings of it).
The CSS is built by Hugo with the standalone Tailwind CSS CLI (see .github/workflows/ci.yml for the pinned version).

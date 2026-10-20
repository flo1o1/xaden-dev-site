---
title: "Credits and licenses"
description: "The tools Xaden runs, the works it builds on, what this site is built with, and their licenses."
---

Xaden was built with the help of an AI assistant, which is why a tool of this size came together so fast. What such an assistant knows,
it knows from people: the authors of open-source code and its documentation, the writers of books, articles, tutorials and standards,
everyone who answered a question in a forum or reported and fixed a bug in the open, and the teachers who explained it first. Most of them
are not named anywhere and did not know their work would end up here. Their knowledge is in every part of Xaden. Thank you.

Xaden stands on other people's work. This page names it, links to it and states the license, so you can see what you depend on and who
made it. Licenses are read from each project's own repository; they can differ between versions, and the license of the version you
install applies. This is a factual list, not legal advice.

## Tools Xaden runs

Xaden bundles none of these. You or the CI workflow that `xaden project adopt` writes install them, and Xaden only starts them as separate
programs and reads their output. Each entry reads: name, license.

### Security and review

- [ShellCheck](https://github.com/koalaman/shellcheck): GPL-3.0. Lints shell scripts. Started as a separate program, never linked or bundled.
- [Gitleaks](https://github.com/gitleaks/gitleaks): MIT. Scans for secrets.
- [Semgrep](https://github.com/semgrep/semgrep): LGPL-2.1. Static analysis with Xaden's own local rules. The rules of the Semgrep registry that a CI run may add are under the [Semgrep Rules License v1.0](https://semgrep.dev/legal/rules-license), not LGPL.
- [actionlint](https://github.com/rhysd/actionlint): MIT. Checks GitHub Actions workflows.
- [zizmor](https://github.com/zizmorcore/zizmor): MIT. Finds security problems in GitHub Actions workflows.
- [Bandit](https://github.com/PyCQA/bandit): Apache-2.0. Security linter for Python.
- [pip-audit](https://github.com/pypa/pip-audit): Apache-2.0. Audits Python dependencies for known vulnerabilities.

### Python

- [Ruff](https://github.com/astral-sh/ruff): MIT. Linter and formatter.
- [mypy](https://github.com/python/mypy): MIT. Type checker.
- [pytest](https://github.com/pytest-dev/pytest): MIT. Test runner.

### JavaScript and TypeScript

- [ESLint](https://github.com/eslint/eslint): MIT. Linter.
- [typescript-eslint](https://github.com/typescript-eslint/typescript-eslint): MIT. TypeScript rules for ESLint.
- [TypeScript](https://github.com/microsoft/TypeScript): Apache-2.0. Type checker.

### Optional tools Xaden only suggests

A `TIP:` in the full check names these when they would fit your project. Xaden installs none of them.

- [jscpd](https://github.com/kucherenko/jscpd): MIT. Finds copy-pasted code.
- [Vulture](https://github.com/jendrikseipp/vulture): MIT. Finds dead Python code.
- [Hypothesis](https://github.com/HypothesisWorks/hypothesis): MPL-2.0. Property-based tests for Python.
- [mutmut](https://github.com/boxed/mutmut): BSD-3-Clause. Mutation testing for Python.
- [Knip](https://github.com/webpro-nl/knip): ISC. Finds unused files and exports in JavaScript projects.
- [fast-check](https://github.com/dubzzz/fast-check): MIT. Property-based tests for JavaScript.
- [StrykerJS](https://github.com/stryker-mutator/stryker-js): Apache-2.0. Mutation testing for JavaScript.

The assistant add-ons the Admin Guide lists, such as Ponytail or Caveman, carry their own licenses; they are named with theirs in
[Requirements and platforms]({{< relref "docs/admin-guide/requirements-and-platforms" >}}).

## Standards and works Xaden builds on

- [OWASP Web Security Testing Guide](https://github.com/OWASP/wstg): CC BY-SA 4.0. Xaden's security review follows its test categories; it copies no text.
- [OWASP ASVS](https://github.com/OWASP/ASVS): CC BY-SA 4.0. The verification level a project chooses in its threat model.
- [OWASP Top 10](https://github.com/OWASP/Top10): CC BY-SA 4.0. Named in the security checklist; no text copied.
- [Conventional Commits](https://github.com/conventional-commits/conventionalcommits.org): MIT. The commit message format Xaden checks.
- [Keep a Changelog](https://github.com/olivierlacan/keep-a-changelog): MIT. The changelog format.
- [Semantic Versioning](https://semver.org): CC BY 3.0. The version scheme.
- [AI-Driven Development manifesto](https://ai-driven-development.org): CC BY 4.0. Version 1.1.1. Xaden's rules implement
  its principles in part and list the gaps; Xaden is not certified by the manifesto and uses no badge or logo of it.

Jobs To Be Done and Given–When–Then are ways of working that Xaden's requirements use; the Clean Code rules follow the practices described
in Robert C. Martin's book *Clean Code*. They are ideas credited here, not text Xaden reproduces.

## This site

- [Hugo](https://github.com/gohugoio/hugo): Apache-2.0. Builds the site.
- [Tailwind CSS](https://github.com/tailwindlabs/tailwindcss): MIT. The stylesheet. Its license banner stays in the built CSS.
- [Hugoplate](https://github.com/zeon-studio/hugoplate): MIT. The layout structure of the theme derives from it.
- [Cinzel](https://github.com/NDISCOVER/Cinzel): SIL OFL 1.1. Copyright 2020 The Cinzel Project Authors. [License text](/fonts/LICENSE-cinzel.txt).
- [Inter](https://github.com/rsms/inter): SIL OFL 1.1. Copyright 2016 The Inter Project Authors. [License text](/fonts/LICENSE-inter.txt).

The fonts are served from this site, from the `@fontsource` packages. The site is hosted on GitHub Pages; the [privacy notice](/privacy/) says what that means for your data.

## Names

The names of assistants and tools, such as Claude Code, Codex, Cursor and GitHub Copilot, belong to their owners. Xaden says that it works
with them and nothing more; it is not affiliated with or endorsed by any of them.

To report a missing credit or a wrong license, write to [hello@xaden.dev](mailto:hello@xaden.dev).

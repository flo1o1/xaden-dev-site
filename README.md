# xaden-dev-site

The source of https://xaden.dev, the website of [Xaden](https://github.com/flo1o1/xaden): a static
[Hugo](https://gohugo.io) site with its own theme (`themes/xaden`), built with the Tailwind CSS
command-line tool and published on GitHub Pages. The documentation pages are not written here: they are
rendered from a Xaden release.

## Build and preview locally

You need macOS or Linux with `git`, `curl`, `hugo` (extended build, the version pinned in
`.github/workflows/ci.yml`) and the standalone `tailwindcss` command (version 4; macOS: `brew install hugo tailwindcss`).

```bash
scripts/sync-docs.sh
scripts/build-css.sh
hugo server
```

- `scripts/sync-docs.sh`: downloads the Xaden release named in `XADEN_DOCS_VERSION` and renders its documentation into `content/docs/`. It stops with an error if the release has a section it does not know.
- `scripts/build-css.sh`: builds the stylesheet with Tailwind into `themes/xaden/assets/css/style.css`, a generated file that git ignores.
- `hugo server`: serves the site at http://localhost:1313 and rebuilds when you edit a file.

Run all checks, including a full build and the site checks (no foreign origins, no inline script, `security.txt` valid):

```bash
scripts/check.sh
scripts/check-site.sh
```

## Where things are

| Path | Purpose |
|------|---------|
| `content/` | Pages you write: home (`_index.md`), About, imprint, privacy, Quick start |
| `docs-parts/` | Texts for the Admins and Security pages that the site writes itself |
| `themes/xaden/` | Layouts, Tailwind stylesheet, fonts, logo and artwork |
| `XADEN_DOCS_VERSION` | The Xaden release the documentation describes |
| `scripts/sync-docs.sh` | Builds the Admins, Developers and Security pages from that release |
| `static/` | Files copied as they are, such as `security.txt` and the `CNAME` for xaden.dev |
| `docs/requirements/` | What the site must do, one file per requirement; `INDEX.md` lists them |
| `docs/threat-model.md`, `SECURITY.md` | Security of the site and how to report a problem |
| `AGENTS.md` | Rules for AI assistants working on this repository |

## How a change goes live

1. Work on a branch and open a pull request. CI builds the site and runs every check.
2. A person merges it into `main`. The ruleset on `main` accepts only commits whose `check` job passed.
3. CI runs again on `main`. A separate `deploy` job publishes the site that this run checked.

A daily workflow (`bump-docs`) opens a pull request when Xaden publishes a new release. Merging it updates
`XADEN_DOCS_VERSION` and the documentation.

# xaden-dev-site

The source of https://xaden.dev, the website of [Xaden](https://github.com/flo1o1/xaden-dev): a static
[Hugo](https://gohugo.io) site with its own theme (`themes/xaden`), built with the Tailwind CSS
command-line tool and published on GitHub Pages. The documentation pages are not written here: they are
rendered from a Xaden release.

## Build and preview locally

You need macOS or Linux with `git`, `curl`, `hugo` (extended build, the version pinned in
`.github/workflows/ci.yml`) and the standalone `tailwindcss` command (version 4; macOS: `brew install hugo tailwindcss`).

```bash
scripts/dev.sh
```

`scripts/dev.sh` runs the three steps below in order (it renders the docs only if they are missing). To run them by hand:

```bash
scripts/sync-docs.sh
scripts/build-css.sh
hugo server
```

- `scripts/sync-docs.sh`: downloads the Xaden release named in `XADEN_DOCS_VERSION` and renders its guide files into `content/docs/`. It stops with an error if the release has a guide file it does not know or a link it cannot resolve. `XADEN_SOURCE=<xaden checkout> scripts/sync-docs.sh` previews unreleased guides (never in CI): it renders the tag from `XADEN_DOCS_VERSION` out of the checkout's git, or the working tree if that tag does not exist there.
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
| `content/` | Pages you write: home (`_index.md`), About, imprint, privacy, and in `content/docs/` Quick start, the guide overviews, Reference, Security and Troubleshooting |
| `themes/xaden/` | Layouts, Tailwind stylesheet, fonts, logo and artwork |
| `XADEN_DOCS_VERSION` | The Xaden release the documentation describes |
| `scripts/sync-docs.sh` | Builds the pages of the Developer Guide and the Admin Guide from the guide files of that release (`PAGES` in the script is the list and the order) |
| `static/` | Files copied as they are, such as `security.txt` and the `CNAME` for xaden.dev |
| `docs/requirements/` | What the site must do, one file per requirement |
| `docs/threat-model.md`, `SECURITY.md` | Security of the site and how to report a problem |
| `CLAUDE.md` | Rules for AI assistants working on this repository |

## Prepare the site for a release that is not published yet

1. In the Xaden checkout, create the tag of the coming release locally (for example `v0.3.0`).
2. On a site branch, set `XADEN_DOCS_VERSION` to that tag and run `XADEN_SOURCE=../code scripts/sync-docs.sh`, then `scripts/dev.sh`.
3. Change the site, run `scripts/check.sh` and `scripts/check-site.sh`, commit. Open the pull request once the tag is pushed to GitHub: CI downloads the tag, so it stays red until then. Merge when it is green.

## How a change goes live

1. Work on a branch and open a pull request. CI builds the site and runs every check.
2. A person merges it into `main`. The ruleset on `main` accepts only commits whose `check` job passed.
3. CI runs again on `main`. A separate `deploy` job publishes the site that this run checked.

A daily workflow (`bump-docs`) opens a pull request when Xaden publishes a new release. Merging it updates
`XADEN_DOCS_VERSION` and the documentation.

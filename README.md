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

- `scripts/sync-docs.sh`: downloads the Xaden release that `VERSION` names (`v` plus `VERSION` without a re-publish sequence) and renders its guide files into `content/docs/`. It stops with an error if the release has a guide file it does not know or a link it cannot resolve. `XADEN_SOURCE=<xaden checkout> scripts/sync-docs.sh` previews unreleased guides (never in CI): it renders that tag out of the checkout's git, or the working tree if that tag does not exist there.
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
| `VERSION` | The site version: the Xaden release the documentation describes (`X.Y.Z`), or a re-publish of it (`X.Y.Z-0001`) |
| `scripts/sync-docs.sh` | Builds the pages of the Developer Guide and the Admin Guide from the guide files of that release (`PAGES` in the script is the list and the order) |
| `static/` | Files copied as they are, such as `security.txt` and the `CNAME` for xaden.dev |
| `docs/requirements/` | What the site must do, one file per requirement |
| `docs/threat-model.md`, `SECURITY.md` | Security of the site and how to report a problem |
| `CLAUDE.md` | Rules for AI assistants working on this repository |

## Prepare the site for a release that is not published yet

1. In the Xaden checkout, create the tag of the coming release locally (for example `v0.5.0`).
2. On a site branch, set `VERSION` to `0.5.0` and run `XADEN_SOURCE=../code scripts/sync-docs.sh`, then `scripts/dev.sh`.
3. Change the site, run `scripts/check.sh` and `scripts/check-site.sh`, commit. Open the pull request once the tag is pushed to GitHub: CI downloads the tag, so it stays red until then. Merge when it is green.

## How a change reaches `main`

1. Work on a branch and open a pull request. CI builds the site and runs every check.
2. A person merges it into `main`. The ruleset on `main` accepts only commits whose `check` job passed.
3. CI runs again on `main`. Nothing is published: `main` is where changes wait for the next release.

## Release the site

The site has the version of the Xaden release it describes, and it is published only from a version tag (REQ-023).

1. Release Xaden first (tag `vX.Y.Z` on GitHub).
2. On a branch `release/vX.Y.Z`: `scripts/release-site.sh X.Y.Z` sets `VERSION`, stamps `CHANGELOG.md`, renders the docs and makes one commit. It never pushes.
3. Push the branch, open the pull request, merge it when `check` is green.
4. Tag the merge commit and push the tag: `git tag -a vX.Y.Z <merge commit>` and `git push origin vX.Y.Z`. CI checks that the tag is the newest one, matches `VERSION` and is on `main`, then the `deploy` job publishes it.

To publish again without a new Xaden release (a typo, a new page): `scripts/release-site.sh republish` on a branch `release/<next version>`, then the same steps. The tag is `vX.Y.Z-0001`, then `-0002`, and so on. Only the newest tag publishes; the `github-pages` environment accepts tags `v*` only.

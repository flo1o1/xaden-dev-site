# Xaden website: concept

Status 2026-10-13: concept decided. Website requirements are drafted in
`docs/requirements/` (17 requirements: 16 `approved`, 1 `dropped`).
Xaden's own requirements stay in `docs/requirements/` of this repository.

## Objective

A small website at `xaden.dev` that tells a visitor in under a minute what Xaden is, whether it is
for them, and how to install it. It is also the home of the documentation and, later, the release notes.

Non-goals: marketing funnel, analytics, user accounts, comments, newsletter, anything that needs a
server. The only traffic signal is GitHub's repository traffic and stars.

## Decisions

| Topic | Decision |
|-------|----------|
| Repository | Separate **public** repository `xaden-dev-site` (private would need a paid GitHub plan for Pages and the ruleset; the published site is public either way). No site files in `template/` or at the scaffold root |
| Docs source | One source of truth: the site renders the docs of the latest scaffold **release** (tarball), never a copy. The site build picks up a new release by scheduled polling (proposed, REQ-064) |
| Generator | Hugo (extended build) with the site's own theme `themes/xaden`, derived from Hugoplate (MIT, commit in `themes/xaden/NOTICE.md`) and styled with Tailwind CSS built by the pinned standalone CLI. Hugoplate itself was not adopted as is: it needs 25 Hugo modules fetched from GitHub, Google Fonts, analytics and scripts, which break REQ-011, REQ-012 and REQ-014 |
| Look | Dark only, dark fantasy mood after the Empyrean novels (REQ-019). Palette taken from `xaden.png`: ink, charcoal, crimson, bone. Fonts Cinzel and Inter, self-hosted |
| Hosting | GitHub Pages, custom domain `xaden.dev`, HTTPS enforced |
| Language | English only, including imprint and privacy notice |
| Imprint | Business address; email as the only contact way (accepted risk: a court may want a second fast contact way, mitigated by answering mail quickly) |
| Blog drafts | Template-based from the `CHANGELOG.md` entry, no LLM, committed as a reviewable draft |
| First release | Home, Docs (install + use), About, Legal, security.txt, 404 |
| Second step | Blog, Atom feed, contributor docs |

Theme check (2026-10-13): MIT, 143 stars, 126 commits, last commit 2026-03-20, single maintainer, no
JavaScript, self-hosted fonts (Fira Mono), only plain footer links to gohugo.io and GitHub, no analytics
or CDN. Needs Hugo >= 0.158.0 (unverified that this version exists) and Sass. Risk: slow maintenance,
so keep fork-ability.

## Site map

| Page | Purpose | Source |
|------|---------|--------|
| Home | What / So what / Now what | hand-written |
| Docs | Install, update, use, customize, contribute | rendered from the scaffold release |
| Blog (second step) | Release posts + occasional insights, Atom feed | `CHANGELOG.md` + hand-written |
| About | Who, why, license (MIT), contact | hand-written |
| Legal | Imprint + privacy notice | hand-written |
| `/.well-known/security.txt` | Vulnerability reporting contact | generated |
| 404 | Back to Home / Docs | hand-written |

Navigation: Docs · Blog · About, plus a link to the GitHub repository; Home is the logo. There is no
Contact page: contact is a section of About and in the footer.

### Home

Structure after [What? So what? Now what?](https://www.simplypsychology.org/what-so-what-now-what.html):

- **What?** One sentence plus real terminal output of creating a project.
- **So what?** The problem (assistants invent rules and requirements, skip checks, leak secrets) and the
  answer (one rule set for every assistant, checked in hooks and CI, code traced to requirements).
  Three to five concrete points, no adjectives without proof, and who Xaden is not for.
- **Now what?** Prerequisites, install command, one primary link to Getting Started.

Every claim links to the doc page or file that backs it.

### Documentation

Task-oriented; the three groups are entry points, not silos. Names differ from the template's
`admin-guide.md` / `user-guide.md`, which are for projects generated *from* Xaden. Every page shows the
Xaden version it describes and ends with "edit on GitHub". Only the latest release is published.

- **Operating systems:** wherever steps differ, install, update and uninstall have a plain section per
  OS (Linux, macOS, Windows). Support levels follow REQ-009 of the scaffold: Linux and macOS supported;
  Windows via WSL (recommended) or Git Bash, untested; native PowerShell not supported. Never invent
  Windows steps that were not run.
- **Admins:** install; update/upgrade (including SemVer meanings); uninstall; keep it secure; what's inside
  (tools and libraries Xaden uses).
- **Developers:** use; customize; create new projects; migrate existing projects; model-specific use.
- **Contributors (second step):** contribute; test; land a change (branch, CI green on the exact commit,
  push to `main`).

### Blog (second step)

Occasional insights plus one post per minor or major release; patch releases only when significant.
Release posts are drafted from the changelog entry: what changed, why it matters, upgrade steps with
breaking changes first, link to `CHANGELOG.md` in the repository. Short, no marketing, not a bare changelog. Never
published unreviewed. Atom feed as a static file. No separate changelog page: the file in the repository is the changelog.

### security.txt

[RFC 9116](https://www.rfc-editor.org/rfc/rfc9116) at `/.well-known/security.txt`: `Contact`, `Expires`
(at most one year ahead), `Canonical`, `Policy` (scaffold `SECURITY.md`), `Preferred-Languages: en`. The
build fails when `Expires` is less than 60 days away. `Contact` is `hello@xaden.dev`, the only address used anywhere on the site.

## Design and technology

- Define colour tokens once (CSS custom properties) as overrides. Check WCAG AA contrast, keyboard use,
  visible focus, reduced motion, 320 px width.
- No cookies, no analytics, no third-party requests; a CI check scans the built site for other origins.
  JavaScript is optional enhancement only.
- Strict Content-Security-Policy as a `<meta>` tag, no inline script. GitHub Pages cannot set response
  headers, so `frame-ancestors`, `Permissions-Policy` and similar protections are unavailable: record
  this as an accepted limit in the site's threat model instead of claiming "rock solid".
- CI actions pinned by commit hash, least-privilege deploy token, `main` protected by a green-CI rule
  like the scaffold's.

## Legal

Not legal advice. The imprint duty (DDG §5) covers sites offered on a lasting basis, even if free; a blog
may also trigger MStV §18. The imprint shows name, business address, email, occupation (VAT ID if any).
The privacy notice names GitHub Pages as host and the processing of visitor IP addresses.

## To do before work starts

1. Done 2026-10-13: website requirements approved as a set.
2. Done 2026-10-13: repository `flo1o1/xaden-dev-site` created (public) from Xaden; these requirements are
   in its `docs/requirements/`. Still open: the green-CI ruleset on `main`, GitHub Pages and the `xaden.dev` domain.
3. Scaffold side, drafted in this repository: REQ-064 (a release reaches the site without manual
   steps) and REQ-065 (Getting Started documents the zip and clone install). Proposed design for
   REQ-064: the site repository polls for the newest tag on a schedule (plus manual start), so the
   scaffold stores no credential for the site. The repository rename `xaden` to `xaden-dev` is still
   planned (`inbox/2026-10-13-rename-repo-xaden-dev.md`).
4. Check that the pinned Hugo version satisfies the theme (>= 0.158.0).
5. Write the imprint and privacy texts; confirm the business address receives mail.
6. Done 2026-10-13: palette taken from `xaden.png` (REQ-019).

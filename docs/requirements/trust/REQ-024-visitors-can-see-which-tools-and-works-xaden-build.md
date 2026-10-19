---
id: REQ-024
type: job
epic: trust
priority: should
status: done
updated: 2026-10-19
---

# Visitors can see which tools and works Xaden builds on, and under which license

## Job

When I decide whether to trust or adopt Xaden, I want to see which tools it runs and which standards and works it builds on, with their licenses, so I can judge the dependencies and know that the authors are credited.

## Acceptance criteria

- Given the About page, then it links to a sub-page "Credits and licenses", and the footer of every page links to it too
- Given the sub-page, then it lists the tools Xaden runs or recommends, each with a link and its license, and says that Xaden bundles none of them: the user or the generated CI installs them
- Given the sub-page, then it credits the standards and works Xaden builds on (OWASP WSTG, ASVS and Top 10; Conventional Commits; Keep a Changelog; Semantic Versioning; the AI-Driven Development manifesto with its CC BY 4.0 attribution) and says that Xaden implements the manifesto and is not certified by it
- Given the site, then it lists what it is built with (Hugo, Tailwind CSS, Hugoplate, the fonts), and the OFL license and copyright text of Cinzel and Inter are served next to the fonts
- Given the sub-page, then it says that names of assistants and tools belong to their owners, and it uses only "works with" wording
- Given the site check, then it fails when an entry on the sub-page has no link or no license, when the footer or About link is missing, or when a font has no license file next to it

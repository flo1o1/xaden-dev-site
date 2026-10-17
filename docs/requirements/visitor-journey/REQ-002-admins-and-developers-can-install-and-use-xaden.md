---
id: REQ-002
type: job
epic: visitor-journey
priority: must
status: approved
updated: 2026-10-15
---

# Visitors can install, use, adopt and operate Xaden from the documentation alone

## Job

When I decide to try Xaden, I want task-oriented instructions to install, update, uninstall, use and migrate, so I can get a working project without reading the repository.

## Acceptance criteria

- Given the docs landing page, then it offers, in this order, Quick start, Developer Guide, Admin Guide, Reference, Security and Troubleshooting, each with a one-sentence description, and the pages of each guide and of the Reference are listed under it
- Given the Developer Guide, then it has one page per step of the life of a project (create a project, add Xaden to a repository, check modes and baselines, kick off, build features, release, join a project, other assistants and local models), and its overview says which page answers which need
- Given the Admin Guide, then it has one page per operating task (requirements and platforms, install, update, pin one version per project, verify releases, optional tools and plugins, update a classic project, uninstall), and its overview says which page answers which need
- Given the Reference, then it holds only facts to look up: the commands in three groups (project, work, team), the settings of `xaden/xaden.conf`, the files and folders, and the exit codes and environment variables; it holds no step-by-step instructions and links to the guide page that has them
- Given `xaden help`, then every command it lists has a heading in the Reference, and the site build fails when one is missing
- Given Troubleshooting, then it is one page grouped by area (install and PATH, creating and adopting, checks and modes, versions and downloads, hooks and CI), and each entry is a heading with the cause and the fix
- Given any heading in the docs, then it says what the reader does or learns ("Add Xaden to a repository"), not a bare label or an unexplained product name
- Given any guide page, then it starts with the shortest path that works (the happy path) and covers special cases, limits and failures after it
- Given the guide pages, then they are generated from one source file each in the Xaden release (`docs/guide/` and the shipped guides), so the site and the repository never differ; the pages that the site writes itself are Quick start, the Reference, Security and Troubleshooting
- Given the install page, then it documents both ways to get Xaden, downloading the release as a zip archive and cloning the repository, each with its steps and when to choose it
- Given the requirements page and the install and update pages, then each has a section per operating system (Linux, macOS, Windows) wherever the steps differ, such as prerequisites, the shell profile line for `PATH`, or the shell used
- Given the Windows section, then it states the support level exactly as the guide in the repository does (WSL or Git Bash, untested; native PowerShell not supported) and invents no steps that were not run
- Given the operating system sections, then they are plain headings on the page and work without JavaScript, not tabs
- Given any docs page, then it shows the Xaden version and release date it describes, or says it is an unreleased preview
- Given the main menu, then Docs opens a submenu with Quick start, Developer Guide, Admin Guide, Reference, Security and Troubleshooting, which works with the keyboard and without JavaScript
- Given any docs page, then it contains no requirement or rule IDs (such as REQ-123 or CC-03), no section references (such as §10) and no paths into the Xaden repository, because readers have not seen the repository; paths inside a generated project stay
- Given any command in the docs, then it uses the `xaden` command wherever one exists, and `scripts/install.sh` appears only to install `xaden`
- Given any link to a page of the site or to an anchor on it, then it resolves, and the site build fails when one does not
- Given the Security page, then it holds all security information, at a high level: it explains how Xaden helps at each stage (before building, while building, on every commit, when downloading, before a release, when something goes wrong) and links to deeper sources such as OWASP, instead of reproducing a checklist

---
id: REQ-002
type: job
epic: visitor-journey
priority: must
status: approved
updated: 2026-10-13
---

# Admins and developers can install and use Xaden from the documentation alone

## Job

When I decide to try Xaden, I want task-oriented instructions to install, update, uninstall, use and migrate, so I can get a working project without reading the repository.

## Acceptance criteria

- Given the docs landing page, then it offers the entry points Admins and Developers, each one single page whose sections are listed on the landing page and in a table of contents
- Given the install page, then it documents both ways to get Xaden, downloading the release as a zip archive and cloning the repository, each with its steps and when to choose it
- Given the install, update and uninstall pages, then each has a section per operating system (Linux, macOS, Windows) wherever the steps differ, such as prerequisites, the shell profile line for `PATH`, or the shell used
- Given the Windows section, then it states the support level exactly as the Getting Started page does (WSL or Git Bash, untested; native PowerShell not supported) and invents no steps that were not run
- Given the operating system sections, then they are plain headings on the page and work without JavaScript, not tabs
- Given the Admins pages, then they answer: install, update and upgrade (with the meaning of SemVer), uninstall, keep it secure, what is inside (linked tools and libraries)
- Given the Developers pages, then they answer: use, customize, create a new project, migrate an existing project, model-specific use
- Given any docs page, then it ends with an edit-on-GitHub link and shows the Xaden version it describes

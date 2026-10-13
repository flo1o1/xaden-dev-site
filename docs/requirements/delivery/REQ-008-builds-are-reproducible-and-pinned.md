---
id: REQ-008
type: quality
epic: delivery
priority: should
status: approved
updated: 2026-10-13
---

# Builds are reproducible and pinned

## Quality goal

Building the same commit twice yields byte-identical output; the Hugo version (extended build), the theme (a commit, not a branch) and every CI action (a commit hash) are pinned.

## Acceptance criteria

- Given the same commit, when built twice, then the outputs are identical
- Given the configuration, then the Hugo version, the theme commit and each action reference are pinned, and CI fails on a floating reference

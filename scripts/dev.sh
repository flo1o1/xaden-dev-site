#!/usr/bin/env bash
# Local preview: renders the docs once if they are missing, builds the stylesheet, serves the site.
# Usage: scripts/dev.sh   (needs hugo extended and tailwindcss v4; http://localhost:1313)
# No checks run here: use scripts/check.sh and scripts/check-site.sh once before you push.
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"

# shortcut: the docs are not refreshed when XADEN_DOCS_VERSION changes, delete content/docs/admins.md to re-render
[ -f "$ROOT/content/docs/admins.md" ] || "$SCRIPTS/sync-docs.sh"
"$SCRIPTS/build-css.sh"
cd "$ROOT" && exec hugo server

#!/usr/bin/env bash
# Local preview: renders the docs when the pinned version changed (or XADEN_SOURCE is set), builds the stylesheet, serves the site.
# Usage: scripts/dev.sh   (needs hugo extended and tailwindcss v4; http://localhost:1313)
# No checks run here: use scripts/check.sh and scripts/check-site.sh once before you push.
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"

# Re-render unless the last render was a release render of the pinned tag. With XADEN_SOURCE set it always
# re-renders (the checkout may have changed); that is local and quick.
tag="$(tr -d '[:space:]' <"$ROOT/XADEN_DOCS_VERSION")"
if [ -n "${XADEN_SOURCE:-}" ] || ! grep -qx "tag: \"$tag\"" "$ROOT/data/release.yaml" 2>/dev/null ||
  ! grep -qx "preview: false" "$ROOT/data/release.yaml" 2>/dev/null; then
  "$SCRIPTS/sync-docs.sh"
fi
"$SCRIPTS/build-css.sh"
cd "$ROOT" && exec hugo server

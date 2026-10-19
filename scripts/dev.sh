#!/usr/bin/env bash
# Local preview: renders the guides from the main of the Xaden checkout next to this one (else from the pinned release), builds the stylesheet, serves the site.
# Usage: scripts/dev.sh   (needs hugo extended and tailwindcss v4; http://localhost:1313)
# No checks run here: use scripts/check.sh and scripts/check-site.sh once before you push.
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"

# The site's main is reviewed here, so the guides come from the main of the Xaden checkout (sync-docs.sh --main):
# XADEN_SOURCE, else the checkout next to this one, else the one next to the worktrees folder when this is a
# worktree of the site. Without any checkout the pinned release renders, unless the last render already was one.
# shellcheck source=SCRIPTDIR/lib.sh
source "$SCRIPTS/lib.sh"
tag="v$(xaden_version "$(tr -d '[:space:]' <"$ROOT/VERSION")")"
xaden_checkout=""
for candidate in "${XADEN_SOURCE:-}" "$ROOT/../code" "$ROOT/../../code"; do
  if [ -n "$candidate" ] && [ -f "$candidate/GETTING-STARTED.md" ]; then xaden_checkout="$(cd "$candidate" && pwd)"; break; fi
done
if [ -n "$xaden_checkout" ]; then
  XADEN_SOURCE="$xaden_checkout" "$SCRIPTS/sync-docs.sh" --main
elif ! grep -qx "tag: \"$tag\"" "$ROOT/data/release.yaml" 2>/dev/null ||
  ! grep -qx "preview: false" "$ROOT/data/release.yaml" 2>/dev/null; then
  "$SCRIPTS/sync-docs.sh"
fi
"$SCRIPTS/build-css.sh"
cd "$ROOT" && exec hugo server

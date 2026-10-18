#!/usr/bin/env bash
# Local preview: renders the guides from the main of the Xaden checkout next to this one (else from the pinned release), builds the stylesheet, serves the site.
# Usage: scripts/dev.sh   (needs hugo extended and tailwindcss v4; http://localhost:1313)
# No checks run here: use scripts/check.sh and scripts/check-site.sh once before you push.
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"

# The site's main is reviewed here, so the guides come from the main of the Xaden checkout next to this one
# (sync-docs.sh --main). Without that checkout, or with XADEN_SOURCE set, the old rules apply: re-render unless the
# last render was a release render of the pinned tag.
# shellcheck source=SCRIPTDIR/lib.sh
source "$SCRIPTS/lib.sh"
tag="v$(xaden_version "$(tr -d '[:space:]' <"$ROOT/VERSION")")"
if [ -z "${XADEN_SOURCE:-}" ] && [ -f "$ROOT/../code/GETTING-STARTED.md" ]; then
  "$SCRIPTS/sync-docs.sh" --main
elif [ -n "${XADEN_SOURCE:-}" ] || ! grep -qx "tag: \"$tag\"" "$ROOT/data/release.yaml" 2>/dev/null ||
  ! grep -qx "preview: false" "$ROOT/data/release.yaml" 2>/dev/null; then
  "$SCRIPTS/sync-docs.sh"
fi
"$SCRIPTS/build-css.sh"
cd "$ROOT" && exec hugo server

#!/usr/bin/env bash
# Builds the theme stylesheet with the standalone Tailwind CSS CLI (no Node, no npm).
# Output: themes/xaden/assets/css/style.css (generated, git-ignored); Hugo fingerprints it.
# Usage: scripts/build-css.sh   (needs tailwindcss v4 on PATH; CI installs the pinned, checksum-verified one)
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"
# shellcheck source=SCRIPTDIR/lib.sh
source "$SCRIPTS/lib.sh"

THEME="$ROOT/themes/xaden"

has_command tailwindcss || die "tailwindcss not found: install the standalone CLI v4 (see TAILWIND_VERSION in .github/workflows/ci.yml; macOS: brew install tailwindcss)"
mkdir -p "$THEME/assets/css"
tailwindcss --input "$THEME/tailwind/main.css" --output "$THEME/assets/css/style.css" --minify >/dev/null 2>&1 ||
  die "tailwindcss failed; run it without the redirect to see why: tailwindcss -i themes/xaden/tailwind/main.css -o /dev/null"
# Keep the license banner but not its URL: the origin check (REQ-011) treats every URL in a stylesheet as a request.
sed -i.bak 's#https://tailwindcss.com#tailwindcss.com#' "$THEME/assets/css/style.css" && rm "$THEME/assets/css/style.css.bak"
info "stylesheet built"

#!/usr/bin/env bash
# Moves XADEN_DOCS_VERSION to the newest Xaden release tag (REQ-006). Prints the new tag when it
# changed and nothing when the pin is already current. Pre-release and malformed tags are ignored.
# Usage: scripts/bump-docs-version.sh [tag-list-file]   (default: tags from the Xaden repository)
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"
# shellcheck source=SCRIPTDIR/lib.sh
source "$SCRIPTS/lib.sh"

XADEN_REMOTE="https://github.com/flo1o1/xaden.git"
RELEASE_TAG_PATTERN='^v[0-9]+\.[0-9]+\.[0-9]+$'
VERSION_FILE="$ROOT/XADEN_DOCS_VERSION"

# list_tags <file>: one tag name per line, from a file or from the Xaden repository.
list_tags() {
  if [ -n "${1:-}" ]; then cat "$1"; return; fi
  git ls-remote --tags --refs "$XADEN_REMOTE" 'v*' | sed 's|.*refs/tags/||'
}

# newest_tag: the highest vX.Y.Z on stdin, compared numerically (POSIX sort, no -V).
newest_tag() {
  grep -E "$RELEASE_TAG_PATTERN" | sed 's/^v//' | sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1 | sed 's/^/v/'
}

main() {
  local latest current
  latest="$(list_tags "${1:-}" | newest_tag)"
  [ -n "$latest" ] || die "REQ-006: no release tag found for the Xaden repository"
  current="$(tr -d '[:space:]' <"$VERSION_FILE")"
  [ "$latest" != "$current" ] || return 0
  printf '%s\n' "$latest" >"$VERSION_FILE"
  printf '%s\n' "$latest"
}

main "$@"

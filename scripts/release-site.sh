#!/usr/bin/env bash
# Releases the site (REQ-023): sets VERSION, stamps the changelog, renders the docs, makes one commit.
# Never pushes or tags: land the commit by pull request, then tag the merge commit (README.md).
# Usage: scripts/release-site.sh <X.Y.Z>     the site for Xaden release vX.Y.Z (its tag must exist)
#        scripts/release-site.sh republish   the same Xaden release again (vX.Y.Z-0001, -0002, ...), for a fix
# XADEN_TAG_LIST=<file>: tags to use instead of asking GitHub (tests).
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"
# shellcheck source=SCRIPTDIR/lib.sh
source "$SCRIPTS/lib.sh"

XADEN_REMOTE="https://github.com/flo1o1/xaden-dev.git"

# xaden_tags: the tags of the Xaden repository, one per line.
xaden_tags() {
  if [ -n "${XADEN_TAG_LIST:-}" ]; then cat "$XADEN_TAG_LIST"; return; fi
  git ls-remote --tags --refs "$XADEN_REMOTE" 'v*' | sed 's|.*refs/tags/||'
}

# stamp_changelog <version>: turns the Unreleased section into a release section; dies when it is empty.
stamp_changelog() {
  awk '/^## \[Unreleased\]/ { in_unreleased = 1; next } /^## \[/ { in_unreleased = 0 } in_unreleased && /^- / { found = 1 } END { exit !found }' "$ROOT/CHANGELOG.md" ||
    die "REQ-023: the Unreleased section of CHANGELOG.md has no entry; say what this release changes"
  awk -v version="$1" -v date="$(date +%F)" '/^## \[Unreleased\]/ { print; print ""; print "## [" version "] - " date; next } { print }' "$ROOT/CHANGELOG.md" >"$ROOT/CHANGELOG.md.new"
  mv "$ROOT/CHANGELOG.md.new" "$ROOT/CHANGELOG.md"
}

main() {
  local what=${1:-} current next
  [ "$#" -eq 1 ] || die "usage: scripts/release-site.sh <X.Y.Z> | republish"
  [ -z "$(git -C "$ROOT" status --porcelain)" ] || die "working tree not clean; commit or stash first"
  current="$(tr -d '[:space:]' <"$ROOT/VERSION")"
  is_site_version "$current" || die "REQ-023: VERSION holds '$current', not X.Y.Z or X.Y.Z-NNNN"
  if [ "$what" = "republish" ]; then
    next="$(next_sequence "$current")"
  else
    printf '%s' "$what" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || die "usage: scripts/release-site.sh <X.Y.Z> | republish"
    version_is_higher "$what" "$current" || die "REQ-023: $what is not higher than the current version $current"
    xaden_tags | grep -qx "v$what" || die "REQ-023: Xaden has no release tag v$what; release Xaden first"
    next=$what
  fi
  # die exits without ERR, so an EXIT trap restores the files unless the commit was made
  RELEASED=0
  trap '[ "$RELEASED" = 1 ] || { git -C "$ROOT" checkout -q -- VERSION CHANGELOG.md; rm -f "$ROOT/CHANGELOG.md.new"; }' EXIT
  printf '%s\n' "$next" >"$ROOT/VERSION"
  stamp_changelog "$next"
  "$SCRIPTS/sync-docs.sh"
  git -C "$ROOT" add VERSION CHANGELOG.md
  git -C "$ROOT" commit -q -m "chore(release): site v$next"
  RELEASED=1
  info "released site v$next (not pushed or tagged; README.md \"Release the site\")"
}

main "$@"

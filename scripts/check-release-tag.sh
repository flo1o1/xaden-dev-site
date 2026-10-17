#!/usr/bin/env bash
# Checks that a tag may publish the site (REQ-023): it is vX.Y.Z[-NNNN], equals v + VERSION, is the
# highest such tag, and its commit is on main. Run by the deploy job on the checkout of the tag.
# Usage: scripts/check-release-tag.sh <tag>      MAIN_REF (default origin/main): where main is
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"
# shellcheck source=SCRIPTDIR/lib.sh
source "$SCRIPTS/lib.sh"

main() {
  local tag=${1:-} newest
  printf '%s' "$tag" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9]{4})?$' || die "REQ-023: '$tag' is not a site release tag like v1.2.3 or v1.2.3-0001"
  [ "$tag" = "v$(tr -d '[:space:]' <"$ROOT/VERSION")" ] || die "REQ-023: tag $tag does not match VERSION $(tr -d '[:space:]' <"$ROOT/VERSION")"
  newest="$(git -C "$ROOT" tag -l 'v*' | newest_site_tag)"
  [ "$newest" = "$tag" ] || die "REQ-023: $tag is not the newest release tag ($newest); only the newest one publishes"
  git -C "$ROOT" merge-base --is-ancestor "$tag" "${MAIN_REF:-origin/main}" || die "REQ-023: the commit of $tag is not on main"
  info "$tag may publish the site"
}

main "$@"

#!/usr/bin/env bash
# Renders the documentation of one Xaden release into content/docs/ (REQ-006).
# Source: the release tarball of the tag in XADEN_DOCS_VERSION; unreleased changes never appear.
# A missing source file, an unreadable tarball or a page without a heading fails the run.
# Usage: scripts/sync-docs.sh [tag]    (needs curl, tar, awk)
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"
# shellcheck source=SCRIPTDIR/lib.sh
source "$SCRIPTS/lib.sh"

XADEN_REPOSITORY="flo1o1/xaden"
DOCS_DIR="$ROOT/content/docs"
# page slug : path inside the release : menu weight. The template's admin and user guides are
# placeholders for generated projects, so they are not published.
PAGES=(
  "getting-started:GETTING-STARTED.md:1"
  "security:template/docs/security.md:2"
  "optional-tools:template/docs/optional-tools.md:3"
  "local-llm:template/docs/local-llm.md:4"
)
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# release_date <tag>: the date (YYYY-MM-DD) of the commit the tag points at.
release_date() {
  curl -fsS "https://api.github.com/repos/$XADEN_REPOSITORY/commits/$1" |
    sed -n 's/^ *"date": "\([0-9-]\{10\}\)T.*/\1/p' | head -n 1
}

# render_page <source file> <slug> <weight> <tag> <date>: front matter + the file without its H1.
render_page() {
  local source="$1" slug="$2" weight="$3" tag="$4" date="$5" title
  [ -f "$source" ] || die "REQ-006: $source is missing in the $tag release"
  title="$(sed -n 's/^# \(.*\)$/\1/p' "$source" | head -n 1)"
  [ -n "$title" ] || die "REQ-006: $source has no top-level heading"
  {
    printf -- '---\ntitle: "%s"\nweight: %s\n---\n\n' "${title//\"/\\\"}" "$weight"
    printf '_Describes Xaden %s, released %s. [Edit on GitHub](https://github.com/%s/blob/%s/%s)._\n\n' \
      "$tag" "$date" "$XADEN_REPOSITORY" "$tag" "${source#"$WORK_DIR"/release/}"
    # <xaden-repo-url> would be read as raw HTML, which the site forbids, and swallow the section after it.
    awk 'BEGIN { skipped = 0 } !skipped && /^# / { skipped = 1; next } { print }' "$source" |
      sed "s#<xaden-repo-url>#https://github.com/$XADEN_REPOSITORY#g"
  } >"$DOCS_DIR/$slug.md"
}

main() {
  local tag="${1:-$(tr -d '[:space:]' <"$ROOT/XADEN_DOCS_VERSION")}" date entry slug path weight
  printf '%s' "$tag" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$' || die "REQ-006: '$tag' is not a release tag like v1.2.3"
  has_command curl || die "curl not found"
  info "download $XADEN_REPOSITORY $tag"
  mkdir "$WORK_DIR/release"
  curl -fsSL "https://github.com/$XADEN_REPOSITORY/archive/refs/tags/$tag.tar.gz" |
    tar -xz -C "$WORK_DIR/release" --strip-components=1
  date="$(release_date "$tag")"
  [ -n "$date" ] || die "REQ-006: could not read the release date of $tag"
  info "render ${#PAGES[@]} pages"
  find "$DOCS_DIR" -type f ! -name '_index.md' -delete
  for entry in "${PAGES[@]}"; do
    IFS=: read -r slug path weight <<<"$entry"
    render_page "$WORK_DIR/release/$path" "$slug" "$weight" "$tag" "$date"
  done
  info "docs of $tag rendered"
}

main "$@"

#!/usr/bin/env bash
# Renders the documentation of one Xaden release into content/docs/ (REQ-006), one page per task,
# grouped by role (REQ-002). Source: the release tarball of the tag in XADEN_DOCS_VERSION;
# unreleased changes never appear. A missing source, a missing or unmapped heading, or an
# unreadable tarball fails the run, so nothing is dropped silently.
# Usage: scripts/sync-docs.sh [tag]    (needs curl, tar, awk)
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"
# shellcheck source=SCRIPTDIR/lib.sh
source "$SCRIPTS/lib.sh"

XADEN_REPOSITORY="flo1o1/xaden"
DOCS_DIR="$ROOT/content/docs"
GETTING_STARTED="GETTING-STARTED.md"
# Whole files: slug | role | weight | path in the release | summary. The title is the file's H1.
# The template's admin and user guides are placeholders for generated projects: not published.
FILE_PAGES=(
  "security|admins|4|template/docs/security.md|Checklist for every change"
  "optional-tools|admins|5|template/docs/optional-tools.md|Extra checks and assistant plugins"
  "local-llm|developers|7|template/docs/local-llm.md|Run Xaden with a local model"
)
# Sections of Getting started, one page each: heading | slug | role | weight | title | summary.
# Add a line when a release adds a section (for example "2. Get Xaden" with the zip and clone install).
SECTION_PAGES=(
  "1. Prerequisites|prerequisites|admins|1|Prerequisites and the xaden command|What you need and the optional xaden command"
  "Getting scaffold improvements into your project|update-a-project|admins|2|Update a project|Pull newer Xaden rules into an existing project"
  "3. Create your project|create-your-project|developers|1|Create your project|One command, a new project with its own git repository"
  "4. Kickoff|kickoff|developers|2|Kickoff|Tell your assistant your idea"
  "5. Build features (repeat)|build-features|developers|3|Build features|The loop: requirement, test, check, commit"
  "6. Release|release|developers|4|Release|Version, tag and push"
  "Joining an existing project|join-a-project|developers|5|Join an existing project|Turn the git hooks on after a clone"
  "Security review quality|security-review-quality|developers|6|Security review quality|Which model to use for reviews"
)
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# release_date <tag>: the date (YYYY-MM-DD) of the commit the tag points at.
release_date() {
  curl -fsS "https://api.github.com/repos/$XADEN_REPOSITORY/commits/$1" |
    sed -n 's/^ *"date": "\([0-9-]\{10\}\)T.*/\1/p' | head -n 1
}

# write_page <slug> <role> <weight> <title> <summary> <source path in release> <tag> <date>:
# front matter, a version line and the body from stdin.
write_page() {
  local slug="$1" role="$2" weight="$3" title="$4" summary="$5" source="$6" tag="$7" date="$8"
  {
    printf -- '---\ntitle: "%s"\nweight: %s\nrole: %s\nsummary: "%s"\n---\n\n' "$title" "$weight" "$role" "$summary"
    printf '_Describes Xaden %s, released %s. [Edit on GitHub](https://github.com/%s/blob/%s/%s)._\n\n' \
      "$tag" "$date" "$XADEN_REPOSITORY" "$tag" "$source"
    # <xaden-repo-url> would be read as raw HTML, which the site forbids, and swallow the text after it.
    sed "s#<xaden-repo-url>#https://github.com/$XADEN_REPOSITORY#g"
  } >"$DOCS_DIR/$slug.md"
}

# section_body <file> <heading>: the lines under "## <heading>" up to the next "## ", with
# "###" promoted to "##" because the page title is the only H1.
section_body() {
  awk -v heading="## $2" '
    /^## / { inside = ($0 == heading); next }
    inside { print }
  ' "$1" | sed 's/^### /## /'
}

# check_all_headings_mapped <file>: every "## " heading of Getting started has a page.
check_all_headings_mapped() {
  local heading entry
  while IFS= read -r heading; do
    for entry in "${SECTION_PAGES[@]}"; do
      [ "${entry%%|*}" = "${heading#\#\# }" ] && continue 2
    done
    die "REQ-006: heading '${heading#\#\# }' of $GETTING_STARTED has no page; add it to SECTION_PAGES"
  done < <(grep '^## ' "$1")
}

render_file_pages() {
  local release="$1" tag="$2" date="$3" entry slug role weight path summary title
  for entry in "${FILE_PAGES[@]}"; do
    IFS='|' read -r slug role weight path summary <<<"$entry"
    [ -f "$release/$path" ] || die "REQ-006: $path is missing in the $tag release"
    title="$(sed -n 's/^# \(.*\)$/\1/p' "$release/$path" | head -n 1)"
    [ -n "$title" ] || die "REQ-006: $path has no top-level heading"
    awk '!skipped && /^# / { skipped = 1; next } { print }' "$release/$path" |
      write_page "$slug" "$role" "$weight" "${title//\"/\\\"}" "$summary" "$path" "$tag" "$date"
  done
}

render_section_pages() {
  local release="$1" tag="$2" date="$3" source="$1/$GETTING_STARTED" entry heading slug role weight title summary body
  [ -f "$source" ] || die "REQ-006: $GETTING_STARTED is missing in the $tag release"
  check_all_headings_mapped "$source"
  for entry in "${SECTION_PAGES[@]}"; do
    IFS='|' read -r heading slug role weight title summary <<<"$entry"
    body="$(section_body "$source" "$heading")"
    [ -n "$body" ] || die "REQ-006: section '$heading' is missing or empty in $GETTING_STARTED of $tag"
    printf '%s\n' "$body" | write_page "$slug" "$role" "$weight" "$title" "$summary" "$GETTING_STARTED" "$tag" "$date"
  done
}

main() {
  local tag="${1:-$(tr -d '[:space:]' <"$ROOT/XADEN_DOCS_VERSION")}" date
  printf '%s' "$tag" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$' || die "REQ-006: '$tag' is not a release tag like v1.2.3"
  has_command curl || die "curl not found"
  info "download $XADEN_REPOSITORY $tag"
  mkdir "$WORK_DIR/release"
  curl -fsSL "https://github.com/$XADEN_REPOSITORY/archive/refs/tags/$tag.tar.gz" |
    tar -xz -C "$WORK_DIR/release" --strip-components=1
  date="$(release_date "$tag")"
  [ -n "$date" ] || die "REQ-006: could not read the release date of $tag"
  find "$DOCS_DIR" -type f ! -name '_index.md' -delete
  render_section_pages "$WORK_DIR/release" "$tag" "$date"
  render_file_pages "$WORK_DIR/release" "$tag" "$date"
  info "docs of $tag rendered: $(find "$DOCS_DIR" -type f ! -name '_index.md' | wc -l | tr -d ' ') pages"
}

main "$@"

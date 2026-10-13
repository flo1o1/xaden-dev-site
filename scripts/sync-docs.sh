#!/usr/bin/env bash
# Renders the documentation of one Xaden release into content/docs/ (REQ-006): one page per role,
# Admins and Developers, with a section per task (REQ-002). Source: the release tarball of the tag
# in XADEN_DOCS_VERSION; unreleased changes never appear. A missing source, a missing or unmapped
# heading, or an unreadable tarball fails the run, so nothing is dropped silently.
# Usage: scripts/sync-docs.sh [tag]    (needs curl, tar, awk)
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"
# shellcheck source=SCRIPTDIR/lib.sh
source "$SCRIPTS/lib.sh"

XADEN_REPOSITORY="flo1o1/xaden"
DOCS_DIR="$ROOT/content/docs"
GETTING_STARTED="GETTING-STARTED.md"
# Pages: role | page title | summary. Sections of each page follow in the order below.
ROLE_PAGES=(
  "admins|Admins|Set up, update and secure Xaden"
  "developers|Developers|Create a project, build with your assistant, release"
)
# Sections of Getting started: role | heading | section title.
# Add a line when a release adds a section (for example "2. Get Xaden" with the zip and clone install).
SECTIONS=(
  "admins|1. Prerequisites|Prerequisites and the xaden command"
  "admins|Getting scaffold improvements into your project|Update a project"
  "developers|3. Create your project|Create your project"
  "developers|4. Kickoff|Kickoff"
  "developers|5. Build features (repeat)|Build features"
  "developers|6. Release|Release"
  "developers|Joining an existing project|Join an existing project"
  "developers|Security review quality|Security review quality"
)
# Whole files, appended after the sections of the same role: role | path in the release.
# The section title is the file's H1. The template's admin and user guides are placeholders for
# generated projects: not published.
FILES=(
  "admins|template/docs/security.md"
  "admins|template/docs/optional-tools.md"
  "developers|template/docs/local-llm.md"
)
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# release_date <tag>: the date (YYYY-MM-DD) of the commit the tag points at.
release_date() {
  curl -fsS "https://api.github.com/repos/$XADEN_REPOSITORY/commits/$1" |
    sed -n 's/^ *"date": "\([0-9-]\{10\}\)T.*/\1/p' | head -n 1
}

# strip_shell_comments: from stdin, shell code blocks (bash, sh, shell or unlabeled) without comments,
# so a copied block pastes into a terminal as is (REQ-018). What a comment said moves into a list
# after the block ("- `command`: comment") so the explanation stays next to the code. Other
# languages keep their comments.
strip_shell_comments() {
  awk '
    function note(command, text) { commands[count] = command; texts[count] = text; count++ }
    /^```/ {
      if (fence) {
        fence = 0; shell = 0
        print
        if (count > 0) {
          print ""
          for (i = 0; i < count; i++) print "- `" commands[i] "`: " texts[i]
        }
        count = 0
        next
      }
      fence = 1; lang = substr($0, 4); shell = (lang == "" || lang == "bash" || lang == "sh" || lang == "shell")
      pending = ""; count = 0
      print; next
    }
    fence && shell {
      if ($0 ~ /^[[:space:]]*#([^!]|$)/) {
        text = $0; sub(/^[[:space:]]*#[[:space:]]*/, "", text)
        pending = (pending == "" ? text : pending " " text)
        next
      }
      if (match($0, /[[:space:]]+#([[:space:]].*)?$/)) {
        text = substr($0, RSTART); command = substr($0, 1, RSTART - 1)
        sub(/^[[:space:]]+#[[:space:]]*/, "", text)
        note(command, text)
        print command; next
      }
      if (pending != "" && $0 !~ /^[[:space:]]*$/) { note($0, pending); pending = "" }
    }
    { print }
  '
}

# demote_headings: from stdin, every Markdown heading one level deeper, except inside code fences.
demote_headings() {
  awk '/^```/ { fence = !fence } !fence && /^#+ / { print "#" $0; next } { print }'
}

# section_body <file> <heading>: the lines under "## <heading>" up to the next "## ".
section_body() {
  awk -v heading="## $2" '
    /^```/ { fence = !fence }
    !fence && /^## / { inside = ($0 == heading); next }
    inside { print }
  ' "$1"
}

# check_all_headings_mapped <file>: every "## " heading of Getting started has a section.
check_all_headings_mapped() {
  local heading entry
  while IFS= read -r heading; do
    for entry in "${SECTIONS[@]}"; do
      entry="${entry#*|}"
      [ "${entry%%|*}" = "${heading#\#\# }" ] && continue 2
    done
    die "REQ-006: heading '${heading#\#\# }' of $GETTING_STARTED has no section; add it to SECTIONS"
  done < <(awk '/^```/ { fence = !fence } !fence && /^## / { print }' "$1")
}

# emit_section <title> <demote|keep>: "## title" and the body from stdin, with shell comments moved
# out of the code blocks and, when the source heading was the file's H1, headings one level deeper.
emit_section() {
  printf '## %s\n\n' "$1"
  if [ "$2" = demote ]; then strip_shell_comments | demote_headings; else strip_shell_comments; fi
  printf '\n'
}

# render_role_page <role> <title> <summary> <release dir> <tag> <date>
render_role_page() {
  local role="$1" title="$2" summary="$3" release="$4" tag="$5" date="$6" entry heading section path body file_title
  {
    printf -- '---\ntitle: "%s"\nrole: %s\nsummary: "%s"\n---\n\n' "$title" "$role" "$summary"
    printf '_Describes Xaden %s, released %s._\n\n' "$tag" "$date"
    for entry in "${SECTIONS[@]}"; do
      [ "${entry%%|*}" = "$role" ] || continue
      entry="${entry#*|}"
      heading="${entry%%|*}"
      section="${entry#*|}"
      body="$(section_body "$release/$GETTING_STARTED" "$heading")"
      [ -n "$body" ] || die "REQ-006: section '$heading' is missing or empty in $GETTING_STARTED of $tag"
      printf '%s\n' "$body" | emit_section "$section" keep
    done
    for entry in "${FILES[@]}"; do
      [ "${entry%%|*}" = "$role" ] || continue
      path="${entry#*|}"
      [ -f "$release/$path" ] || die "REQ-006: $path is missing in the $tag release"
      file_title="$(sed -n 's/^# \(.*\)$/\1/p' "$release/$path" | head -n 1)"
      [ -n "$file_title" ] || die "REQ-006: $path has no top-level heading"
      awk '!skipped && /^# / { skipped = 1; next } { print }' "$release/$path" | emit_section "$file_title" demote
    done
  } | sed "s#<xaden-repo-url>#https://github.com/$XADEN_REPOSITORY#g" >"$DOCS_DIR/$role.md"
  # <xaden-repo-url> would be read as raw HTML, which the site forbids, and swallow the text after it.
}

main() {
  local tag="${1:-$(tr -d '[:space:]' <"$ROOT/XADEN_DOCS_VERSION")}" date entry
  printf '%s' "$tag" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$' || die "REQ-006: '$tag' is not a release tag like v1.2.3"
  has_command curl || die "curl not found"
  info "download $XADEN_REPOSITORY $tag"
  mkdir "$WORK_DIR/release"
  curl -fsSL "https://github.com/$XADEN_REPOSITORY/archive/refs/tags/$tag.tar.gz" |
    tar -xz -C "$WORK_DIR/release" --strip-components=1
  [ -f "$WORK_DIR/release/$GETTING_STARTED" ] || die "REQ-006: $GETTING_STARTED is missing in the $tag release"
  date="$(release_date "$tag")"
  [ -n "$date" ] || die "REQ-006: could not read the release date of $tag"
  check_all_headings_mapped "$WORK_DIR/release/$GETTING_STARTED"
  # everything generated goes; _index.md and quick-start.md are hand-written
  find "$DOCS_DIR" -type f ! -name '_index.md' ! -name 'quick-start.md' -delete
  for entry in "${ROLE_PAGES[@]}"; do
    IFS='|' read -r role title summary <<<"$entry"
    render_role_page "$role" "$title" "$summary" "$WORK_DIR/release" "$tag" "$date"
  done
  info "docs of $tag rendered: ${#ROLE_PAGES[@]} pages"
}

main "$@"

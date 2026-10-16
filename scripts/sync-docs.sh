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

XADEN_REPOSITORY="flo1o1/xaden-dev"
DOCS_DIR="$ROOT/content/docs"
GETTING_STARTED="GETTING-STARTED.md"
# Pages: role | page title | summary. Sections of each page follow in the order below.
ROLE_PAGES=(
  "admins|Admins|Install, extend and update Xaden"
  "developers|Developers|Create a project, build with your assistant, release"
  "security|Security|How Xaden helps keep your project secure"
)
# Parts of each page, in order: role | kind | reference | title | argument.
#   section     "## <reference>" of Getting started as a section called <title>; the argument names
#               an "###" subsection to leave out (it is placed elsewhere)
#   subsection  the "###" <argument> under "## <reference>" of Getting started, as "### <title>"
#   file        a whole file of the release, titled by its H1 (reference = path in the release)
#   own         a text of this site in docs-parts/ (@TAG@ and @VERSION@ are filled in); with an
#               empty title it brings its own sections
# A part of role "none" is never published; it marks a section as covered by an own text.
# Add a line when a release adds a section of Getting started: the run fails on any unmapped one.
# The template's admin and user guides are placeholders for generated projects: not published.
PARTS=(
  "admins|section|1. Prerequisites|Prerequisites|Optional: the \`xaden\` command"
  'admins|own|docs-parts/admins-install.md|Install|'
  "admins|subsection|1. Prerequisites|The \`xaden\` command|Optional: the \`xaden\` command"
  'admins|file|template/docs/optional-tools.md||'
  'admins|section|Getting scaffold improvements into your project|Update a project|'
  'developers|section|3. Create your project|Create your project|'
  'developers|own|docs-parts/developers-existing-project.md|Bring an existing project|'
  'developers|section|4. Kickoff|Kickoff|'
  'developers|section|5. Build features (repeat)|Build features|'
  'developers|section|6. Release|Release|'
  'developers|section|Joining an existing project|Join an existing project|'
  'developers|file|template/docs/local-llm.md||'
  'security|own|docs-parts/security.md||'
  'none|section|2. Get Xaden|not published|'
  'none|section|Security review quality|not published|'
)
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

# release_date <tag>: the date (YYYY-MM-DD) of the commit the tag points at.
release_date() {
  # The API limits anonymous callers per IP address, which shared CI runners exhaust; a token lifts that.
  curl -fsS ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} "https://api.github.com/repos/$XADEN_REPOSITORY/commits/$1" |
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

# rewrite_for_readers: from stdin, the text without references that mean nothing to readers who
# have not seen the Xaden repository (REQ-002): rule and section references, repository paths.
rewrite_for_readers() {
  perl -0pe '
    s/ \((?:`?AGENTS\.md`? )?(?:§ ?[0-9]+|section [0-9]+)\)//g;
    s/ \(CC-[0-9]+\)//g;
    s/see `template\/docs\/local-llm\.md`/see [Using the scaffold with other LLMs](#using-the-scaffold-with-other-llms)/g;
    s/list in `template\/docs\/optional-tools\.md`/list in [Optional tools](#optional-tools)/g;
    s/are in `template\/docs\/optional-tools\.md` → "Assistant\s+plugins" \(in a generated project: `docs\/optional-tools\.md`\)/are in the [Optional tools](#optional-tools) section "Assistant plugins"/g;
    s/tracked by git in `template\/`/tracked by git in Xaden\x27s template folder/g;
    s/comes from `template\/`/comes from Xaden\x27s template folder/g;
    s/--brief REQ-003 feature/--brief <requirement> feature/g;
    s/index, REQ-003, prompt/index, the named requirement, prompt/g;
  '
}

# prefer_xaden_command: from stdin, the text with the `xaden` command wherever it has an equivalent
# (REQ-002). The Xaden docs show the scripts first and `xaden` as an option; the site makes `xaden`
# the first choice. Block rewrites come first, the plain command swaps last. Text that no longer
# matches (a release that already says it this way) is left alone.
prefer_xaden_command() {
  perl -0pe '
    # Create your project: `xaden new` creates ./<name>, so the folder to enter changes too.
    s/```bash\nscripts\/new-project\.sh my-app\nscripts\/new-project\.sh my-app ~\/code\/x\ncd \.\.\/my-app\n```\n\n- `scripts\/new-project\.sh my-app`: [^\n]*\n- `scripts\/new-project\.sh my-app ~\/code\/x`: [^\n]*\n\nWith the `xaden` command: [^\n]*\n/```bash\nxaden new my-app\ncd my-app\n```\n\n- `xaden new my-app`: creates the folder `my-app` in the current directory, with its own git repository and hooks\n- `cd my-app`: moves your terminal into the new project\n\nTo create the project somewhere else, add the folder: `xaden new my-app ~\/code\/x`.\n/;
    s/Then clone your copy and run\n`scripts\/new-project\.sh my-app` from it the same way\./Then clone your copy and run its `scripts\/install.sh`; `xaden new my-app` then works the same way./;
    # Update a project: run inside the project.
    s/Pull the newest scaffold, then from the scaffold directory:.*?inside the project\./Pull the newest Xaden (`git pull` in its folder), then run this inside your project:\n\n```bash\nxaden update\nxaden update --apply\n```\n\n- `xaden update`: dry run, lists what would change\n- `xaden update --apply`: stages the changes; review them with `git diff --cached`/s;
    # The xaden command is the way in, not an option.
    s/so you can\nuse the scaffold from any directory\./so you can\nuse Xaden from any directory./;
    s/is: the link points into it\./is: the link points into it. Every command in these docs assumes the command is installed./;
    s/\| `scripts\/new-project\.sh`, creating `\.\/my-app` \(or `dir`\) \|/| creates `.\/my-app` (or `dir`) with its own git repository and hooks |/;
    s/\| `scripts\/update-scaffold\.sh` for the project you are in \|/| brings the project you are in to this Xaden version; a dry run without `--apply` |/;
    s/\| the project\x27s own `scripts\/setup\.sh`, `check\.sh`, `req\.sh`, `pack-context\.sh`, `release\.sh`, from anywhere inside it \|/| activate the git hooks, run the checks, manage requirements, build a context pack, cut a release; from anywhere inside the project |/;
    # Everything else: the plain command swaps.
    s/scripts\/new-project\.sh/xaden new/g;
    s/scripts\/update-scaffold\.sh/xaden update/g;
    s/scripts\/setup\.sh/xaden setup/g;
    s/scripts\/check\.sh/xaden check/g;
    s/scripts\/req\.sh/xaden req/g;
    s/scripts\/pack-context\.sh/xaden pack/g;
    s/scripts\/release\.sh/xaden release/g;
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

# without_subsection <heading>: from stdin, the text without the "### <heading>" block.
without_subsection() {
  awk -v heading="### $1" '
    /^### / { skipping = ($0 == heading) }
    !skipping { print }
  '
}

# subsection_body <file> <h2 heading> <h3 heading>: the lines under that "###", up to the next heading.
subsection_body() {
  section_body "$1" "$2" | awk -v heading="### $3" '
    /^### / { inside = ($0 == heading); next }
    inside { print }
  '
}

# check_all_headings_mapped <file>: every "## " heading of Getting started is used by a part.
check_all_headings_mapped() {
  local heading entry rest kind reference
  while IFS= read -r heading; do
    for entry in "${PARTS[@]}"; do
      rest="${entry#*|}"
      kind="${rest%%|*}"
      rest="${rest#*|}"
      reference="${rest%%|*}"
      case "$kind" in section | subsection) [ "$reference" = "${heading#\#\# }" ] && continue 2 ;; esac
    done
    die "REQ-006: heading '${heading#\#\# }' of $GETTING_STARTED has no part; add it to PARTS"
  done < <(awk '/^```/ { fence = !fence } !fence && /^## / { print }' "$1")
}

# emit_section <title> <demote|keep>: "## title" and the body from stdin, with shell comments moved
# out of the code blocks and, when the source heading was the file's H1, headings one level deeper.
emit_section() {
  printf '## %s\n\n' "$1"
  if [ "$2" = demote ]; then strip_shell_comments | demote_headings; else strip_shell_comments; fi
  printf '\n'
}

# render_part <kind> <reference> <title> <argument> <release dir> <tag> <version>: one part of a page.
render_part() {
  local kind="$1" reference="$2" title="$3" argument="$4" release="$5" tag="$6" version="$7" body file_title
  case "$kind" in
    section)
      body="$(section_body "$release/$GETTING_STARTED" "$reference")"
      [ -n "$body" ] || die "REQ-006: section '$reference' is missing or empty in $GETTING_STARTED of $tag"
      [ -z "$argument" ] || printf '%s\n' "$body" | grep -qxF "### $argument" ||
        die "REQ-006: subsection '$argument' is missing in section '$reference' of $tag"
      printf '%s\n' "$body" | { if [ -n "$argument" ]; then without_subsection "$argument"; else cat; fi; } | emit_section "$title" keep
      ;;
    subsection)
      body="$(subsection_body "$release/$GETTING_STARTED" "$reference" "$argument")"
      [ -n "$body" ] || die "REQ-006: subsection '$argument' is missing or empty in section '$reference' of $tag"
      printf '### %s\n\n' "$title"
      printf '%s\n' "$body" | strip_shell_comments
      printf '\n'
      ;;
    file)
      [ -f "$release/$reference" ] || die "REQ-006: $reference is missing in the $tag release"
      file_title="$(sed -n 's/^# \(.*\)$/\1/p' "$release/$reference" | head -n 1)"
      [ -n "$file_title" ] || die "REQ-006: $reference has no top-level heading"
      awk '!skipped && /^# / { skipped = 1; next } { print }' "$release/$reference" | emit_section "$file_title" demote
      ;;
    own)
      [ -f "$ROOT/$reference" ] || die "REQ-006: $reference is missing in this repository"
      # without a title the text brings its own sections: its "###" headings become "##"
      sed -e "s/@TAG@/$tag/g" -e "s/@VERSION@/$version/g" "$ROOT/$reference" |
        { if [ -n "$title" ]; then emit_section "$title" keep; else sed 's/^### /## /'; printf '\n'; fi; }
      ;;
    *) die "unknown part kind '$kind'" ;;
  esac
}

# render_role_page <role> <title> <summary> <release dir> <tag> <date>
render_role_page() {
  local role="$1" title="$2" summary="$3" release="$4" tag="$5" date="$6" entry part_role kind reference part_title argument
  {
    printf -- '---\ntitle: "%s"\nrole: %s\nsummary: "%s"\n---\n\n' "$title" "$role" "$summary"
    printf '_Describes Xaden %s, released %s._\n\n' "$tag" "$date"
    for entry in "${PARTS[@]}"; do
      IFS='|' read -r part_role kind reference part_title argument <<<"$entry"
      [ "$part_role" = "$role" ] || continue
      render_part "$kind" "$reference" "$part_title" "$argument" "$release" "$tag" "${tag#v}"
    done
  } | rewrite_for_readers | prefer_xaden_command | sed "s#<xaden-repo-url>#https://github.com/$XADEN_REPOSITORY#g" >"$DOCS_DIR/$role.md"
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

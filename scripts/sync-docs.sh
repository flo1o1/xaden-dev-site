#!/usr/bin/env bash
# Renders the guide pages of one Xaden release into content/docs/ (REQ-006): one page per source file,
# the Developer Guide and the Admin Guide (REQ-002). Source: the release tarball of the Xaden
# tag that VERSION names, without a re-publish sequence (REQ-023); unreleased changes never appear. A missing
# source, an unknown link target, a guide file without a page, or an unreadable tarball fails the run, so nothing is dropped silently. The pages
# that the site writes itself (Quick start, Reference, Security, Troubleshooting) live in content/.
# Usage: scripts/sync-docs.sh [tag]    (needs curl, tar, awk, perl)
#        XADEN_SOURCE=<xaden checkout> scripts/sync-docs.sh    local preview (not in CI): renders the tag in
#        VERSION from the checkout's git, so a release can be prepared before it is published;
#        without that local tag it renders the working tree, uncommitted edits included
#        scripts/sync-docs.sh --main    local preview of what code's main holds: renders the working tree of the
#        Xaden checkout next to this one (or XADEN_SOURCE), whatever tags it has; scripts/dev.sh does this
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"
# shellcheck source=SCRIPTDIR/lib.sh
source "$SCRIPTS/lib.sh"

XADEN_REPOSITORY="flo1o1/xaden-dev"
DOCS_DIR="$ROOT/content/docs"
GETTING_STARTED="GETTING-STARTED.md"
# Pages generated from the release: section | page name | source file in the release | summary.
# The order is the order in the menu and in the "previous / next" links. Every file under docs/guide/
# of the release must be listed here, or the run fails. A fifth field "unreleased" marks a page that Xaden's main
# already has but the pinned release does not: it renders when the source exists (a preview of main, or a release
# that carries it) and is skipped with a warning otherwise, so scripts/sync-docs.sh --main always renders. Remove the
# field in the pull request that pins a release holding the page.
PAGES=(
  "developer-guide|create-a-project|docs/guide/developer/create-a-project.md|Start a new project with Xaden's rules, checks and requirements from the first commit."
  "developer-guide|add-xaden-to-a-repository|docs/guide/developer/add-xaden-to-a-repository.md|Put Xaden beneath a repository you already have without changing its build."
  "developer-guide|check-modes-and-baselines|docs/guide/developer/check-modes-and-baselines.md|Decide how strict the checks are, and adopt without failing on old findings."
  "developer-guide|what-xaden-checks|docs/guide/developer/what-xaden-checks.md|See which checks each layout runs, which an adopted project does not, and how to make the gates blocking.|unreleased"
  "developer-guide|kick-off-with-your-assistant|docs/guide/developer/kick-off-with-your-assistant.md|Turn an idea into approved requirements, a stack and a first skeleton."
  "developer-guide|build-features|docs/guide/developer/build-features.md|Add a feature from a requirement, test first, checked before every commit."
  "developer-guide|use-the-aidd-framework|docs/guide/developer/use-the-aidd-framework.md|Switch on the AI-Driven Dev framework in a project at a pinned version, and off again.|unreleased"
  "developer-guide|release-a-version|docs/guide/developer/release-a-version.md|Cut a checked, stamped and tagged version when you decide to."
  "developer-guide|join-a-project|docs/guide/developer/join-a-project.md|Start contributing to a repository whose team already uses Xaden."
  "developer-guide|other-assistants-and-local-models|template/docs/local-llm.md|Use Xaden in a chat window or with a model on your own machine."
  "admin-guide|requirements-and-platforms|docs/guide/admin/requirements-and-platforms.md|What Xaden needs, and what differs on Linux, macOS and Windows."
  "admin-guide|install-xaden|docs/guide/admin/install-xaden.md|Get Xaden onto your machine with git or from a zip archive."
  "admin-guide|update-xaden|docs/guide/admin/update-xaden.md|Move the Xaden on your machine to a newer version."
  "admin-guide|check-for-updates|docs/guide/admin/check-for-updates.md|Let Xaden report newer versions and dependencies, as often as you choose."
  "admin-guide|pin-one-version-per-project|docs/guide/admin/pin-one-version-per-project.md|Make a team use one Xaden version, and move it together."
  "admin-guide|verify-releases|docs/guide/admin/verify-releases.md|Check checksums and signatures, and know what they prove."
  "admin-guide|optional-tools-and-plugins|template/docs/optional-tools.md|Extra checks and assistant plugins, and their risks."
  "admin-guide|uninstall|docs/guide/admin/uninstall.md|Remove Xaden from a repository or from a machine."
  "contributing|install-with-git|docs/guide/contributing/install-with-git.md|Clone Xaden to read its history, contribute or work on it."
  "contributing|architecture|docs/guide/contributing/architecture.md|How the repository is organised and how the xaden command finds a version."
  "contributing|work-on-xaden|docs/guide/contributing/work-on-xaden.md|How a change to Xaden is made, checked and landed."
  "contributing|release-and-signing|docs/guide/contributing/release-and-signing.md|How a Xaden release is cut and signed."
  "contributing|threat-model-and-requirements|docs/guide/contributing/threat-model-and-requirements.md|What Xaden protects, what it accepts, and where its requirements live."
  "contributing|xaden-and-the-aidd-manifesto|docs/guide/developer/xaden-and-the-aidd-manifesto.md|Which values and principles of the AI-Driven Development Manifesto Xaden meets, and which only partly.|unreleased"
)
# Site pages that sources link to: source file | page URL.
SITE_TARGETS=(
  "template/docs/security.md|/docs/security/"
  "$GETTING_STARTED|/docs/quick-start/"
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
# so a copied block pastes into a terminal as is (REQ-002). What a comment said moves into a list
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
    s/ \(REQ-[0-9]+(?:, REQ-[0-9]+)*\)//g;
    s/, REQ-[0-9]+\)/)/g;
    s/recorded before REQ-153/recorded before the pin check existed/g;
    s/the risks to know before installing are in `template\/docs\/optional-tools\.md` → "Assistant\s+plugins" \(in a generated project: `docs\/optional-tools\.md`\)/the risks to know before installing are in [Optional tools and assistant plugins](\/docs\/admin-guide\/optional-tools-and-plugins\/#assistant-plugins-claude-code)/g;
    s/list in `template\/docs\/optional-tools\.md`/list in [Optional tools and assistant plugins](\/docs\/admin-guide\/optional-tools-and-plugins\/)/g;
    s/ \(`?AGENTS\.md`? §[0-9]+\)//g;
    s/\(§[0-9]+\)/(see the rules in AGENTS.md)/g;
    s/ `AGENTS\.md` §[0-9]+//g;
    s/`AGENTS\.md` §[0-9]+/`AGENTS.md`/g;
    s/AGENTS\.md §[0-9]+/AGENTS.md/g;
    s/tracked by git in `template\/`/tracked by git in Xaden\x27s template folder/g;
    s/comes from `template\/`/comes from Xaden\x27s template folder/g;
    s/--brief REQ-003 feature/--brief <requirement> feature/g;
    s/index, REQ-003, prompt/index, the named requirement, prompt/g;
  '
}

# assistant_commands: from stdin, the per-assistant commands of the guides turned into the picker blocks of
# REQ-022 (shortcodes `prompt` and `cmd`, see themes/xaden/layouts/shortcodes/). Each rule matches the
# wording of the guides; render_page fails when a page that must have blocks has none (the wording changed).
assistant_commands() {
  perl -0pe '
    # a pair of code blocks: the slash command, then the plain prompt
    s{([^\n]*?)In Claude Code, type:\n\n```text\n/([a-z-]+) ([^\n]*)\n```\n\n(.*?)In any other assistant, tell it:\n\n```text\nRun `xaden prompt ([a-z-]+)` and follow it\. ([^:\n]+): [^\n]*\n```\n}{$1Start it with:\n\n\{\{< prompt "$2" "$5" "$6" "$3" >\}\}\n\n$4}s;
    # the table of other tasks: one column with the command of the chosen assistant
    s{\| You want to \| Claude Code \| Tell another assistant to run \|\n\|[-|]+\|\n}{| You want to | Run |\n|-------------|-----|\n};
    s{^\| ([^|\n]+) \| `/([a-z-]+)` \| `xaden prompt ([a-z-]+)` \|$}{| $1 | \{\{< cmd "$2" "$3" >\}\} |}mg;
    # sentences
    s{In Claude Code, type `/xaden-release` for the checklist the assistant follows, including the security review before every release\. In any\nother assistant, tell it to run `xaden prompt release`\.}{For the checklist the assistant follows, including the security review before every release, use \{\{< cmd "xaden-release" "release" >\}\}.};
    s{In Claude Code, type\n`/xaden-feature <what users can do afterwards>`; in any other assistant, tell it to run `xaden prompt feature`\.}{Then start a feature with \{\{< cmd "xaden-feature" "feature" "<what users can do afterwards>" >\}\}.};
  '
}

# source_to_url <source file>: the site URL of a page generated from that file, or of a site page.
source_to_url() {
  local entry section page source target
  for entry in "${PAGES[@]}"; do
    IFS='|' read -r section page source _ <<<"$entry"
    [ "$source" = "$1" ] && { printf '/docs/%s/%s/' "$section" "$page"; return 0; }
  done
  for entry in "${SITE_TARGETS[@]}"; do
    IFS='|' read -r source target <<<"$entry"
    [ "$source" = "$1" ] && { printf '%s' "$target"; return 0; }
  done
  return 1
}

# resolve_path <directory> <relative path>: the path with "." and ".." segments folded away.
resolve_path() {
  perl -e 'my @out; for my $part (split m{/}, "$ARGV[0]/$ARGV[1]") { next if $part eq "" || $part eq "."; if ($part eq "..") { pop @out } else { push @out, $part } } print join("/", @out)' "$1" "$2"
}

# rewrite_links <source file>: from stdin, relative links between source files turned into site URLs.
# A link to a file that has no page fails the run.
rewrite_links() {
  local source=$1 dir text link target anchor url map
  dir="$(dirname "$source")"
  text="$(cat)"
  map="$(mktemp)"
  while IFS= read -r link; do
    [ -n "$link" ] || continue
    target="${link%%#*}"
    anchor=""
    case "$link" in *'#'*) anchor="#${link#*#}" ;; esac
    if ! url="$(source_to_url "$(resolve_path "$dir" "$target")")"; then
      [ "${SYNC_MAIN:-0}" = 1 ] || die "REQ-006: $source links to $link, which has no page on the site (add it to PAGES in scripts/sync-docs.sh)"
      warn "$source links to $link, which has no page on the site; the link stays as written in this preview"
      continue
    fi
    printf '%s\t%s\n' "$link" "$url$anchor" >>"$map"
  done < <(printf '%s\n' "$text" | grep -oE '\]\([^)#:]+\.md(#[^)]*)?\)' | sed -e 's/^](//' -e 's/)$//' | sort -u)
  # perl, not bash substitution: older bash keeps the quotes of a quoted replacement
  printf '%s\n' "$text" | perl -pe 'BEGIN { open my $fh, "<", $ARGV[0] or die; while (<$fh>) { chomp; my ($from, $to) = split /\t/; $m{$from} = $to } @ARGV = () } s/\]\(([^)]+)\)/exists $m{$1} ? "]($m{$1})" : $&/ge' "$map"
  rm -f "$map"
}

# render_page <section> <name> <source> <summary> <weight> <release dir>: writes one page.
render_page() {
  local section=$1 name=$2 source=$3 summary=$4 weight=$5 release=$6 title file
  file="$DOCS_DIR/$section/$name.md"
  [ -f "$release/$source" ] || die "REQ-006: $source is missing in the release"
  title="$(sed -n 's/^# \(.*\)$/\1/p' "$release/$source" | head -n 1)"
  [ -n "$title" ] || die "REQ-006: $source has no top-level heading"
  mkdir -p "$DOCS_DIR/$section"
  {
    printf -- '---\ntitle: "%s"\nweight: %s\ndescription: "%s"\n---\n\n' "$title" "$weight" "$summary"
    awk '!skipped && /^# / { skipped = 1; next } /^## Next$/ { exit } { print }' "$release/$source" |
      strip_shell_comments | if [ "$section" = contributing ]; then cat; else rewrite_for_readers; fi | assistant_commands | rewrite_links "$source"
  } >"$file"
  case "$source" in
    *kick-off-with-your-assistant.md|*build-features.md|*release-a-version.md|*join-a-project.md)
      grep -q '{{< \(prompt\|cmd\) ' "$file" ||
        die "REQ-022: $source has no assistant commands after the rewrite; its wording changed, update assistant_commands in scripts/sync-docs.sh" ;;
  esac
}

# section_is_newer_than_release <section> <release dir>: true when none of the section's source files is in the
# release, so a section added after that release does not fail the pinned release's render (a section with
# only some of its files still fails in render_page).
section_is_newer_than_release() {
  local entry entry_section source
  for entry in "${PAGES[@]}"; do
    IFS='|' read -r entry_section _ source _ <<<"$entry"
    [ "$entry_section" = "$1" ] || continue
    [ ! -f "$2/$source" ] || return 1
  done
  return 0
}

# check_every_guide_has_a_page <release dir>: a guide file without a page would be dropped silently.
check_every_guide_has_a_page() {
  local file entry known
  while IFS= read -r file; do
    known=0
    for entry in "${PAGES[@]}"; do
      case "$entry" in *"|$file|"*) known=1 ;; esac
    done
    [ "$known" = 1 ] && continue
    if [ "${SYNC_MAIN:-0}" = 1 ]; then add_preview_page "$file"; else die "REQ-006: $file of the release has no page; add it to PAGES in scripts/sync-docs.sh"; fi
  done < <(cd "$1" && find docs/guide -name '*.md' | LC_ALL=C sort)
}

# add_preview_page <guide file>: a preview of main must render even when the file is not in PAGES yet (REQ-006).
# Warns, and appends an entry derived from the path (section by folder, page name by file name); a folder the site
# has no section for is skipped with the same warning. A release build never gets here: it fails instead.
add_preview_page() {
  local file=$1 section
  case "$file" in
    docs/guide/developer/*) section=developer-guide ;;
    docs/guide/admin/*) section=admin-guide ;;
    docs/guide/contributing/*) section=contributing ;;
    *) warn "$file has no page and no section to put it in; add it to PAGES in scripts/sync-docs.sh"; return 0 ;;
  esac
  warn "$file is not in PAGES yet; the preview renders it as is. Add it to PAGES in scripts/sync-docs.sh before the release"
  PAGES+=("$section|$(basename "$file" .md)|$file|Preview of a page that is not in the page list yet.|unreleased")
}

# check_reference_covers_commands <release dir>: every command in `xaden help` has a heading in the
# Reference (REQ-002). Read from the usage text; no code of the release runs.
check_reference_covers_commands() {
  local command missing=""
  [ -f "$1/scripts/xaden.sh" ] || return 0
  while IFS= read -r command; do
    grep -rqE "^#{2,3} \`xaden $command" "$DOCS_DIR/reference" || missing="$missing $command"
  done < <(awk '/^usage\(\) \{/ { in_usage = 1 } in_usage && /<<.EOF.$/ { inside = 1; next } inside && /^EOF$/ { exit } inside && /^  [a-z]/ { print $1 }' "$1/scripts/xaden.sh" | sort -u)
  [ -z "$missing" ] && return 0
  if [ "${SYNC_MAIN:-0}" = 1 ]; then # a preview of main shows what is missing, a release build refuses
    warn "REQ-002: commands in 'xaden help' without a Reference entry:$missing (add a '## \`xaden <command>\`' heading to content/docs/reference/)"
    return 0
  fi
  die "REQ-002: commands in 'xaden help' without a Reference entry:$missing (add a '## \`xaden <command>\`' heading to content/docs/reference/)"
}

# use_local_source <checkout> <tag>: preview of unreleased docs. Extracts the local git tag from the
# checkout when it exists (a release prepared before it is published), else copies the working tree
# (uncommitted edits show) into the release folder. Prints "<version tag>|<date>". Never used in CI.
use_local_source() {
  local source=$1 tag=$2
  [ -z "${CI:-}" ] || die "REQ-006: XADEN_SOURCE is for local previews and is refused when CI is set"
  [ -f "$source/$GETTING_STARTED" ] || die "REQ-006: $source is not a Xaden checkout ($GETTING_STARTED or VERSION missing)"
  [ -f "$source/VERSION" ] || die "REQ-006: $source is not a Xaden checkout ($GETTING_STARTED or VERSION missing)"
  if [ "${SYNC_MAIN:-0}" != 1 ] && git -C "$source" rev-parse -q --verify "refs/tags/$tag^{commit}" >/dev/null 2>&1; then
    warn "PREVIEW of the local tag $tag from $source: content/docs/ is git-ignored, do not publish this build"
    git -C "$source" archive "$tag" | tar -x -C "$WORK_DIR/release"
    printf '%s|%s' "$tag" "$(git -C "$source" log -1 --format=%as "$tag")"
    return
  fi
  warn "PREVIEW of unreleased files from $source (no local tag $tag, or --main): content/docs/ is git-ignored, do not publish this build"
  tar -C "$source" --exclude=./.git --exclude=./inbox --exclude=./node_modules --exclude=./worktrees -cf - . |
    tar -x -C "$WORK_DIR/release"
  printf 'v%s|%s' "$(tr -d '[:space:]' <"$source/VERSION")" "$(date +%F)"
}

# page_is_not_in_release <flag> <release dir> <source>: true for a page marked "unreleased" whose source the
# release does not have yet; every other missing source still fails in render_page.
# A preview of main (SYNC_MAIN) also skips a listed page whose source main removed or moved.
page_is_not_in_release() { { [ "$1" = unreleased ] || [ "${SYNC_MAIN:-0}" = 1 ]; } && [ ! -f "$2/$3" ]; }

main() {
  if [ "${1:-}" = "--main" ]; then
    shift
    export SYNC_MAIN=1
    XADEN_SOURCE="${XADEN_SOURCE:-$ROOT/../code}"
  fi
  local tag="${1:-v$(xaden_version "$(tr -d '[:space:]' <"$ROOT/VERSION")")}" date entry section page source summary flag weight=0 preview=false skipped=""
  mkdir "$WORK_DIR/release"
  if [ -n "${XADEN_SOURCE:-}" ]; then
    entry="$(use_local_source "$XADEN_SOURCE" "$tag")"
    tag="${entry%%|*}"
    date="${entry#*|}"
    preview=true
  else
    printf '%s' "$tag" | grep -Eq '^v[0-9]+\.[0-9]+\.[0-9]+$' || die "REQ-006: '$tag' is not a release tag like v1.2.3"
    has_command curl || die "curl not found"
    info "download $XADEN_REPOSITORY $tag"
    curl -fsSL "https://github.com/$XADEN_REPOSITORY/archive/refs/tags/$tag.tar.gz" |
      tar -xz -C "$WORK_DIR/release" --strip-components=1
    [ -f "$WORK_DIR/release/$GETTING_STARTED" ] || die "REQ-006: $GETTING_STARTED is missing in the $tag release"
    date="$(release_date "$tag")"
    [ -n "$date" ] || die "REQ-006: could not read the release date of $tag"
  fi
  [ -d "$WORK_DIR/release/docs/guide" ] || die "REQ-006: docs/guide/ is missing in the $tag release; use a release that has the guides"
  check_every_guide_has_a_page "$WORK_DIR/release"
  # everything generated goes; the hand-written _index.md files stay
  find "$DOCS_DIR/developer-guide" "$DOCS_DIR/admin-guide" "$DOCS_DIR/contributing" -type f ! -name '_index.md' -delete 2>/dev/null || true
  for entry in "${PAGES[@]}"; do
    IFS='|' read -r section page source summary flag <<<"$entry"
    weight=$((weight + 10))
    if section_is_newer_than_release "$section" "$WORK_DIR/release"; then
      case " $skipped " in *" $section "*) ;; *) warn "the $tag release has no $section pages yet; that section stays empty until a release carries them"; skipped="$skipped $section" ;; esac
      continue
    fi
    if page_is_not_in_release "$flag" "$WORK_DIR/release" "$source"; then
      warn "$source is not in the $tag docs (unreleased, or removed on main); its page is skipped"
      continue
    fi
    render_page "$section" "$page" "$source" "$summary" "$weight" "$WORK_DIR/release"
  done
  check_reference_covers_commands "$WORK_DIR/release"
  mkdir -p "$ROOT/data"
  printf 'tag: "%s"\ndate: "%s"\npreview: %s\n' "$tag" "$date" "$preview" >"$ROOT/data/release.yaml"
  info "docs of $tag rendered: ${#PAGES[@]} pages"
}

# sourced by tests/sync-docs-local.sh, which calls the functions without running a render
[ "${BASH_SOURCE[0]}" != "$0" ] || main "$@"

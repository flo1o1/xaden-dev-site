#!/usr/bin/env bash
# Builds the site with Hugo and checks the output against the site's quality goals:
#   REQ-011  no reference to another origin, no inline script
#   REQ-012  every page carries the Content-Security-Policy meta tag
#   REQ-009  security.txt has Contact and Expires, and Expires is at least 60 days away
#   REQ-024  every entry of the credits page has a link and a license; footer, About and the fonts carry the credits
# Usage: scripts/check-site.sh   (needs hugo, extended build, and the tailwindcss CLI v4 on PATH)
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPTS/.." && pwd)"
# shellcheck source=SCRIPTDIR/lib.sh
source "$SCRIPTS/lib.sh"

OWN_ORIGIN="https://xaden.dev"
# Namespace identifiers inside generated XML/HTML; they are names, not requests.
NAMESPACE_URIS="http://www.w3.org/1999/xhtml http://www.sitemaps.org/schemas/sitemap/0.9"
SECURITY_TXT_MIN_DAYS=60
OUTPUT_DIR="$(mktemp -d)"
trap 'rm -rf "$OUTPUT_DIR"' EXIT

# build_site: renders the site into OUTPUT_DIR; fails on any Hugo warning-level error.
build_site() {
  has_command hugo || die "hugo not found (extended build, see .github/workflows/ci.yml for the pinned version)"
  "$SCRIPTS/build-css.sh" >/dev/null
  (cd "$ROOT" && hugo --gc --minify --panicOnWarning --destination "$OUTPUT_DIR" >/dev/null)
}

# list_origin_references: prints every http(s) URL a browser would request. In HTML that is
# the value of a src, href, action, poster, srcset or data attribute outside plain links
# (<a href>), so URLs shown as text or code are not requests; in CSS, JS, JSON and XML any URL
# counts. Fonts are not read: their embedded licence metadata names URLs no browser requests. Neither are the OFL texts
# next to them (fonts/LICENSE-*.txt): they name the license and project URLs as text for readers (REQ-024).
list_origin_references() {
  find "$OUTPUT_DIR" -name '*.html' -exec sed -E 's/<a [^>]*>//g' {} + |
    grep -hoE '(src|href|action|poster|srcset|data)=("[^"]*"|[^ >]*)' |
    grep -oE 'https?://[^"'"'"' )<>]+' || true
  grep -rhoE 'https?://[^"'"'"' )<>]+' "$OUTPUT_DIR" \
    --include='*.css' --include='*.xml' --include='*.txt' --include='*.js' --include='*.json' --exclude='LICENSE-*.txt' || true
}

# check_no_foreign_origins: REQ-011.
check_no_foreign_origins() {
  local url foreign=""
  while IFS= read -r url; do
    case "$url" in
      "$OWN_ORIGIN"*) ;;
      *)
        case " $NAMESPACE_URIS " in
          *" $url "*) ;;
          *) foreign="$foreign $url" ;;
        esac
        ;;
    esac
  done < <(list_origin_references | sort -u)
  [ -z "$foreign" ] || die "REQ-011: the built site refers to other origins:$foreign"
}

# check_no_inline_script: REQ-012, only script files from the site itself are allowed
# (the policy says script-src 'self'); any inline script or event handler fails.
check_no_inline_script() {
  if grep -rhoE '<script[^>]*>' "$OUTPUT_DIR" --include='*.html' | grep -qv 'src='; then
    die "REQ-012: a built page contains an inline <script>"
  fi
  if grep -rlE '[[:space:]]on[a-z]+=' "$OUTPUT_DIR" --include='*.html' | grep -q .; then
    die "REQ-012: a built page contains an inline event handler"
  fi
}

# check_assistant_variants: REQ-022, a page that offers per-assistant commands has them for every assistant
# of data/assistants.yaml, so no reader meets a page without the commands of their tool.
check_assistant_variants() {
  local page id missing=""
  while IFS= read -r page; do
    while IFS= read -r id; do
      grep -q "data-assistant=\"$id\"" "$page" || missing="$missing
$page: no commands for $id"
    done < <(sed -n 's/^- id: //p' "$ROOT/data/assistants.yaml")
  done < <(grep -rl 'class="assistant-variant"' "$OUTPUT_DIR" --include='*.html')
  [ -z "$missing" ] || die "REQ-022: a page lacks the commands of an assistant:$missing"
}

# check_content_security_policy: REQ-012, every HTML page carries the meta tag.
check_content_security_policy() {
  local page missing=""
  while IFS= read -r page; do
    grep -q 'http-equiv=Content-Security-Policy' "$page" || grep -q 'http-equiv="Content-Security-Policy"' "$page" ||
      missing="$missing ${page#"$OUTPUT_DIR"/}"
  done < <(find "$OUTPUT_DIR" -name '*.html')
  [ -z "$missing" ] || die "REQ-012: pages without Content-Security-Policy:$missing"
}

# days_from_today <n>: the date n days ahead as YYYY-MM-DD (BSD date on macOS, GNU date on Linux).
days_from_today() { date -v+"$1"d +%F 2>/dev/null || date -d "+$1 days" +%F; }

# check_security_txt: REQ-009 (RFC 9116: Contact and Expires are required).
check_security_txt() {
  local file="$OUTPUT_DIR/.well-known/security.txt" expires limit
  [ -f "$file" ] || die "REQ-009: .well-known/security.txt is missing"
  grep -q '^Contact: ' "$file" || die "REQ-009: security.txt has no Contact field"
  expires="$(sed -n 's/^Expires: \([0-9-]\{10\}\).*/\1/p' "$file")"
  [ -n "$expires" ] || die "REQ-009: security.txt has no Expires field"
  limit="$(days_from_today "$SECURITY_TXT_MIN_DAYS")"
  [ "$expires" \> "$limit" ] || die "REQ-009: security.txt expires on $expires; renew it (needs at least $SECURITY_TXT_MIN_DAYS days, i.e. after $limit)"
}

# check_docs_have_no_internal_references: REQ-002, readers have not seen the Xaden repository. Contributing is
# the exception: its readers work in that repository, so its pages name rule IDs and paths.
check_docs_have_no_internal_references() {
  local found
  found="$(grep -rnE 'REQ-[0-9]+|CC-[0-9]+|§|template/' "$OUTPUT_DIR/docs" --include='*.html' --exclude-dir=contributing | cut -c1-160 | head -n 5 || true)"
  [ -z "$found" ] || die "REQ-002: docs pages hold rule IDs, section references or repository paths (extend rewrite_for_readers in scripts/sync-docs.sh):
$found"
}

# check_docs_prefer_xaden: REQ-002, the xaden command comes first wherever it exists. Contributing is exempt: its
# readers maintain Xaden and run the repository's own scripts.
check_docs_prefer_xaden() {
  local found
  found="$(grep -rnoE 'scripts/(new-project|update-scaffold|setup|check|req|pack-context|release)\.sh' "$OUTPUT_DIR/docs" --include='*.html' --exclude-dir=contributing | head -n 5 || true)"
  [ -z "$found" ] || die "REQ-002: docs pages show a script where the xaden command exists (extend prefer_xaden_command in scripts/sync-docs.sh):
$found"
}

# check_credits: REQ-024. Every list entry of content/about/credits.md reads "- [Name](https://...): <license>. ..." with a
# license from CREDIT_LICENSES; the footer and the About page link to it; every font has a license file next to it.
CREDIT_LICENSES='MIT|Apache-2\.0|GPL-3\.0|LGPL-2\.1|MPL-2\.0|BSD-3-Clause|ISC|CC BY-SA 4\.0|CC BY 4\.0|CC BY 3\.0|SIL OFL 1\.1'
check_credits() {
  local page="$ROOT/content/about/credits.md" bad font entries
  [ -f "$page" ] || die "REQ-024: content/about/credits.md is missing"
  entries="$(grep -c '^- \[' "$page" || true)"
  [ "$entries" -gt 0 ] || die "REQ-024: the credits page lists no entry"
  bad="$(grep '^- \[' "$page" | grep -Ev "^- \[[^]]+\]\(https://[^)]+\): ($CREDIT_LICENSES)[. ]" || true)"
  [ -z "$bad" ] || die "REQ-024: credits entries without a link or a known license (form: - [Name](https://...): MIT. note):
$bad"
  grep -Eq 'href="?/about/credits/' "$OUTPUT_DIR/index.html" || die "REQ-024: the footer does not link to the credits page"
  grep -Eq 'href="?/about/credits/' "$OUTPUT_DIR/about/index.html" || die "REQ-024: the About page does not link to the credits page"
  for font in "$OUTPUT_DIR"/fonts/*.woff2; do
    ls "$OUTPUT_DIR"/fonts/LICENSE-*.txt >/dev/null 2>&1 || die "REQ-024: fonts are served without a license file next to them"
    [ -e "$font" ] || break
  done
  grep -q 'Copyright' "$OUTPUT_DIR"/fonts/LICENSE-*.txt || die "REQ-024: a font license file has no copyright line"
}

# check_rule_file: Xaden REQ-112, this repository's rule file says the user merges and the site's main mirrors Xaden's main.
check_rule_file() {
  grep -q 'the user merges' "$SCRIPTS/../CLAUDE.md" || die "Xaden REQ-112: CLAUDE.md no longer says the user merges"
  grep -q "must show what Xaden's .main. does" "$SCRIPTS/../CLAUDE.md" || die "Xaden REQ-112: CLAUDE.md no longer says the site's main mirrors Xaden's main"
}

# check_internal_links: REQ-002, every link to a page of this site, and every #anchor in one, resolves.
check_internal_links() {
  local broken
  broken="$(perl -MFile::Find -e '
    my ($root, %ids, %pages) = ($ARGV[0]);
    find(sub { return unless /\.html$/; my $rel = $File::Find::name; $rel =~ s/^\Q$root\E//; $rel =~ s/index\.html$//;
      open my $fh, "<", $_ or die; local $/; my $html = <$fh>; $pages{$rel} = $html; $ids{$rel}{$1} = 1 while $html =~ /\sid="?([^"\s>]+)/g }, $root);
    my %seen;
    for my $page (sort keys %pages) {
      while ($pages{$page} =~ /href="?(\/[^"\s>#]*)(#[^"\s>]*)?/g) {
        my ($path, $anchor) = ($1, $2); next if $path =~ m{^/(img|css|js|\.well-known|fonts|CNAME)} || $path =~ /\.[a-z0-9]+$/;
        my $key = exists $pages{$path} ? $path : "$path/"; $key =~ s{//$}{/};
        my $problem = !exists $pages{$key} ? "page missing" : ($anchor && !$ids{$key}{substr($anchor, 1)}) ? "anchor missing" : next;
        print "$page -> $path" . ($anchor // "") . " ($problem)\n" unless $seen{"$path$anchor$problem"}++;
      }
    }' "$OUTPUT_DIR" | head -n 10)"
  [ -z "$broken" ] || die "REQ-002: broken internal links:
$broken"
}

main() {
  info "build"
  build_site
  info "no other origins (REQ-011)"
  check_no_foreign_origins
  info "no inline script (REQ-012)"
  check_no_inline_script
  info "Content-Security-Policy on every page (REQ-012)"
  check_content_security_policy
  info "commands for every assistant (REQ-022)"
  check_assistant_variants
  info "docs without internal references (REQ-002)"
  check_docs_have_no_internal_references
  info "docs use the xaden command (REQ-002)"
  check_docs_prefer_xaden
  info "internal links and anchors (REQ-002)"
  check_internal_links
  info "security.txt (REQ-009)"
  check_security_txt
  info "rule file (Xaden REQ-112)"
  check_rule_file
  info "credits and licenses (REQ-024)"
  check_credits
  info "site checks passed"
}

main "$@"

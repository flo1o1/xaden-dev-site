#!/usr/bin/env bash
# Tests the local-preview guards of scripts/sync-docs.sh (REQ-006). Usage: tests/sync-docs-local.sh
# The refusals happen before any download or write, so no network and no Xaden checkout are needed.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# expect_refusal <description> <expected text> <env assignment...>: sync-docs.sh must fail with the text.
expect_refusal() {
  local description=$1 text=$2 output
  shift 2
  if output="$(env "$@" "$ROOT/scripts/sync-docs.sh" 2>&1)"; then
    printf 'FAIL: %s: the script succeeded\n' "$description" >&2; exit 1
  fi
  grep -q "$text" <<<"$output" || { printf 'FAIL: %s: expected "%s" in:\n%s\n' "$description" "$text" "$output" >&2; exit 1; }
  printf 'ok: %s\n' "$description"
}

mkdir "$WORK/not-xaden"
expect_refusal "local source is refused in CI" "refused when CI is set" CI=true XADEN_SOURCE="$WORK/not-xaden"
expect_refusal "a folder that is not a Xaden checkout is refused" "is not a Xaden checkout" -u CI XADEN_SOURCE="$WORK/not-xaden"
expect_refusal "a missing folder is refused" "is not a Xaden checkout" -u CI XADEN_SOURCE="$WORK/missing"

# A checkout with a local tag: the tag is rendered, not the working tree. The fixture has no guides, so
# the run stops after choosing the source, which is all this test needs (no network).
git init -q "$WORK/xaden"
printf '# Getting started\n' >"$WORK/xaden/GETTING-STARTED.md"
printf '0.0.1\n' >"$WORK/xaden/VERSION"
git -C "$WORK/xaden" add -A
git -C "$WORK/xaden" -c user.name=t -c user.email=t@example.com commit -q -m init
pinned="v$(tr -d '[:space:]' <"$ROOT/VERSION" | sed 's/-.*//')"
expect_refusal "without the pinned tag the working tree is rendered" "no local tag $pinned" -u CI XADEN_SOURCE="$WORK/xaden"
git -C "$WORK/xaden" tag "$pinned"
expect_refusal "the pinned tag is rendered from the checkout's git" "PREVIEW of the local tag $pinned" -u CI XADEN_SOURCE="$WORK/xaden"
# --main renders the working tree even though the pinned tag exists in the checkout
output="$(env -u CI XADEN_SOURCE="$WORK/xaden" "$ROOT/scripts/sync-docs.sh" --main 2>&1 || true)"
grep -q "PREVIEW of unreleased files" <<<"$output" || { printf 'FAIL: --main did not render the working tree:\n%s\n' "$output" >&2; exit 1; }
printf 'ok: --main renders the working tree even when the pinned tag exists\n'

# An "unreleased" page of PAGES (one Xaden's main has and the pinned release lacks) is skipped with a warning only
# while its source is missing, so --main always renders; a page without the mark still fails (REQ-006).
# shellcheck source=SCRIPTDIR/../scripts/sync-docs.sh
source "$ROOT/scripts/sync-docs.sh"
mkdir -p "$WORK/release/docs"
printf '# T\n' >"$WORK/release/docs/present.md"
page_is_not_in_release unreleased "$WORK/release" docs/missing.md || { printf 'FAIL: an unreleased page without a source is not skipped\n' >&2; exit 1; }
printf 'ok: an unreleased page without a source is skipped\n'
! page_is_not_in_release unreleased "$WORK/release" docs/present.md || { printf 'FAIL: an unreleased page with a source is skipped\n' >&2; exit 1; }
printf 'ok: an unreleased page with a source is rendered\n'
! page_is_not_in_release "" "$WORK/release" docs/missing.md || { printf 'FAIL: a page without the mark is skipped, so a missing source would pass silently\n' >&2; exit 1; }
printf 'ok: a page without the mark is never skipped\n'
grep -q '|unreleased"$' "$ROOT/scripts/sync-docs.sh" || printf 'note: no page is marked unreleased now\n'

# A preview of main (SYNC_MAIN=1) always renders (REQ-006): an unlisted guide file gets an entry derived from its path,
# a command without a Reference entry and a link to an unknown page only warn, a removed page is skipped. A release build
# (SYNC_MAIN unset) still fails on each, so nothing is dropped silently on a published site.
mkdir -p "$WORK/main/docs/guide/developer" "$WORK/main/scripts"
printf '# Brand new\n' >"$WORK/main/docs/guide/developer/brand-new.md"
printf 'usage() {\n  cat <<'"'"'EOF'"'"'\n  zzz-undocumented-command  does something\nEOF\n}\n' >"$WORK/main/scripts/xaden.sh"
if (check_every_guide_has_a_page "$WORK/main") >/dev/null 2>&1; then printf 'FAIL: a release build accepted an unlisted guide file\n' >&2; exit 1; fi
printf 'ok: a release build still fails on an unlisted guide file\n'
pages_before=${#PAGES[@]}
output="$(SYNC_MAIN=1 check_every_guide_has_a_page "$WORK/main" 2>&1)"
grep -q "brand-new.md is not in PAGES yet" <<<"$output" || { printf 'FAIL: no warning for an unlisted guide file:\n%s\n' "$output" >&2; exit 1; }
SYNC_MAIN=1 check_every_guide_has_a_page "$WORK/main" 2>/dev/null
[ "${#PAGES[@]}" -gt "$pages_before" ] && printf '%s\n' "${PAGES[@]}" | grep -q '^developer-guide|brand-new|docs/guide/developer/brand-new.md|.*|unreleased$' ||
  { printf 'FAIL: the unlisted guide file got no derived entry\n' >&2; exit 1; }
printf 'ok: --main gives an unlisted guide file a derived entry and warns\n'
output="$(SYNC_MAIN=1 check_reference_covers_commands "$WORK/main" 2>&1)" || { printf 'FAIL: --main died on a command without a Reference entry\n' >&2; exit 1; }
grep -q "zzz-undocumented-command" <<<"$output" || { printf 'FAIL: no warning naming the undocumented command:\n%s\n' "$output" >&2; exit 1; }
printf 'ok: --main only warns about a command without a Reference entry\n'
if (check_reference_covers_commands "$WORK/main") >/dev/null 2>&1; then printf 'FAIL: a release build accepted a command without a Reference entry\n' >&2; exit 1; fi
printf 'ok: a release build still fails on a command without a Reference entry\n'
SYNC_MAIN=1 page_is_not_in_release "" "$WORK/release" docs/missing.md || { printf 'FAIL: --main did not skip a page whose source is gone\n' >&2; exit 1; }
printf 'ok: --main skips a listed page whose source is gone\n'

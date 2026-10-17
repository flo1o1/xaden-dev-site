#!/usr/bin/env bash
# Tests the site release cycle (REQ-023): version order, scripts/release-site.sh and scripts/check-release-tag.sh
# on a throwaway repository. No network. Usage: tests/release-site.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=SCRIPTDIR/../scripts/lib.sh
source "$ROOT/scripts/lib.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.com GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.com

# expect <description> <expected> <actual>
expect() {
  [ "$2" = "$3" ] || { printf 'FAIL: %s: expected "%s", got "%s"\n' "$1" "$2" "$3" >&2; exit 1; }
  printf 'ok: %s\n' "$1"
}
# expect_failure <description> <text> <command...>: the command fails and says the text.
expect_failure() {
  local description=$1 text=$2 output
  shift 2
  if output="$("$@" 2>&1)"; then printf 'FAIL: %s: succeeded\n' "$description" >&2; exit 1; fi
  grep -q -- "$text" <<<"$output" || { printf 'FAIL: %s: expected "%s" in:\n%s\n' "$description" "$text" "$output" >&2; exit 1; }
  printf 'ok: %s\n' "$description"
}

# versions and their order
expect "next sequence of a plain version" "0.4.0-0001" "$(next_sequence 0.4.0)"
expect "next sequence of a sequence" "0.4.0-0010" "$(next_sequence 0.4.0-0009)"
expect "a sequence sorts above its release" "v0.4.0-0001" "$(printf 'v0.4.0\nv0.4.0-0001\nv0.3.9\n' | newest_site_tag)"
expect "a higher release beats any sequence" "v0.5.0" "$(printf 'v0.4.0-0009\nv0.5.0\nv0.4.0\n' | newest_site_tag)"
expect "numbers compare as numbers" "v0.10.0" "$(printf 'v0.9.0\nv0.10.0\nv0.2.0\n' | newest_site_tag)"
expect "other tags are ignored" "v1.0.0" "$(printf 'v1.0.0\nv2.0.0-rc1\nlatest\n' | newest_site_tag)"
version_is_higher 0.4.0-0001 0.4.0 && version_is_higher 0.5.0 0.4.0-0003 && ! version_is_higher 0.4.0 0.4.0 && ! version_is_higher 0.4.0 0.4.0-0001
echo "ok: version_is_higher"

# a repository with the release scripts and a docs sync that does nothing
mkdir -p "$WORK/site/scripts"
cp "$ROOT/scripts/lib.sh" "$ROOT/scripts/release-site.sh" "$ROOT/scripts/check-release-tag.sh" "$WORK/site/scripts/"
printf '#!/bin/sh\nexit 0\n' >"$WORK/site/scripts/sync-docs.sh" && chmod +x "$WORK/site/scripts/sync-docs.sh"
printf '0.4.0\n' >"$WORK/site/VERSION"
printf '# Changelog\n\n## [Unreleased]\n\n- a fix\n\n## [0.4.0] - 2026-01-01\n\n- old\n' >"$WORK/site/CHANGELOG.md"
git init -q -b main "$WORK/site" && git -C "$WORK/site" add -A && git -C "$WORK/site" commit -q -m "chore: init"
printf 'v0.4.0\nv0.5.0\n' >"$WORK/xaden-tags"
release() { (cd "$WORK/site" && XADEN_TAG_LIST="$WORK/xaden-tags" scripts/release-site.sh "$@"); }

expect_failure "a Xaden version without a Xaden tag is refused" "Xaden has no release tag v0.6.0" release 0.6.0
expect_failure "a version that is not higher is refused" "not higher" release 0.4.0
expect_failure "a bad argument is refused" "usage" release 0.5
release republish >/dev/null
expect "republish sets the next sequence" "0.4.0-0001" "$(tr -d '[:space:]' <"$WORK/site/VERSION")"
expect "the release is one commit" "chore(release): site v0.4.0-0001" "$(git -C "$WORK/site" log -1 --format=%s)"
grep -q '^## \[0.4.0-0001\] - ' "$WORK/site/CHANGELOG.md" && echo "ok: the changelog is stamped"
expect_failure "an empty Unreleased section is refused" "has no entry" release republish
expect "a refused release leaves VERSION alone" "0.4.0-0001" "$(tr -d '[:space:]' <"$WORK/site/VERSION")"
printf -- '- new page\n' >"$WORK/entry" && sed -i.bak '/^## \[Unreleased\]/r '"$WORK/entry" "$WORK/site/CHANGELOG.md" && rm "$WORK/site/CHANGELOG.md.bak"
git -C "$WORK/site" commit -q -am "docs: entry"
release 0.5.0 >/dev/null
expect "a new Xaden release sets its version" "0.5.0" "$(tr -d '[:space:]' <"$WORK/site/VERSION")"

# the tag check: main is the local branch here
check_tag() { (cd "$WORK/site" && MAIN_REF=main scripts/check-release-tag.sh "$@"); }
git -C "$WORK/site" tag v0.5.0
check_tag v0.5.0 >/dev/null && echo "ok: the newest tag on main may publish"
expect_failure "a tag that differs from VERSION is refused" "does not match VERSION" check_tag v0.4.0
git -C "$WORK/site" tag v0.4.0 HEAD~2
expect_failure "an older tag is refused" "does not match VERSION" check_tag v0.4.0
printf '0.4.0\n' >"$WORK/site/VERSION" && git -C "$WORK/site" commit -q -am "chore: back"
expect_failure "a tag that is not the newest is refused" "not the newest" check_tag v0.4.0
expect_failure "a bad tag name is refused" "not a site release tag" check_tag latest
git -C "$WORK/site" checkout -q -b side && printf '0.5.0-0001\n' >"$WORK/site/VERSION" && git -C "$WORK/site" commit -q -am "chore: side" && git -C "$WORK/site" tag v0.5.0-0001
expect_failure "a tag whose commit is not on main is refused" "not on main" check_tag v0.5.0-0001

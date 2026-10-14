#!/usr/bin/env bash
# Tests scripts/bump-docs-version.sh against fixed tag lists (REQ-006). Usage: tests/bump-docs-version.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# run_bump <current pin> <tag...>: copies the script, pins <current>, prints "<stdout>|<pin after>".
run_bump() {
  local current="$1" out
  shift
  mkdir -p "$WORK/scripts"
  cp "$ROOT/scripts/bump-docs-version.sh" "$ROOT/scripts/lib.sh" "$WORK/scripts/"
  printf '%s\n' "$current" >"$WORK/XADEN_DOCS_VERSION"
  printf '%s\n' "$@" >"$WORK/tags.txt"
  out="$("$WORK/scripts/bump-docs-version.sh" "$WORK/tags.txt")" || return 1
  printf '%s|%s' "$out" "$(tr -d '[:space:]' <"$WORK/XADEN_DOCS_VERSION")"
}

expect() {
  [ "$2" = "$3" ] || { printf 'FAIL: %s: expected "%s", got "%s"\n' "$1" "$3" "$2" >&2; exit 1; }
  printf 'ok: %s\n' "$1"
}

expect "newer tag is pinned and printed" "$(run_bump v0.2.2 v0.2.0 v0.3.0)" "v0.3.0|v0.3.0"
expect "tags compare numerically, not as text" "$(run_bump v0.2.2 v0.2.2 v0.2.10)" "v0.2.10|v0.2.10"
expect "current pin prints nothing" "$(run_bump v0.2.2 v0.2.1 v0.2.2)" "|v0.2.2"
expect "pre-release and malformed tags are ignored" "$(run_bump v0.2.2 v0.2.2 v0.3.0-rc1 latest v1)" "|v0.2.2"
if run_bump v0.2.2 latest >/dev/null 2>&1; then echo "FAIL: no release tag must fail" >&2; exit 1; fi
echo "ok: no release tag fails"

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

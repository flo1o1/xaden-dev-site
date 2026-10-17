#!/usr/bin/env bash
# Shared helpers for scripts in this repo. Source it; do not execute it.
# Portable on Linux and macOS (bash >= 3.2, POSIX sed/awk/tar only).

# Check results: every check is passed, failed or skipped; finish_checks reports them.
FAILURES=0
CHECKS_PASSED=0
SKIPPED_CHECKS=""
# "1" makes a missing tool a failure instead of a skipped check.
STRICT="${STRICT:-0}"

info() { printf '==> %s\n' "$*"; }
# tip <text>: names an optional tool that fits this project (REQ-051); never changes a result.
tip() { printf 'TIP: %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# has_command <name>: true if <name> is on PATH.
has_command() { command -v "$1" >/dev/null 2>&1; }

# record_missing_tool <label> <binary>: a check whose tool is missing is skipped (reported
# as INCOMPLETE), or failed when STRICT=1.
record_missing_tool() {
  if [ "$STRICT" = "1" ]; then
    warn "required tool missing: $2 ($1)"
    FAILURES=$((FAILURES + 1))
  else
    warn "SKIPPED $1: '$2' not installed"
    SKIPPED_CHECKS="$SKIPPED_CHECKS${SKIPPED_CHECKS:+, }$1"
  fi
}

# run_tool <label> <binary> [args...]: runs one check and records passed or failed;
# a missing binary is recorded by record_missing_tool.
run_tool() {
  local label=$1 binary=$2
  shift 2
  if ! has_command "$binary"; then
    record_missing_tool "$label" "$binary"
    return 0
  fi
  info "$label"
  if "$binary" "$@"; then
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
  else
    warn "$label failed"
    FAILURES=$((FAILURES + 1))
  fi
}

# finish_checks: prints the summary and exits. Failures exit 1. Skipped checks never count
# as passed: the run is reported INCOMPLETE (exit 0 locally; --strict turns skips into failures).
finish_checks() {
  printf '==> summary: %d passed, %d failed, skipped: %s\n' \
    "$CHECKS_PASSED" "$FAILURES" "${SKIPPED_CHECKS:-none}"
  [ "$FAILURES" -eq 0 ] || die "$FAILURES check(s) failed"
  if [ -n "$SKIPPED_CHECKS" ]; then
    warn "INCOMPLETE: not all checks ran. Install the missing tools, or use --strict to require them."
    exit 0
  fi
  info "all checks passed"
}

# --- site versions (REQ-023) -------------------------------------------------------------------
# A site version is X.Y.Z (the Xaden release the docs describe) or X.Y.Z-NNNN (a re-publish).

SITE_VERSION_PATTERN='^[0-9]+\.[0-9]+\.[0-9]+(-[0-9]{4})?$'

# is_site_version <string>: true for X.Y.Z and X.Y.Z-NNNN.
is_site_version() { printf '%s' "$1" | grep -Eq "$SITE_VERSION_PATTERN"; }

# xaden_version <site version>: the Xaden release it describes (X.Y.Z).
xaden_version() { printf '%s' "${1%%-*}"; }

# version_key <site version>: X.Y.Z.N for numeric sorting; no sequence counts as 0.
version_key() {
  local sequence=0
  case "$1" in *-*) sequence=$((10#${1#*-})) ;; esac
  printf '%s.%s' "$(xaden_version "$1")" "$sequence"
}

# version_is_higher <a> <b>: true when site version a is above b (X, then Y, Z, then the sequence).
version_is_higher() {
  [ "$(version_key "$1")" != "$(version_key "$2")" ] &&
    [ "$(printf '%s\n%s\n' "$(version_key "$1")" "$(version_key "$2")" | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n | tail -n 1)" = "$(version_key "$1")" ]
}

# newest_site_tag: from stdin, the highest vX.Y.Z[-NNNN] (other lines are ignored).
newest_site_tag() {
  grep -E '^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9]{4})?$' | sed 's/^v//' |
    while IFS= read -r version; do printf '%s %s\n' "$(version_key "$version")" "$version"; done |
    sort -t. -k1,1n -k2,2n -k3,3n -k4,4n | tail -n 1 | awk '{ print "v" $2 }'
}

# next_sequence <site version>: the re-publish after it (0.4.0 -> 0.4.0-0001, 0.4.0-0001 -> 0.4.0-0002).
next_sequence() {
  local current=$1 number
  number="$(version_key "$current")"
  number=$((10#${number##*.} + 1))
  [ "$number" -le 9999 ] || die "REQ-023: no sequence left after $current"
  printf '%s-%04d' "$(xaden_version "$current")" "$number"
}

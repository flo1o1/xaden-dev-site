#!/usr/bin/env bash
# Static analysis: shellcheck on the scripts, gitleaks on the git history.
# Usage: scripts/check.sh [--strict]   (--strict: a missing tool is a failure, not a skipped check)
# The site itself is checked by scripts/check-site.sh.
set -euo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/lib.sh
source "$SCRIPTS/lib.sh"

for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    *) die "unknown option: $arg (usage: scripts/check.sh [--strict])" ;;
  esac
done
cd "$SCRIPTS/.."

run_tool "shellcheck" shellcheck -x scripts/*.sh scripts/hooks/commit-msg tests/*.sh
run_tool "secret scan (gitleaks)" gitleaks git --no-banner --redact --log-level warn .

finish_checks

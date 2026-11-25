#!/bin/bash
# Runs the repo's checks in one folder and prints one verdict per check, so that no log reaches the conversation.
#   bash check.sh <folder> [<checks file>]
#
# The checks file (by default <repo>-lanes/.lead/checks) has one check per line, "label: command":
#   types: npx tsc --noEmit
#   tests: bash /path/to/locked.sh tests npm test
# Empty lines and lines starting with # are skipped. Each command runs in the folder; its whole output goes to
# <repo>-lanes/.lead/logs/<folder name>-<label>.log, and only the last lines of a failed check are printed.
# It exits with the number of failed checks.
folder="${1:?usage: check.sh <folder> [<checks file>]}"
cd "$folder" || { echo "check.sh: no folder $folder" >&2; exit 99; }

root="$(git worktree list --porcelain | sed -n '1s/^worktree //p')"
lead="$(dirname "$root")/$(basename "$root")-lanes/.lead"
checks="${2:-$lead/checks}"
[ -f "$checks" ] || { echo "check.sh: no checks file at $checks" >&2; exit 99; }
mkdir -p "$lead/logs"

failed=0
number=0
while IFS= read -r line || [ -n "$line" ]; do
  number=$((number + 1))
  case "$line" in ""|\#*) continue ;; esac
  if ! printf '%s\n' "$line" | grep -Eq '^[A-Za-z0-9_-]+: .'; then
    echo "check.sh: line $number of $checks is not \"label: command\" (a label of letters, digits, - or _)" >&2
    exit 99
  fi
  label="${line%%:*}"
  command="${line#*: }"
  log="$lead/logs/$(basename "$folder")-$label.log"
  if bash -c "$command" > "$log" 2>&1 < /dev/null; then
    echo "$label=ok"
  else
    echo "$label=FAILED (exit $?), log: $log"
    tail -n 15 "$log" | sed 's/^/    /'
    failed=$((failed + 1))
  fi
done < "$checks"

exit "$failed"

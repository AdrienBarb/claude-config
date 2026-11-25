#!/bin/bash
# Runs a command while holding a named lock, so that one lane at a time uses what the lanes share: a test
# database, a build cache, anything two runs at once would break. The others wait their turn.
#   bash locked.sh <lock name> <command> [arguments...]        run from inside the repo or one of its lanes
#
# The lock lives in <repo>-lanes/.lead/locks, the one folder every lane of a repo shares. A lock left by a process
# that died is taken over. It waits as long as the lock is held, and says once that it waits: give the call a
# timeout long enough for the runs queued before it.
name="${1:?usage: locked.sh <lock name> <command> [arguments...]}"
shift
[ "$#" -gt 0 ] || { echo "locked.sh: no command given" >&2; exit 2; }
case "$name" in */*|"") echo "locked.sh: the lock name must be one word without a slash" >&2; exit 2 ;; esac

root="$(git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')"
if [ -n "$root" ]; then
  locks="$(dirname "$root")/$(basename "$root")-lanes/.lead/locks"
else
  locks="${TMPDIR:-/tmp}/owner-locks"
fi
mkdir -p "$locks"
lock="$locks/$name"

# A holder writes its pid right after taking the lock. Five empty reads in a row (ten seconds) mean it died in
# between, which leaves a lock nobody will ever release.
empty=0
said=false
until mkdir "$lock" 2>/dev/null; do
  holder="$(cat "$lock/pid" 2>/dev/null || true)"
  if ! $said; then echo "locked.sh: waiting for the lock '$name', held by process ${holder:-unknown}" >&2; said=true; fi
  if [ -z "$holder" ]; then empty=$((empty + 1)); else empty=0; fi
  if { [ -n "$holder" ] && ! kill -0 "$holder" 2>/dev/null; } || [ "$empty" -ge 5 ]; then
    rm -f "$lock/pid"
    rmdir "$lock" 2>/dev/null
    empty=0
    continue
  fi
  sleep 2
done
echo $$ > "$lock/pid"
trap 'rm -f "$lock/pid"; rmdir "$lock" 2>/dev/null' EXIT

"$@"

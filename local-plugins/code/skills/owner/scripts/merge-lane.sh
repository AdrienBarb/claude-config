#!/bin/bash
# Merges a lane's branch into the base branch, then brings the lane up to date with it.
#   bash merge-lane.sh <name> "<merge message>"     merge the lane into the base branch, then refresh the lane
#   bash merge-lane.sh --refresh <name>             only bring the base branch into the lane
# Run from anywhere inside the repo or one of its lanes. The base branch is the main folder's current branch.
#
# It refuses a lane that holds uncommitted changes, for a merge as for a refresh: they would stay behind and the
# ticket would look merged, or the next ticket would be built on top of them.
# When git itself refuses to start the merge (a file modified in the main folder that the lane also changed), it
# prints git's reason and changes nothing: that file is somebody's work in progress, never overwrite or stash it.
# On a conflict it stops with the merge left open and lists the files: resolve them where the merge is open (the
# main folder for a merge, the lane for a refresh), commit, then run it again with --refresh for a merge.
# After a refresh, <repo>-lanes/.lead/refresh.sh runs inside the lane when it exists: what a lane needs after it
# received new commits (regenerate code, install a new dependency). The lead writes it while preparing the run.
set -uo pipefail

refresh_only=false
if [ "${1:-}" = "--refresh" ]; then refresh_only=true; shift; fi
name="${1:?usage: merge-lane.sh [--refresh] <name> [\"<merge message>\"]}"
message="${2:-merge lane/$name}"

root="$(git worktree list --porcelain | sed -n '1s/^worktree //p')"
lanes="$(dirname "$root")/$(basename "$root")-lanes"
dir="$lanes/$name"
base="$(git -C "$root" branch --show-current)"
[ -d "$dir" ] || { echo "merge-lane.sh: no lane at $dir" >&2; exit 2; }
[ -n "$base" ] || { echo "merge-lane.sh: the main folder is on no branch" >&2; exit 2; }

conflicts() {
  echo "CONFLICT while $1; the merge is left open in $2. Files to resolve:"
  git -C "$2" diff --name-only --diff-filter=U | sed 's/^/    /'
}

if [ -n "$(git -C "$dir" status --porcelain)" ]; then
  echo "merge-lane.sh: the lane has uncommitted changes; commit them, or park them on a branch, first:" >&2
  git -C "$dir" status --short | head -n 20 >&2
  exit 2
fi

if ! $refresh_only; then
  if ! refusal="$(git -C "$root" merge --no-ff -q -m "$message" "lane/$name" 2>&1)"; then
    if git -C "$root" rev-parse -q --verify MERGE_HEAD > /dev/null; then
      conflicts "merging lane/$name into $base" "$root"
      exit 3
    fi
    echo "REFUSED: git did not start the merge of lane/$name into $base, and nothing changed. Its reason:"
    echo "$refusal" | sed 's/^/    /'
    exit 6
  fi
  echo "merged: $base is at $(git -C "$root" rev-parse --short HEAD)"
fi

if ! git -C "$dir" merge -q --no-edit "$base"; then
  conflicts "bringing $base into lane/$name" "$dir"
  exit 4
fi
if [ -f "$lanes/.lead/refresh.sh" ]; then
  if ! (cd "$dir" && bash "$lanes/.lead/refresh.sh") > "$lanes/.lead/refresh-$name.log" 2>&1; then
    echo "merge-lane.sh: the refresh script failed in $dir; its last lines:" >&2
    tail -n 15 "$lanes/.lead/refresh-$name.log" >&2
    exit 5
  fi
fi
echo "lane $name is at $(git -C "$dir" rev-parse --short HEAD), up to date with $base"

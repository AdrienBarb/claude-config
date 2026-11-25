#!/bin/bash
# Removes a lane and its branch once nothing of it is left to keep.
#   bash drop-lane.sh <name>        run from anywhere inside the repo or one of its lanes
#
# It refuses, and says why, when the lane holds uncommitted changes or commits the base branch does not have:
# that work would be lost. Git-ignored files of the lane (installed dependencies, build output) go with it.
set -uo pipefail

name="${1:?usage: drop-lane.sh <name>}"
root="$(git worktree list --porcelain | sed -n '1s/^worktree //p')"
dir="$(dirname "$root")/$(basename "$root")-lanes/$name"
base="$(git -C "$root" branch --show-current)"
[ -d "$dir" ] || { echo "no lane at $dir: nothing to remove"; exit 0; }

if [ -n "$(git -C "$dir" status --porcelain)" ]; then
  echo "kept: lane $name has uncommitted changes:"
  git -C "$dir" status --short | head -n 20
  exit 1
fi
ahead="$(git -C "$root" rev-list --count "$base..lane/$name")"
if [ "$ahead" -gt 0 ]; then
  echo "kept: lane/$name has $ahead commit(s) that $base does not have"
  exit 1
fi

git -C "$root" worktree remove "$dir" || { echo "kept: git could not remove $dir"; exit 1; }
git -C "$root" branch -q -d "lane/$name"
rm -f "$(dirname "$dir")/.lead/ready-$name"
echo "removed: lane $name and its branch"

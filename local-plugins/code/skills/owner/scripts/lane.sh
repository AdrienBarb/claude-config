#!/bin/bash
# Makes one lane: a copy of the repo (a git worktree) on its own branch, beside the repo, ready for a builder.
#   bash lane.sh <name>        run from anywhere inside the repo or one of its lanes
#
# The lane is <repo>-lanes/<name>, on branch lane/<name>, cut from the base branch: the branch the main folder
# is on. A worktree holds tracked files only, so two things are added:
#   - the git-ignored .env* files of the repo's root are linked into the lane, so that it reads the same settings;
#   - <repo>-lanes/.lead/setup.sh runs inside the lane when it exists: what a fresh copy needs before it can build
#     and test (install dependencies, generate code). The lead writes it once, while preparing the run.
# Run again on a lane that is ready, it changes nothing and says so. Run again on a lane whose setup exited with
# an error, it runs the setup again. A setup that exited without error is never run twice: after correcting
# setup.sh for such a lane, run it yourself inside the lane.
set -euo pipefail

name="${1:?usage: lane.sh <name>}"
root="$(git worktree list --porcelain | sed -n '1s/^worktree //p')"
[ -n "$root" ] || { echo "lane.sh: not inside a git repository" >&2; exit 1; }
base="$(git -C "$root" branch --show-current)"
[ -n "$base" ] || { echo "lane.sh: the main folder is on no branch; put it on the base branch first" >&2; exit 1; }
lanes="$(dirname "$root")/$(basename "$root")-lanes"
dir="$lanes/$name"

ready="$lanes/.lead/ready-$name"

if [ -d "$dir" ] && [ -f "$ready" ]; then
  echo "lane already there: $dir (branch $(git -C "$dir" branch --show-current))"
  exit 0
fi

mkdir -p "$lanes/.lead"
if [ ! -d "$dir" ]; then
  if git -C "$root" show-ref --verify --quiet "refs/heads/lane/$name"; then
    git -C "$root" worktree add -q "$dir" "lane/$name"
  else
    git -C "$root" worktree add -q -b "lane/$name" "$dir" "$base"
  fi
fi

for file in "$root"/.env*; do
  [ -f "$file" ] || continue
  link="$dir/$(basename "$file")"
  if git -C "$root" check-ignore -q "$file" && [ ! -e "$link" ]; then ln -s "$file" "$link"; fi
done

if [ -f "$lanes/.lead/setup.sh" ]; then
  if ! (cd "$dir" && bash "$lanes/.lead/setup.sh") > "$lanes/.lead/setup-$name.log" 2>&1; then
    echo "lane.sh: the setup failed in $dir; its last lines:" >&2
    tail -n 15 "$lanes/.lead/setup-$name.log" >&2
    exit 1
  fi
fi

touch "$ready"
echo "lane ready: $dir (branch lane/$name, from $base)"

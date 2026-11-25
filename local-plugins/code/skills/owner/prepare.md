# Preparing the run

Read once, at the start of a run, and carried out in full before the first builder starts. The preparation is what makes several builders safe: a run that skips it loses work to collisions the tickets could have told you about. It is also the last moment the user is at the keyboard: whatever needs their answer is found here and asked here, once, not in the middle of the night.

The scripts are in `scripts/`, beside this file; `SKILL.md` lists them. Run them, do not rewrite them. Your own files of the run go in `<repo>-lanes/.lead/`, a folder beside the repo that no lane contains.

## Contents

1. Read
2. Plan what runs together
3. Find what the lanes share
4. List the commands that stall an unattended run
5. Record the starting state
6. Make the lanes and prove one
7. Write the progress file
8. Last things

## 1. Read

`CLAUDE.md`, `AGENTS.md`, the tracker record, the verification record (`### Verification` section, else `docs/agents/verify.md`), the spec of each feature, and every ticket of the batch. Note what every builder must know: the git rules (branch, commit format), which checks may be run locally and how, which servers must not be started by hand, the design rules or skills the repo applies to its screens.

## 2. Plan what runs together

From the tickets' blockers, work out what can be built side by side, and write it down as waves: the tickets that can start now, those that follow each of them. Then read the tickets against each other, because blockers say what a ticket needs, not what it collides with:

- **A ticket that must run alone, first.** Anything only one ticket may change (the database's schema and its migrations, a shared configuration, a rename everyone depends on) is built and merged before the lanes fill up. If two tickets of the batch both change such a thing, they are not side by side: one blocks the other.
- **Files many tickets will touch** (the file of the app's texts, the stylesheet, a list of routes, a registry). Either one ticket holds the file and the others wait for it, or the file merges cleanly by nature (a JSON file of keys does, with `merge-json.py`). Decide per file and note it.
- **Seams.** Two tickets built at the same moment cannot ask each other anything. Where one uses what another makes (a table and its columns, an address, a function's shape, an event's name), the name and the shape must be written in the tickets before either starts. Where they are missing or disagree, settle it from the spec and write it into both tickets now. A choice the spec does not make is the user's: ask it at the end of the preparation.
- **A missing blocker.** A ticket that leans on another without naming it as a blocker gets the blocker added, with one line saying why.

## 3. Find what the lanes share

A lane is a separate folder, but it is the same machine. List what all lanes use at once, and decide how each is taken in turn:

- **The test database, and anything else two test runs at once would break**: run those checks through `locked.sh`, which lets one lane at a time. Prove the need rather than assume it: on the base branch, start the full tests twice at the same moment, once. If both pass, no lock is needed.
- **Ports**: one per lane for a dev server, and whatever the app needs to run on another port (a base-URL setting, a job runner of its own).
- **Caches and generated files** a worktree does not have: what `setup.sh` must do in a fresh lane (install dependencies, generate code), and what `refresh.sh` must do after a lane receives new commits. Write both in `<repo>-lanes/.lead/`.
- **What costs or runs out**: a paid API the checks call, a quota. Say when a builder may make a real call, and what it does when the service refuses.
- **Disk**: a lane holds its own installed dependencies. Measure the first lane (`du -sh`) and the free space (`df -h`) before making the others.

## 4. List the commands that stall an unattended run

A command a hook or a permission rule refuses, or holds for approval, halts everything until a human answers. Always treat these as stalling: `rm -rf` (use `trash`, or the alternative the repo names), `sudo`, `su`, `chmod`, `chown`, `dd`, `mkfs`, `fdisk`, `kill`, `killall`, a force push. Add what the repo's rules forbid, and the `permissions.deny` and `permissions.ask` entries of `~/.claude/settings.json` and of the repo's `.claude/settings*.json`. Read the hooks that run before a shell command, too: one that searches the whole command text refuses a forbidden word even inside a commit message or a string.

For each thing a builder will really need (stop a dev server, delete a folder, make a file runnable), find the form that passes and try it once now, while a prompt can still be answered: stopping a server by its port, `lsof -ti :<port> | xargs kill`, passes where `kill <pid>` asks. The list and its alternatives go into every brief.

Separately, list what the machine lets through and the rules of the run forbid: a push, a reset of the database, a `git reset --hard`. No hook stops those; the brief is the only guard.

## 5. Record the starting state

`git status --short` in the main folder: the files already modified are the user's. Never stage them, and leave them out of every scope check. If a ticket of the batch must change one of them, its merge will be refused later: ask the user about it at the end of the preparation.

Put the main folder where the repo's git rules say work happens: that branch is the **base branch** of the run, and its commit now is the start of the batch, which the review checkpoints diff from. Everything a builder must read (the specs, the tickets) is committed on the base branch before any lane is made: a lane holds what git tracks, nothing else.

## 6. Make the lanes and prove one

Decide how many lanes: the widest wave of the plan, at most five (five builders with their checks taken in turn is what one machine has been seen to carry), and no more than the disk allows.

Write the repo's checks, one per line as `label: command`, in `<repo>-lanes/.lead/checks`: types, lint, tests, with the tests through `locked.sh` when section 3 says so. Not the production build: it is slow, and it runs on the base branch.

Make the first lane with `lane.sh <lane name>`, then run `check.sh <lane folder>` in it on untouched code. It must pass: a lane that cannot pass the checks on code nobody changed will fail every ticket for the wrong reason. Until it does, correct `setup.sh` and run it again yourself inside the lane, `(cd <lane folder> && bash <repo>-lanes/.lead/setup.sh)`: `lane.sh` runs the setup again only for a lane whose setup exited with an error. Then make the other lanes.

If no lane can be made to pass, work in the main folder, one ticket at a time, and say so in the progress file.

## 7. Write the progress file

`progress.md` in the feature's folder, committed with each merge when git tracks that folder. It holds:

- the start time and the start commit;
- the user's files that are not yours;
- the plan of section 2: the waves, the ticket that runs alone, the ticket that holds each shared file;
- one line per ticket: state, lane, merge commit;
- the lanes: name, folder, branch, port;
- the choices you made that the user may want to know.

Keep it true at every merge: a session that lost its context starts from it.

## 8. Last things

- **On macOS, keep the machine awake**: `caffeinate -i -t <seconds>` in the background. Count 45 minutes per ticket divided by the number of lanes (a ticket has been seen to take about 35 minutes of a lane), plus an hour for the checkpoints. Closing the lid still suspends the run.
- **Resume.** Resolved tickets are skipped. A ticket found `claimed` was interrupted: the progress file says in which lane; if its work is there or in its notes folder, take it up at the check of the loop, else set it back to `open`. A checkpoint folder with a `review.md` and corrections not yet merged was interrupted too: take it up at its "Decide" step.
- **Ask what must be asked.** If the preparation found a decision that belongs to the user, a missing ticket, one of their modified files in a ticket's way, or too little disk, say it now and wait.
- Otherwise tell the user, in one line and in their language, how many tickets, how many lanes, which ticket runs alone first, and that the run starts.

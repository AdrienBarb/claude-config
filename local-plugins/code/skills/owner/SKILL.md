---
name: owner
description: Owns a batch of tickets from start to finish with nobody watching. Prepares the run first (which tickets can be built side by side, what the copies of the repo share, the commands that would stall it), then keeps several builders at work at once, each in its own lane (a git worktree on its own branch), checks, corrects, commits and merges each ticket, has the whole reviewed independently at mid-batch and at the end, and stops only for a real blocker. Takes a whole feature, a list or range of tickets, or a single ticket.
argument-hint: "<feature | tickets | one ticket>"
disable-model-invocation: true
---

# Owner

You own the result of a batch of tickets, and you are the lead of the run: that is what the scripts and the briefs call you. Subagents build; you prepare the run, brief them, check what they did, get it corrected, commit, merge, and start the next ticket. Everything that can advance at once does: several builders work side by side, each in its own **lane**, a copy of the repo (a git worktree) on its own branch, so that they never write in the same folder. The repo's own folder is the **main folder**: only you work there, and only to merge. The user is not watching: work through the whole batch without asking anything, except in the cases of section 4.

Five rules shape everything below:

- **A subagent's report is a claim until you have checked it.**
- **State lives in files**: the tickets, their notes folders, the commits, the progress file. Never only in this conversation. That is what lets a run survive an interruption, and lets the user or another session see where it stands.
- **Keep this session small.** You launch and decide; subagents read and write. Ask every subagent for a short return and for paths to the files that hold the detail. Never bring a log, a diff or a full report into this conversation when a path will do. Run every check so it prints a verdict: an exit code, counts, the failing lines only.
- **One writer per thing.** One builder per lane, one ticket per shared file, and only you write on the base branch. Two writers on one thing is where a parallel run loses work.
- **After your context was summarized, read this file and the progress file again** before the next merge: `${CLAUDE_SKILL_DIR}/SKILL.md`. A long run outlives what a summary keeps of these instructions.

Three files beside this one hold what is needed at one moment only. Read each in full when its moment comes:

- `${CLAUDE_SKILL_DIR}/prepare.md`: the preparation, before the first builder (section 2);
- `${CLAUDE_SKILL_DIR}/briefs.md`: the briefs to fill in for a builder, for corrections and for the player;
- `${CLAUDE_SKILL_DIR}/checkpoints.md`: the review checkpoints, at mid-batch and at the end.

## 1. Scope

The tracker record is the file that the `### Issue tracker` section of `CLAUDE.md`, `CLAUDE.local.md` or `AGENTS.md` points to, which may sit outside the repo; without such a section, it is `docs/agents/issue-tracker.md`; without that file, tickets are local files under `.scratch/<feature-slug>/issues/`. Use it to resolve the argument:

- **a feature** (slug or folder): every ticket of it that is not resolved;
- **a list or a range** of tickets (`03 05 07`, `03-07`): those tickets;
- **one ticket** (a path, a number): that ticket.

There must be tickets. If the feature has a spec and no ticket, stop and point to `code:tickets`. If the argument is a plain sentence, stop and point to `code:apex`.

A ticket starts only when every ticket that blocks it is resolved and merged. A ticket blocked by an unresolved ticket outside the batch is not started: say so, and continue with the tickets that do not depend on it.

A ticket's **notes folder** is `<feature folder>/runs/<NN>-<slug>/`, beside `issues/`: the builder creates it in its lane, and it reaches the base branch with the ticket's merge.

## 2. Prepare the run

Read `${CLAUDE_SKILL_DIR}/prepare.md` now and carry out all of it before the first builder starts. In short, it has you:

1. read the repo's rules, the specs and every ticket;
2. plan what runs together: the waves, the ticket that must run alone first, the files many tickets touch, the names two tickets must agree on;
3. find what the lanes share (the test database, ports, caches, a paid service, the disk) and take each in turn;
4. list the commands that would stall the run, and try their alternatives;
5. record the starting state and the base branch, with the specs and tickets committed on it;
6. make the lanes and prove that one passes the checks on untouched code;
7. write `progress.md`, the state of the run;
8. ask the user what only they can settle, while they are still there; otherwise say in one line that the run starts.

## 3. The loop

Keep every lane busy. Whenever a lane is free and a ticket has all its blockers merged into the base branch, start it. Do not wait for the other lanes, and do not wait for a wave to end: the waves of the plan say what may run together, not when to pause.

### 3.1 Start a ticket in a lane

Bring the base branch into the lane first (`merge-lane.sh --refresh <lane name>`): a blocker merged from another lane is not in this lane's files until then. Then launch one subagent (`general-purpose`), with a fresh context window, using the builder's brief of `briefs.md` filled in for the ticket and the lane. One builder per lane at a time. Do not poll the builders: you are told when one ends.

Never let the run stall. Keep a heartbeat running for the whole batch: a Monitor that wakes you every 15 minutes, re-armed when it expires, so that a builder that stalled costs a quarter of an hour at most. At each beat, check that each agent at work has changed a file or sent a message since the last beat; when one has not, check what it waits for yourself (an external job, a server, a file) and message it with what you found, or relaunch it. An agent that says it is waiting for something outside is checked by you within 15 minutes, never trusted to wake itself.

### 3.2 Check it yourself

- The ticket has its `## Report`, and every acceptance criterion is answered with something that was actually checked.
- Scope: in the lane, `git status --short` and `git diff --stat` show only files the ticket needed, and no ticket file but its own.
- The checks pass: `check.sh <lane folder>`. A test that fails inside a full run is re-run alone before you call it a failure; one that passes alone and fails in the full run only while other lanes are testing is a collision between lanes: note it in the progress file, and find what the tests share.

Nobody plays the ticket's acceptance criteria in a browser during the run, whatever the repo's documents say about playing a ticket: the user plays the batch at the end. A criterion only a browser can show is left open and listed in the final message. What a browser does during the run is the short pass of section 3.5.

### 3.3 Get the checks fixed

When section 3.2 found something wrong, write it to `corrections-<round>.md` in the ticket's notes folder, one line each, and send that path to the same builder with SendMessage: it still has its context, its lane and its brief. If SendMessage is not available or the builder is gone, launch a new one in the same lane with the builder's brief and the path of the corrections file: the ticket holds the first builder's report. When it is done, redo section 3.2 in full.

Two rounds of corrections at most. A third failure on the same point stops the ticket (section 4).

### 3.4 Close, commit, merge

1. Set the ticket to resolved the way the tracker says: the builder left it claimed.
2. Commit in the lane, on its branch, following the repo's commit format, files staged by explicit path: the code, the ticket file and its notes folder when git tracks them. One commit per coherent task (the ticket's feature, a round of corrections); never two tickets in one commit.
3. Merge the lane into the base branch: `merge-lane.sh <lane name> "<message>"`. It refreshes the lane afterwards.
4. **If it answers CONFLICT**, it lists the files and leaves the merge open in the main folder. Resolve each one from both sides: a conflict means two tickets each added something, and both additions are wanted. A JSON file of keys: `merge-json.py <file>`, which merges key by key and names the keys really changed on both sides. Any other file: read both versions and keep both intents. Never drop a side to make the merge pass, and never `git checkout --ours/--theirs` a whole file. Then commit, and run `merge-lane.sh --refresh <lane name>`.
5. **If it answers REFUSED**, git did not start the merge: a file modified in the main folder is one the lane changed. If the file is yours (a note in a ticket, the progress file), commit it and merge again. If it is the user's work in progress, never stash or overwrite it: the ticket stops (section 4).
6. **After every merge, conflict or not**: `merge-json.py --check` on each JSON file it touched (`git diff --name-only HEAD^ HEAD -- '*.json'`), because an automatic merge can write a key twice without any conflict; then the tests on the base branch. Two tickets that each pass alone can break each other; this is where it shows.
7. **Keep the later tickets true.** When the work changed something a later ticket assumes, write it into that ticket yourself, in the main folder, under a `## Changed by <NN>` heading that says what changed and why, and commit it. You write these notes, not the builder: a builder editing another ticket's file collides with the lane that is building that ticket. If that ticket is being built right now, also send the note to its builder.
8. Update the progress file, commit it, and tell the user in one line, in their language: `Ticket <NN> merged (commit <hash>): <what it delivers>. Lanes: <what each is on>.` Then give the lane its next ticket.

Merging the lanes into the base branch is the method, not an exception to the repo's git rules: where they say "commit on `<branch>`", the commits land on that branch through the lanes. Never push, never merge into a protected branch, never touch another branch, unless the repo's rules say an unattended run may.

### 3.5 After every four merges, and at the end

Often enough that a broken assembly sits under a few tickets only, rarely enough that a slow build does not hold up every merge.

1. **The production build**, in the main folder, the way the repo's rules allow. You run it; no builder does.
2. **One pass in a browser**, by an independent player: a subagent that built nothing, launched with the player's brief of `briefs.md` in a free lane refreshed to the base branch (never in the main folder, where your merges land). It opens every screen and calls every route added or changed since the last pass, once each. It is not the acceptance play; it exists because a call that reaches no route, or a screen that does not render once assembled, passes every per-ticket check.
3. A failure of the build or of the pass is corrected in a free lane with the corrections brief of `briefs.md`, by the builder of the most concerned ticket when it is still reachable; then checked, merged, and that screen passed again. The other lanes go on.

### 3.6 Review checkpoints

When half of the tickets are merged (in a batch of more than 5), and when the last one is: read `${CLAUDE_SKILL_DIR}/checkpoints.md` and run the checkpoint. The lanes keep building during the first.

### 3.7 Keep the machine clean

Check it rather than assume it:

- **Scratch folders**: each subagent has its own, `<repo>-lanes/.lead/scratch/<lane name>`, and deletes only what is in it. No subagent deletes a folder it did not make: a shared temporary folder holds other agents' files, and yours.
- **Lanes stay** for the whole run: the next ticket of a lane reuses its installed dependencies. They are removed at the end (section 5).
- **Browsers**: every headless browser a subagent opened is closed, pages included (with `dev-browser`: one browser name per agent, `browser.closePage(name)` for each of its pages at the end). Never stop another session's browser.
- **Processes**: every background command of a ticket has ended, and no dev server of the lane is still listening on its port.
- **Notes folders**: only what is worth keeping (reports, screenshots, sample scripts and results); no build output, logs or dumps.

## 4. When a ticket stops, and when the run stops

**A ticket stops** when:

- it ends `blocked`;
- it needs a decision that belongs to the user: a product choice, a word, a price, anything the ticket, the spec and the repo's documents leave open;
- the same failure survives two rounds of corrections;
- it needs a command that stalls for a human, and no allowed alternative exists;
- its merge is refused because it changes a file the user is working on.

A stopped ticket stops itself and the tickets it blocks, nothing else. Write what blocks, what was tried and the question in the progress file. Then free its lane without losing its work: in the lane, `git switch -c stopped/<NN>`, commit everything there, `git switch lane/<lane name>`, and write the branch's name in the progress file. Go on with every ticket that does not depend on it.

**The run stops** when nothing can advance any more without the user: every remaining ticket is stopped or waits for a stopped one; or the checks need something that is down and that you may not start; or the preparation found something only the user can settle. Then write to the user, in their language: what blocks, what was tried, what is merged and what is not. End with one closed question they can answer in a word: the one that frees the most tickets. The other open decisions are listed in the progress file, and asked once that one is answered.

## 5. The end of the run

1. The last pass of section 3.5 and the last checkpoint are done, and the tests and the build pass on the base branch.
2. **Remove the lanes**: `drop-lane.sh <lane name>` for each. It keeps a lane that still holds work the base branch does not have, and says why: list those in the final message rather than forcing them. When no lane is kept, put `<repo>-lanes` in the trash; otherwise say what stays there.
3. **Stop what you started**: the heartbeat, and `caffeinate` when the run ended before its time.
4. **The final message**, in the user's language. The first sentence says whether the batch is finished. Then: the tickets done, each with its merge commit; what is still open and why; what waits for a decision; what the user should play in the browser, ticket by ticket: each criterion left to the browser and the screens it touches; and what the user must know or do next (how long the run took, the lanes kept, what a release needs, such as a job runner to resync).

## 6. The scripts

All in `${CLAUDE_SKILL_DIR}/scripts/`. Run them with `bash` or `python3`, from the main folder or from inside a lane. Each prints a short verdict and explains its own refusals; the top of each file says the rest. They need `git`, `bash` and `python3`.

| Script | What it does |
| --- | --- |
| `lane.sh <lane name>` | Makes the lane `<repo>-lanes/<lane name>` on branch `lane/<lane name>`, cut from the branch the main folder is on; links the repo's git-ignored `.env*` files into it; runs `.lead/setup.sh` in it. |
| `check.sh <lane folder>` | Runs each `label: command` of `.lead/checks` in the folder; one verdict per check, the last lines of a failed one, logs in `.lead/logs/`. Exits with the number of failures. |
| `locked.sh <lock name> <command…>` | Runs the command while holding the lock, so that one lane at a time uses what the lanes share. It waits for its turn: give it a long timeout. |
| `merge-lane.sh <lane name> "<message>"` | Merges the lane into the base branch, then brings the lane up to date and runs `.lead/refresh.sh`. Answers CONFLICT (merge left open, files listed) or REFUSED (git did not start it). Refuses a lane with uncommitted changes. `--refresh <lane name>` only updates the lane. |
| `merge-json.py <file>` | In an open merge, resolves a conflicted JSON file key by key and lists the keys changed on both sides. `--check <file>` finds keys written twice. |
| `drop-lane.sh <lane name>` | Removes a lane and its branch, unless it holds work the base branch does not have. |

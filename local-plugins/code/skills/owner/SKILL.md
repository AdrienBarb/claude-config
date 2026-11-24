---
name: owner
description: Own a batch of tickets from start to finish with nobody watching - one ticket at a time, each built by a subagent, checked, corrected and committed, with an independent review at the end of the batch (and at mid-batch past 5 tickets) - stopping only for a real blocker. Takes a whole feature, a list or range of tickets, or a single ticket.
argument-hint: "<feature | tickets | one ticket>"
disable-model-invocation: true
---

# Owner

You own the result of a batch of tickets. Subagents do the work; you brief them, check what they did, get it corrected, commit, and move to the next ticket; at the checkpoints of section 3b, you have the work reviewed independently and corrected. Nobody plays the work in a browser during the run: the user plays the whole batch at the end. The user is not watching: work through the whole batch without asking anything, except in the cases of section 4.

Three rules shape everything below:

- **A subagent's report is a claim until you have checked it.**
- **State lives in files**: the tickets, their notes folders, the commits. Never only in this conversation. That is what lets a run survive an interruption and resume.
- **Keep this session small.** You launch and decide; subagents read and write. Ask every subagent for a short return and for paths to the files that hold the detail. Never bring a log, a diff or a full report into this conversation when a path will do. Run every check so it prints a verdict: an exit code, counts, the failing lines only.

## 1. Scope

The tracker record is the file that the `### Issue tracker` section of `CLAUDE.md`, `CLAUDE.local.md` or `AGENTS.md` points to, which may sit outside the repo; without such a section, it is `docs/agents/issue-tracker.md`; without that file, tickets are local files under `.scratch/<feature-slug>/issues/`. Use it to resolve the argument:

- **a feature** (slug or folder): every ticket of it that is not resolved;
- **a list or a range** of tickets (`03 05 07`, `03-07`): those tickets;
- **one ticket** (a path, a number): that ticket.

There must be tickets. If the feature has a spec and no ticket, stop and point to `code:tickets`. If the argument is a plain sentence, stop and point to `code:apex`.

Work the batch in ticket order, a ticket starting only when every ticket that blocks it is resolved. A ticket blocked by an unresolved ticket outside the batch is not started: say so, and continue with the tickets that do not depend on it.

## 2. Before the first ticket

1. **Read the rules of the repo**: `CLAUDE.md`, `AGENTS.md`, the tracker record, the verification record (`### Verification` section, else `docs/agents/verify.md`), and the spec of the feature. Note what every builder must know: the git rules (branch, worktree, commit format), which checks may be run locally and how, which servers must not be started by hand, the design rules or skills the repo applies to its screens.
2. **List the commands that stop an unattended run.** A command a hook or a permission rule refuses, or holds for approval, halts everything until a human answers. Always treat these as stopping: `rm -rf` (use `trash`, or the alternative the repo names), `sudo`, `su`, `chmod`, `chown`, `dd`, `mkfs`, `fdisk`, `kill`, `killall`, a force push. Add what the repo's rules forbid, and the `permissions.deny` and `permissions.ask` entries of `~/.claude/settings.json` and of the repo's `.claude/settings*.json`.
3. **Record the starting state.** `git status --short`: the files already modified are not yours. Never stage them, and leave them out of every scope check. Then put yourself where the repo's git rules say work happens: the branch or the worktree they require, and note its commit as the start of the batch: the checkpoints of section 3b diff from it.
4. **Check what the checks need**: the database, the test runners, whatever the repo's allowed checks rely on. Start only what the repo lets an agent start; if something is down and you may not start it, that is a stop condition.
5. **On macOS, keep the machine awake**: run `caffeinate -i -t <seconds>` in the background, counting an hour per ticket. It ends by itself. Closing the lid still suspends the run.
6. **Resume.** Resolved tickets are skipped. A ticket found `claimed` was interrupted: if its work is in the working tree or in its notes folder, take it up at step 3.2; if there is nothing, set it back to `open`. A checkpoint folder with a `review.md` and corrections not yet committed was interrupted too: take it up at its step 2.
7. Tell the user, in one line, how many tickets, in which order, and that the first one starts.

## 3. For each ticket

### 3.1 Build

Launch one subagent (`general-purpose`), with a fresh context window, using the brief of section 6 filled in for the ticket. One ticket at a time: tickets of a feature edit the same files. Wait for it to finish; do not poll.

Never let the run stall. Keep a heartbeat running for the whole batch (a Monitor that wakes you every 15 minutes, re-armed when it expires). At each beat, check that the agent at work has changed a file or sent a message since the last beat; when it has not, check what it waits for yourself (an external job, a server, a file) and message it with what you found, or relaunch it. An agent that says it is waiting for something outside is checked by you within 15 minutes, never trusted to wake itself.

### 3.2 Check it yourself

- The ticket has its `## Report`, and every acceptance criterion is answered with something that was actually checked.
- Scope: `git status --short` and `git diff --stat` show only files the ticket needed.
- The repo's checks pass, run the way its rules allow: types, lint, tests, build. A test that fails inside a full run is re-run alone before you call it a failure. You run the build, once per round; the builder does not.

Nobody plays the ticket in a browser, not the builder, not you, not a player: the user plays the batch at the end. A criterion only a browser can show is left open and listed in the final message.

There is no review per ticket: reviews run at the checkpoints of section 3b.

### 3.3 Get the checks fixed

When step 3.2 found something wrong, write it to `<notes folder>/corrections-<round>.md`, one line each, and send that path to the same builder with SendMessage: it still has its context. Repeat the rules of the brief. If SendMessage is not available or the builder is gone, launch a new one with the ticket, its report and the corrections file. When it is done, redo step 3.2 in full.

Two rounds of corrections at most. A third failure on the same point is a stop condition.

### 3.4 Keep the later tickets true

When the work changed something a later ticket assumes, and the builder did not update that ticket, edit it yourself under a `## Changed by <NN>` heading that says what changed and why. The next builder must not meet the same surprise.

### 3.5 Clean up

Before the commit, leave the machine as the ticket found it, and check it rather than assume it:

- **Copies and worktrees**: every copy made for a build, every worktree, every scratch folder of the ticket is deleted for real (`rm -r` on your own scratch copy; the Trash frees no space). A copy holds only what git tracks or would track (`git ls-files -co --exclude-standard`), never an ignored folder: ignored folders can weigh tens of gigabytes. Check the free space (`df -h`) once per ticket.
- **Browsers**: every headless browser the builder opened is closed, pages included (with `dev-browser`: one browser name per agent, `browser.closePage(name)` for each of its pages at the end). Never stop another session's browser.
- **Processes**: every background command you started for the ticket has ended (TaskStop otherwise), and no test server of the ticket is still listening.
- **Notes folder**: only what is worth keeping (reports, screenshots, sample scripts and results); no build output, logs or dumps.

Put the same duty in every brief: each subagent cleans what it created before its last message, and says so in it.

### 3.6 Close and commit

Set the ticket to resolved the way the tracker says: the builder left it claimed. Then commit, following the repo's git rules, files staged by explicit path, with the code, and the ticket file and its notes when git tracks them.

Organize commits by task, one commit per coherent task: the ticket's feature, a round of corrections, a refactor. A ticket may end in several commits; never mix two tickets in one commit.

Never push, never merge, never commit on a protected branch, unless the repo's rules say an unattended run may.

### 3.7 Report and move on

Write one line to the user, in their language, then go to the next ticket, or to the checkpoint of section 3b when one falls here: `Ticket <NN> done (commit <hash>): <what it delivers>. Next: <MM>.`

## 3b. Review checkpoints

Reviews run on several tickets at once, not after each ticket.

- **Batch of 5 tickets or fewer**: one checkpoint, after the last ticket, on the diff of the whole batch.
- **Batch of more than 5 tickets**: two checkpoints, one after ticket ⌈n/2⌉ on the diff since the start of the batch, one after the last ticket on the diff since the first checkpoint.

At a checkpoint:

1. **Review.** Call the Skill tool with `code:review`, passing the diff (the commits since the start of the batch or since the last checkpoint: `git diff <start>..HEAD`), the tickets it covers, the spec, the plans, and a notes folder for the checkpoint (`<feature>/runs/review-<NN>/`). Its reviewers are subagents; the consolidated findings go to `review.md` there. Three axes by default (spec, logic, standards together with UX/UI when a screen is touched); add the others when the diff touches security, auth or payments.
2. **Decide**, finding by finding; the reviewers do not. Each finding is one of:
   - **fix now**;
   - **not this batch**: it existed before, or it belongs to a later ticket. Note it in that ticket, or in the final message;
   - **rejected**, with the reason: it contradicts the spec, a validated mockup or a rule of the repo.

   LOW findings may wait and be grouped in the last checkpoint's corrections.
3. **Get it corrected.** Write the ids to fix to `corrections-<round>.md` in the checkpoint's folder, one line each, pointing at `review.md`. Send it to the builder of the most concerned ticket if it is still reachable, else launch a new builder with the tickets covered, their reports and the corrections file. When it is done, redo step 3.2 on the whole diff, review again only if the corrections rewrote a significant part, and commit the corrections as their own commit(s). Two rounds at most, as in step 3.3.
4. **Keep the later tickets true** (step 3.4) for anything the corrections changed.

Then report in one line and continue: `Checkpoint after <NN>: <findings fixed> fixed, <rejected> rejected (commit <hash>). Next: <MM>.`

## 4. When to stop

Stop the loop and start no further ticket when:

- a ticket ends `blocked`;
- a decision belongs to the user: a product choice, a word, a price, anything the ticket, the spec and the repo's documents leave open;
- the same failure survives two rounds of corrections;
- the work needs a command that stops for a human, and no allowed alternative exists;
- the checks need something that is down and that you may not start.

Then write to the user, in their language: what blocks, what was tried, what is committed and what is not. End with one closed question they can answer in a word.

## 5. The final message

When the batch is done, or when you stop, write to the user in their language. The first sentence says whether the batch is finished. Then: the tickets done, each with its commit; what is still open and why; what waits for a decision; what the user should play in the browser, ticket by ticket: each criterion left to the browser and the screens it touches.

## 6. The builder's brief

The builder sees nothing of this conversation. Fill this in for each ticket and pass it as the whole prompt:

```
Work ticket <ticket reference> in <absolute path of the repo or worktree>. You know nothing of the
conversation that sent you: everything you need is in the files named here.

- Read first: <the repo's rule files>, the ticket, its spec at <spec reference>, and the `## Report`
  of each ticket that blocks it.
- Build it with the skill `code:apex -a -e -t <ticket reference>`. `-e` is required: you cannot
  launch subagents. An independent review reads your work later, with the tickets around it, and
  the user plays it in the browser at the end of the batch: do not play it yourself, whatever the repo's documents say about
  playing a ticket. Open each screen you touched once, to see that it renders without an error,
  and stop there. Do not run the production build either: I run it when I check your work.
- Follow the repo's rules, in particular: <check policy; servers not to start; design rules or
  skills to apply; anything else noted in section 2>.
- Never commit, never push, never change branch. Never run <the stopping commands>: each one halts
  the run until a human answers. <The allowed alternatives.>
- Never ask a question: the decisions are in the ticket and the spec. If a decision is missing, or
  the same error survives two fixes, set the ticket to `blocked`, write under `## Blocked` what
  blocks, what you tried and what is needed, and stop.
- Finish by appending a `## Report` to the ticket: what was done, what differs from the ticket and
  why, the problems found, what was checked, and the later tickets you edited (each under a
  `## Changed by <NN>` heading). Leave the ticket `claimed`: I resolve it after checking.
- Put your working files in <notes folder>.
- Clean up before your last message: delete every copy, worktree and scratch file you made (never copy
  a git-ignored folder), close every page of your headless browser (one browser name for you alone),
  end every background command. Your last message says what you cleaned.
- Your last message, under 200 words: the files you changed, each acceptance criterion with what
  you saw (a criterion that only the browser can show: "left to the browser"), and what differs
  from the ticket. No logs.
```

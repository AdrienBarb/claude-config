# Review checkpoints

Read when a checkpoint falls. Reviews run on several tickets at once, not after each ticket.

- **Batch of 5 tickets or fewer**: one checkpoint, when the last ticket is merged, on the diff of the whole batch.
- **Batch of more than 5 tickets**: two checkpoints, one when half of the tickets are merged, on the diff of the base branch since the start of the batch, one when the last is merged, on the diff since the first checkpoint. The lanes keep building during the first.

At a checkpoint:

1. **Review.** Call the Skill tool with `code:review`, passing the diff (`git diff <start>..<base branch>`), the tickets it covers, the spec, the plan of each ticket (in its notes folder), and a notes folder for the checkpoint (`<feature folder>/runs/review-<NN>/`). Its reviewers are subagents, on the axes that skill chooses from what the diff touches; the consolidated findings go to `review.md` there.
2. **Decide**, finding by finding; the reviewers do not. Each finding is one of:
   - **fix now**;
   - **not this batch**: it existed before, or it belongs to a later ticket. Note it in that ticket, or in the final message;
   - **rejected**, with the reason: it contradicts the spec, a validated mockup or a rule of the repo.

   LOW findings may wait and be grouped in the last checkpoint's corrections. A finding in files that lanes are editing right now waits for the last checkpoint.
3. **Get it corrected.** Write the ids to fix to `corrections-<round>.md` in the checkpoint's folder, one line each, pointing at `review.md`. Group them in lots that touch different files, one lot per free lane. Commit the checkpoint's folder on the base branch and refresh each of those lanes, so that the lane holds the files. Launch one builder per lot with the corrections brief of `briefs.md`. Then check, commit and merge each lot as the loop does for a ticket, without a ticket status to set. Review again only if the corrections rewrote a significant part. Two rounds at most.
4. **Keep the later tickets true** for anything the corrections changed, as after a ticket's merge.

Then report in one line and continue: `Checkpoint at <n> tickets: <findings fixed> fixed, <rejected> rejected (commit <hash>).`

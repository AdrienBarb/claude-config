---
name: tickets
description: Break a spec, a plan, or the current conversation into tickets, each a thin end-to-end slice that declares which tickets block it, and publish them where the repo keeps its tickets.
disable-model-invocation: true
---

# Tickets

Cut the work into tickets a fresh session can take one at a time. Skip this skill when the whole feature fits in one session: go straight to `code:apex`.

## Where tickets go

The tracker record is the file that the `### Issue tracker` section of `CLAUDE.md`, `CLAUDE.local.md` or `AGENTS.md` points to, which may sit outside the repo; without such a section, it is `docs/agents/issue-tracker.md`. If it exists, follow its operations.

If it does not exist, use local files, no setup needed: one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, next to the feature's `spec.md`.

## Process

### 1. Gather the source

Work from the spec the user points to (a path, an issue number, a feature slug) and read it in full. With no reference, use the spec written earlier in this conversation; failing that, the conversation itself.

### 2. Explore

If you have not already, read the code the work touches. Look for a prefactor that makes the feature easy: make the change easy, then make the easy change. Prefactoring tickets come first.

### 3. Draft the slices

Each ticket is a vertical slice:

- It cuts a narrow but complete path through every layer it needs (schema, API, UI, tests). Never one layer across the whole feature.
- Once done, it can be shown or verified on its own.
- It fits in one fresh session.

Give each ticket its blockers: the tickets that must be resolved before it can start. A ticket with no blocker can start now, and two tickets that do not block each other can be worked in parallel sessions.

**The exception is a wide mechanical change** (rename a column, retype a shared symbol) that breaks call sites everywhere at once, so no thin slice can land green. Sequence it as expand, migrate, contract: first add the new form beside the old; then migrate callers in batches (per package or directory), one ticket per batch, each blocked by the expand; finally delete the old form in a ticket blocked by every batch.

### 4. Check the breakdown with the user

Show a numbered list. For each ticket: its title, what it blocks on, and the end-to-end behaviour it makes work. Ask:

- Is the size right, or too coarse, or too fine?
- Does each ticket depend only on tickets that really gate it?
- Should any be merged or split?

Iterate until the user approves.

### 5. Publish

Publish in dependency order, blockers first, so each ticket can reference real identifiers. On a tracker with native sub-issues and blocking links, use them and attach each ticket to its spec.

For local files, use this template, one ticket per file:

<ticket-template>

# <NN>: <Ticket title>

Spec: ../spec.md
Status: open
Blocked by: <numbers, or none>

## What to build

The end-to-end behaviour this ticket makes work, from the user's point of view. Not a layer-by-layer task list.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

</ticket-template>

On a tracker, the issue body carries the same "What to build" and "Acceptance criteria" sections, plus a "Blocked by" section when the tracker has no native blocking.

No file paths and no code in a ticket: they go stale. Same exception as in a spec: a snippet that states a decision more exactly than prose.

Do not close or modify the spec.

### 6. Say what is startable

End with the tickets that can start now (no open blocker), and the command for the first one: `/code:apex <ticket reference>`.

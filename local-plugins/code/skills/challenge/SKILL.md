---
name: challenge
description: Have a spec or an implementation plan attacked by reviewers that start with no context, before any code is written, then settle each finding with the author. Use when the user asks to challenge, stress-test, red-team or review a spec, a design document or a plan.
argument-hint: "[path or reference of the spec or plan]"
---

# Challenge

The session that wrote a document is its worst judge: it shares every assumption the author made. This skill hands the document to reviewers that have never seen the conversation, collects what they find, and settles each finding with the author.

It reviews documents, never code. For code, use `code:review`.

## 1. Find the document

Use the path or reference passed as argument. With none, take the spec or plan written in this conversation. If there are several candidates or none, ask.

When the document lives on a tracker, follow the tracker record to fetch it (the file the `### Issue tracker` section of `CLAUDE.md`, `CLAUDE.local.md` or `AGENTS.md` points to, else `docs/agents/issue-tracker.md`) and save it to a local file first: reviewers read a file.

Decide what kind of document it is:

- a **spec** says what to build and which decisions were made;
- a **plan** says which files change and how.

## 2. Send the reviewers

Each reviewer is a subagent with a fresh context window. If this session cannot start subagents, stop and say so: a review in the same context is not a fresh review.

Rules for every reviewer:

- Its prompt contains the document's path, the brief below, and nothing else from this conversation: no summary, no intent, no defence of the document. What the document does not say, the reviewer must not know.
- It is read-only: it reads the document and the repo, and changes nothing.
- It rates each finding **Blocker** (the work would go wrong), **Major** (a real gap) or **Nit**, and names the section or lines concerned.

Launch all reviewers of the round in one message so they run in parallel.

| Reviewer | Spec | Plan |
| --- | --- | --- |
| Naive reader | yes | yes |
| Critic | yes | no |
| Code checker | yes | yes |
| Implementer | no | yes |

**Naive reader.** "You have just joined this project and know nothing about it. You know software. First, in your own words, write two short paragraphs: what this document proposes, and how the existing system works according to it. If you cannot write one of them for some section, that section is a Blocker. Then flag every term specific to this project that is used without being defined or linked, every step that assumes knowledge the document never gives, and every vague statement ('the system handles this') that does not say how. Do not flag general engineering terms."

**Critic.** "You are a skeptical senior engineer. Stress-test this design. Flag every claim about behaviour, performance or constraints that has no justification. Flag the failure modes, security problems, scale limits and integration problems the design creates and does not address. Check that rejected alternatives are listed, each with a concrete reason; a design with a single path and no alternative considered is a Major finding. For each finding, say what would have to be true for the design to hold."

**Code checker.** "You are a pedantic auditor. For every file, function, endpoint, table, flag or behaviour the document describes as existing today, open the code and check it. A statement the code contradicts is a Blocker: every later reader inherits it. A cited item that does not exist is a Blocker. Then look for what the code has in this area that the document leaves out: validation rules, hardcoded constants, retries, error paths, an existing helper that already does what the document proposes to build. Files the document says it will create are not findings."

**Implementer.** "You are the engineer who will write this code tomorrow, and you may not make any design decision yourself. Read the plan and ask of each step: do I know exactly what to write, where, and how? Flag every step that leaves a choice to you: a schema, an API signature, a dependency, an error-handling strategy, an edge case. Flag every step stated as a summary ('update the auth service') instead of an action. Check that every file is marked create, modify or delete, that the plan is cut into phases that each leave the code building and testable, and that the tests to write are named."

## 3. Show the result

Start with the naive reader's two paragraphs, as written. The author compares them with what they meant: a wrong paraphrase is a finding in itself, even when the reviewer flagged nothing.

Then one table of findings, Blockers first: severity, reviewer, where, what. Merge duplicates and keep the most precise wording. Drop nothing silently.

## 4. Settle each finding

For every Blocker and Major, take a position: **fix** (give the exact change to the document) or **contest** (give the reason the finding is wrong or the trade-off is accepted). Present them all in one round, numbered, each worded so "yes" accepts your position, and wait for the author's answers. The decisions are the author's.

Apply the accepted fixes to the document. Do not touch code.

If Blockers were fixed, re-run once, and only the reviewers whose findings were fixed. One re-run at most: whatever is still open after it is recorded as an accepted trade-off, not looped on.

## 5. Record

Write `challenge.md` next to the document (for local files, in the feature folder, beside `spec.md`): the naive reader's paragraphs, the findings table, and for each finding what was decided, fixed or accepted and why.

End with one line: how many findings, how many fixed, how many accepted, and whether the document is ready to build from.

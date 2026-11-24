---
name: step-05-examine
description: Adversarial code review - security, logic, and quality analysis
prev_step: steps/step-04-validate.md
next_step: steps/step-06-resolve.md
---

# Step 5: Examine (Adversarial Review)

Skeptical review of the implementation: assume bugs exist, find what tests miss. If teams_mode: the team stays alive — no shutdown before step-09-finish.

If save_mode:
```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "05" "examine" "in_progress"
```

## 1. Gather changes

`git diff --name-only` + `git status --porcelain` (use the right base if work spans several commits). Group: source, tests, config.

## 2. Review

**If economy_mode — self-review against this checklist, no subagents:**

- Security: no injection (SQL/command/XSS), no secrets in code, input validation at boundaries, auth checks on protected routes.
- Logic: error handling for failure modes, edge cases, null/undefined, race conditions.
- Quality: follows existing patterns, no duplication, clear naming.
- Maintainability: no file pushed past 1k lines without strong justification, no ad-hoc conditionals bolted onto unrelated flows, no thin abstractions or identity wrappers, no unnecessary casts/`any`/`unknown`, feature logic stays in its canonical layer, reuses canonical helpers, nothing that could be dramatically simpler.

**Otherwise — delegate to the review skill.** Call the Skill tool with `code:review`, passing: what to diff (the base ref if the work spans commits, otherwise the uncommitted changes), `{ticket_ref}`, `{spec_ref}` and the plan file when they exist, and `{run_dir}` (else `{output_dir}`, if set) as the folder for its report. The skill runs the reviewers in parallel and returns every finding with a severity and a validity. Do not launch review agents yourself: one review, in one place.

## 3. Classify and present

Severity: CRITICAL (security/data loss) / HIGH (significant bug) / MEDIUM / LOW. Validity: **Real** / **Noise** / **Uncertain** — never dismiss a finding without justification. The review skill already assigned both: keep them, and re-check yourself only a finding you disagree with.

Present the findings table (ID, severity, category, location, issue, validity) with a summary count, and create one todo per finding.

## 4. Gate (this transition always confirms unless auto_mode)

- auto_mode → proceed automatically based on findings.
- Otherwise ask via AskUserQuestion: **Resolve findings** (recommended) / **Skip to tests** / **Skip resolution** / **Discuss findings**.

If save_mode: append findings and a `## Step Complete` block to `{output_dir}/05-examine.md`.

## Routing

- "Resolve findings" → load `./step-06-resolve.md`
- "Skip to tests" (test_mode) → load `./step-07-tests.md`
- "Skip resolution" → test_mode ? `./step-07-tests.md` : pr_mode ? `./step-09-finish.md` : workflow complete.

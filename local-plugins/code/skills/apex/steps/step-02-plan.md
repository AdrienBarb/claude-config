---
name: step-02-plan
description: Strategic planning - create detailed file-by-file implementation strategy
prev_step: steps/step-01-analyze.md
next_step: steps/step-03-execute.md
---

# Step 2: Plan (Strategic Design)

Transform the analysis into a complete, file-by-file implementation plan. No source code is written or modified in this step.

If save_mode:
```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "02" "plan" "in_progress"
```

## 1. Design the complete strategy

Think through the ENTIRE implementation before writing the plan: every file that changes, dependency order, edge cases, error handling, test coverage.

## 2. Write the plan — structured by FILE, not by feature

```markdown
## Implementation Plan: {task_description}

### Overview
[1-2 sentences]

### File Changes

#### `src/path/file1.ts`
- Add `functionName` that handles X (follow pattern in `example.ts:45`)
- Handle error case: [specific scenario]

#### `src/path/file3.ts` (NEW FILE)
- Create utility for Z; export `utilityFunction`
- Pattern: follow `similar-util.ts` structure

### Testing Strategy
- New: `src/path/file1.test.ts` — happy path, error case, edge case
- Update: `src/path/existing.test.ts` — new flow

### Acceptance Criteria Mapping
- [ ] AC1: satisfied by changes in `file1.ts`

### Risks & Considerations
- Risk 1: [issue and mitigation]
```

Every action specific and actionable, with line references from the analysis. Every AC mapped to a file change. No scope creep.

**Zero-decision rule.** The plan leaves no design choice to whoever executes it: no schema, signature, dependency, error-handling strategy or edge case left open. Mark every file `Create`, `Modify` or `Delete`. A plan a fresh session could not execute without asking a question is not finished.

**If save_mode:** write the FULL plan to `{output_dir}/02-plan.md` before presenting any summary.

**If `{run_dir}` is set (ticket mode):** also write the full plan to `{run_dir}/plan.md`, whatever save_mode is. That file is what `code:challenge`, `code:review` and a later session read.

## 3. Create the team (teams_mode only — BEFORE the TaskList)

TeamCreate resets the task list, so the team must exist before any TaskCreate. Do NOT spawn agents yet — that happens in step-03-execute-teams.

```
TeamCreate:
  team_name: "apex-{feature_name}"
  description: "APEX: {task_description}"
```

**If TeamCreate / TaskCreate are not available in this session** (they are gated; on 2026-10-06 the
implementers reported "TaskList is disabled for my session"): skip §3 and §4, keep the task list in
`{output_dir}/02-plan.md` (one task per file group, with its file boundary and dependencies), and
step-03-execute-teams briefs each implementer with its task in full.

## 4. Create the TaskList (mandatory)

One `TaskCreate` per file change:
- **subject**: `{action} {filepath}` (e.g. "Add validateToken to src/auth/handler.ts")
- **description**: full details — functions, patterns to follow, line references
- **activeForm**: present continuous ("Adding validateToken to handler.ts")

Then wire dependencies with `TaskUpdate` + `addBlockedBy` wherever one file's change depends on another's.

## 5. Targeted questions (skip entirely if auto_mode)

Identify what you are genuinely uncertain about (file locations, patterns, user expectations, technical approach). Ask via AskUserQuestion about at most the top 1-4 uncertainties where multiple valid approaches exist, user intent is genuinely ambiguous, or a wrong assumption would cause significant rework. Offer concrete options with tradeoffs and a recommendation.

Never ask generic plan approval ("does this plan look good?"), never ask about details you can decide yourself. Good: "When a user submits an invalid email, inline validation or on submit only?" Bad: "Ready to proceed?"

If nothing meets the bar, proceed without asking.

## 6. Plan approval

**If auto_mode:** show the plan summary (overview, file counts, key decisions, AC coverage, risks), then proceed directly.

**If not auto_mode:** use EnterPlanMode / ExitPlanMode — never AskUserQuestion — for approval:

1. Call `EnterPlanMode`.
2. Write the FULL plan to the plan file the system provides. It must start with the APEX Workflow Context block below, then contain every section from step 2 unabridged — this file is the complete implementation reference and the only thing that survives "Execute and clear context".

```markdown
# APEX Implementation Plan: {task_description}

## APEX Workflow Context

> **IMPORTANT:** This is an APEX workflow plan. If you are reading this after
> "Execute and clear context", restore the state variables below and load the
> next step file to continue the workflow.

### State Variables
| Variable | Value |
|----------|-------|
| task_description | {task_description} |
| task_id | {task_id} |
| feature_name | {feature_name} |
| auto_mode | {auto_mode} |
| examine_mode | {examine_mode} |
| save_mode | {save_mode} |
| test_mode | {test_mode} |
| verify_mode | {verify_mode} |
| economy_mode | {economy_mode} |
| branch_mode | {branch_mode} |
| pr_mode | {pr_mode} |
| tasks_mode | {tasks_mode} |
| teams_mode | {teams_mode} |
| output_dir | {output_dir} |
| branch_name | {branch_name} |
| ticket_ref | {ticket_ref} |
| spec_ref | {spec_ref} |
| run_dir | {run_dir} |

### Next Step After Approval
{if tasks_mode or teams_mode: `{skill_dir}/steps/step-02b-tasks.md`}
{else: `{skill_dir}/steps/step-03-execute.md`}
(Write the absolute path of this skill's folder in place of `{skill_dir}`: the fresh agent has no other way to find it.)

---

[Full plan: Overview, File Changes, Testing Strategy, Acceptance Criteria Mapping, Key Decisions, Risks & Considerations]
```

3. Call `ExitPlanMode` with allowedPrompts covering: build/typecheck/lint/test/format commands, git operations for branches and commits, and the APEX progress-tracking scripts.

## 7. Save completion (if save_mode)

Append a `## Step Complete` block (status, counts, next step, timestamp) to `{output_dir}/02-plan.md`.

## Routing

- tasks_mode or teams_mode → load `./step-02b-tasks.md`
- otherwise → load `./step-03-execute.md`

After "Execute and clear context": the fresh agent reads the plan file, restores every state variable from the table, and loads the step listed under "Next Step After Approval".

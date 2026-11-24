---
name: step-02b-tasks
description: Generate task breakdown with dependencies from the implementation plan
prev_step: steps/step-02-plan.md
next_step: steps/step-03-execute.md
---

# Step 2b: Task Breakdown

Turn the plan into self-contained task files with explicit dependencies, enabling parallel execution. Still no implementation — that's step 3.

If save_mode: `mkdir -p {output_dir}/tasks`

## 1. Identify tasks

From the plan, split work into tasks that are completable in one focused session and touch 1-3 files each. Mark which are independent (parallelizable) and which depend on others. Keep dependencies minimal and justified.

## 2. Create one file per task: `{output_dir}/tasks/task-NN-{name}.md`

```markdown
---
id: task-NN
name: {short-descriptive-name}
status: pending
priority: {high|medium|low}
depends_on: [task-XX]   # empty array if none
blocks: [task-ZZ]
estimated_files:
  - path/to/file1.ts
---

# Task NN: {Title}

## Objective
{one sentence}

## Context
{2-3 sentences of background — the task must be understandable standalone}

## Plan
{numbered implementation steps with line references and patterns}

## Files to Modify
| File | Action | Changes |
|------|--------|---------|

## Acceptance Criteria
- [ ] {specific testable criterion}

## Dependencies
{why each depends_on/blocks relationship exists}
```

## 3. Create `{output_dir}/tasks/README.md`

Overview with: total task count, a dependency graph sketch, a task summary table (id / name / status / depends on / priority), the parallel execution groups, and the critical path (longest dependency chain). Verify there are no circular dependencies.

## 4. Summary and gate

Present totals (tasks, independent, sequential chains) and the created files.

- auto_mode → proceed directly.
- Otherwise ask via AskUserQuestion: **Continue to execution** (recommended) / **Review tasks first** / **Adjust breakdown**.

## Routing

- teams_mode → load `./step-03-execute-teams.md`
- otherwise → load `./step-03-execute.md`

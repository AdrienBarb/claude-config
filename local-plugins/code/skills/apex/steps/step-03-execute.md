---
name: step-03-execute
description: Todo-driven implementation - execute the plan file by file
prev_step: steps/step-02-plan.md
next_step: steps/step-04-validate.md
---

# Step 3: Execute (Implementation)

Implement the approved plan file-by-file, tracking progress with todos. Follow the plan exactly: no features or "improvements" beyond it, no redesigning. If context was cleared via "Execute and clear context", first read the plan file and restore the state variables from its APEX Workflow Context section.

If save_mode:
```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "03" "execute" "in_progress"
```

## 1. Create todos from the plan

One todo per planned change (`src/auth/handler.ts: Add validateToken function`), via TodoWrite.

## 2. Implement file by file

For each todo: follow the patterns from the analysis, use the exact names from the plan, handle the error cases it specifies, no comments unless truly necessary. If save_mode, log each completed file to `{output_dir}/03-execute.md` (what changed, where).

**On a blocker:** if auto_mode, make a reasonable decision and continue. Otherwise ask via AskUserQuestion: **Use alternative approach** (recommended, describe it) / **Skip this part** / **Stop for discussion**.

## 3. Quick check

After all todos: run the project's typecheck and lint commands (see package.json / project CLAUDE.md for the exact names) and fix any errors now.

## 4. Summary and gate

Present files modified, new files, todo completion count.

- auto_mode → proceed to validation.
- Otherwise ask via AskUserQuestion: **Proceed to validation** (recommended) / **Review changes** / **Make adjustments**.

If save_mode: append a `## Step Complete` block to `{output_dir}/03-execute.md`.

## Routing

Load `./step-04-validate.md`.

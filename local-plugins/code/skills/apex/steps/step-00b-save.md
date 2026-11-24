---
name: step-00b-save
description: Setup save output structure for APEX workflow
returns_to: step-00-init.md
---

# Step 0b: Save Mode Setup

Create the output structure, capture `{task_id}` and `{output_dir}`, then return to step-00-init. Nothing else happens in this sub-step.

## Output structure

All outputs go to the project directory:

```
.claude/output/apex/{task-id}/
├── 00-context.md        # Params, user request, progress table
├── 01-analyze.md        # Analysis findings
├── 02-plan.md           # Implementation plan
├── 03-execute.md        # Execution log
├── 04-validate.md       # Validation results
├── 02b-tasks/           # Task breakdown (if -k or -m)
├── 05-examine.md        # Review findings (if -x)
├── 06-resolve.md        # Resolution log (if -x)
├── 07-tests.md          # Test analysis (if -t)
├── 08-run-tests.md      # Test runner log (if -t)
├── 10-verify.md         # Feature verification (if -v)
└── 09-finish.md         # PR creation (if -pr)
```

## 1. Run the setup script

Pass `{feature_name}` (without number prefix), NOT `{task_id}` — the script generates the numbered ID itself:

```bash
bash {skill_dir}/scripts/setup-templates.sh \
  "{feature_name}" \
  "{task_description}" \
  "{auto_mode}" \
  "{examine_mode}" \
  "{save_mode}" \
  "{test_mode}" \
  "{economy_mode}" \
  "{branch_mode}" \
  "{pr_mode}" \
  "{interactive_mode}" \
  "{tasks_mode}" \
  "{verify_mode}" \
  "{branch_name}" \
  "{original_input}"
```

The script auto-generates `{task_id}` = `NN-{feature_name}` (next available number), creates the directory, initializes `00-context.md` with the progress table, and pre-creates step files from templates (only for enabled steps).

## 2. Capture output variables

From the script output: `{task_id}` = generated ID, `{output_dir}` = `.claude/output/apex/{task_id}`.

## Save pattern for all subsequent steps

1. `bash {skill_dir}/scripts/update-progress.sh "{task_id}" "{step_num}" "{step_name}" "in_progress"`
2. Append findings/outputs to the pre-created step file
3. `bash {skill_dir}/scripts/update-progress.sh "{task_id}" "{step_num}" "{step_name}" "complete"`

## Return

Return to `step-00-init.md` immediately with `{task_id}` and `{output_dir}` set.

---
name: step-06-resolve
description: Resolve findings - interactively address review issues
prev_step: steps/step-05-examine.md
---

# Step 6: Resolve Findings

Fix real issues, dismiss noise, discuss uncertain items. Never auto-fix a Noise or Uncertain finding, and always validate after fixes. If teams_mode: the team stays alive — no shutdown before step-09-finish.

If save_mode:
```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "06" "resolve" "in_progress"
```

## 1. Choose a strategy

- auto_mode → auto-fix all **Real** findings, skip Noise/Uncertain.
- Otherwise ask via AskUserQuestion: **Auto-fix Real issues** (recommended) / **Walk through each finding** / **Fix only critical** / **Skip all**.

**Walk through each:** for every finding in severity order, ask: **Fix now** (recommended) / **Skip** / **Discuss** / **Mark as noise**.

**Skip all** with unresolved CRITICAL/HIGH findings: confirm first — **Go back and fix** / **Proceed anyway** / **Fix only critical**.

## 2. Apply fixes and validate

Apply each chosen fix, logging it (if save_mode). Then run the project's typecheck and lint — both must pass before moving on.

## 3. Summary

List fixed findings (with what was done), skipped findings (with why), and the validation status. If save_mode: append a `## Step Complete` block to `{output_dir}/06-resolve.md`. Close with the workflow summary: task, files modified, findings identified/resolved/skipped, suggested next steps (commit, full test suite, deploy).

## Routing

- verify_mode → load `./step-10-verify.md`
- pr_mode → load `./step-09-finish.md`
- otherwise → workflow complete.

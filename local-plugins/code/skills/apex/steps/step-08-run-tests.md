---
name: step-08-run-tests
description: Run tests in a loop - fix issues until all pass
prev_step: steps/step-07-tests.md
---

# Step 8: Run Tests (Fix Loop)

Run the tests and fix failures until everything is green. Clean up any background processes you start.

If save_mode:
```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "08" "run-tests" "in_progress"
```

## 1. Check required services

If the tests need a database, dev server or similar, check whether it's running.

**If missing:** auto_mode → start it automatically. Otherwise ask via AskUserQuestion: **I'll start manually** / **Start automatically** / **Skip tests needing services** / **Skip test step**.

## 2. Fix loop

Run the project's test command. On failure: diagnose whether it's a code bug or a test bug, fix the root cause, run again. Maximum 10 rounds; log each round's pass/fail counts (if save_mode).

**Same failure 3 times:** auto_mode → try one different approach, then move on. Otherwise ask via AskUserQuestion: **I'll debug manually** / **Skip this test** / **Delete test** / **Keep trying**.

**Configuration errors** (missing module, connection refused…): auto_mode → fix them; otherwise ask: **I'll fix manually** / **Try automatic fix** / **Skip tests**.

## 3. Report

Totals (passed/failed, rounds needed) and the test files covered. If save_mode: append a `## Step Complete` block to `{output_dir}/08-run-tests.md`.

## Routing (first match wins)

1. examine_mode → load `./step-05-examine.md`
2. verify_mode → load `./step-10-verify.md`
3. pr_mode → load `./step-09-finish.md`
4. auto_mode → workflow complete, show summary.
5. Otherwise ask via AskUserQuestion: **Run adversarial review** / **Verify feature** / **Complete workflow**.

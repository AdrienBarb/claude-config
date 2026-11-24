---
name: step-04-validate
description: Self-check - run tests, verify AC, audit implementation quality
prev_step: steps/step-03-execute.md
---

# Step 4: Validate (Self-Check)

Run every check, verify every acceptance criterion, and fix failures before moving on. Never report a check as passing when it didn't. If teams_mode: the team stays alive — no shutdown before step-09-finish.

If save_mode:
```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "04" "validate" "in_progress"
```

## 1. Run the validation suite

Discover the project's exact commands (package.json scripts, project CLAUDE.md) and its check policy. When the project or user CLAUDE.md limits local checks (e.g. "only the test files you touched, one at a time; type-check once at the end"), that policy wins over this step: run the touched test files one by one, then the end-of-work pass it names, sequentially, never while teammates run checks. Otherwise run typecheck, lint, and the tests covering the affected area. Every required check MUST pass: fix root causes and re-run until green. Run the format command if one exists.

## 2. Self-audit

- All todos complete; nothing skipped without reason.
- Each acceptance criterion demonstrably met — you can explain how, edge cases included.
- New functionality has tests; existing tests still pass.
- Code follows the codebase's patterns, error handling, and naming.

## 3. Present results

Compact report: typecheck / lint / tests / format status, each AC with how it was verified, files modified.

If save_mode: append results and a `## Step Complete` block to `{output_dir}/04-validate.md`.

## Routing (first match wins)

1. test_mode → load `./step-07-tests.md`
2. examine_mode → load `./step-05-examine.md`
3. verify_mode → load `./step-10-verify.md`
4. pr_mode → load `./step-09-finish.md`
5. auto_mode → workflow complete, show final summary.
6. Otherwise ask via AskUserQuestion: **Run adversarial review** / **Verify feature** / **Add tests** / **Complete workflow** — and route accordingly.

---
name: step-10-verify
description: Launch app and verify feature works through real user surface
prev_step: steps/step-04-validate.md
---

# Step 10: Verify (Feature Validation)

Test the feature the way a real user would — through the running app, not the code. The point is to catch what code review and tests miss. Never claim it works without actually exercising it. If teams_mode: the team stays alive — shutdown only in step-09-finish.

If save_mode:
```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "10" "verify" "in_progress"
```

## 1. Verify

**If economy_mode:** self-verify — launch the app and test each AC yourself with dev-browser, curl or shell.

**Otherwise — delegate to the verify skill.** Call the Skill tool with `code:verify`, passing: `{task_description}`, each acceptance criterion, `{ticket_ref}` and `{spec_ref}` when they exist, and `{run_dir}` (else `{output_dir}`, if set) as the folder for its report and screenshots. The skill proves the app runs the changed code, plays it as a user, and returns PASS / FAIL / NOT VERIFIED per criterion with proof. Do not launch a verifier agent yourself.

## 2. Report and handle failures

Present the per-AC PASS/FAIL table and the overall verdict, compared against the ORIGINAL request. A criterion the skill returned as NOT VERIFIED counts as a FAIL here.

**If FAIL:**

- auto_mode → fix the failing ACs and re-verify, max 2 retry rounds.
- Otherwise ask via AskUserQuestion: **Fix and re-verify** (recommended) / **Fix without re-verify** / **Skip verification** / **Discuss issues**.

Fix loop (when fixing): identify the root cause of each failing AC, apply the fix, run typecheck + lint, re-verify. Max 3 rounds; if still failing, ask: **Keep trying** / **Accept current state** / **I'll fix manually**. Never proceed silently on a FAIL verdict without the user's OK.

If save_mode: append the verdict, rounds and failing ACs to `{output_dir}/10-verify.md`, then run the update-progress script with "complete".

## Routing

- pr_mode → load `./step-09-finish.md`
- otherwise → workflow complete, show summary.

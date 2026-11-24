---
name: step-00b-economy
description: Economy mode overrides - no subagents, direct tool usage to save tokens
load_condition: economy_mode = true
---

# Economy Mode Overrides

Loaded only with `-e`/`--economy`. Purpose: ~70% fewer tokens for users on limited plans, at the cost of less thorough exploration. These rules override the default behavior of ALL steps.

## Overrides

1. **No subagents, ever.** Never use the Task tool with a subagent_type. Use Glob/Grep/Read directly instead of exploration agents, self-review instead of reviewer agents, self-verify instead of the verifier agent.
2. **Minimal exploration.** Search the obvious locations with the task's keywords, read only the 3-5 most relevant files, stop as soon as you have enough to proceed. At most 1-2 web searches, and only when genuinely stuck on an unfamiliar API.
3. **Examine (step-05) becomes a self-review** against the economy checklist in that step.
4. **Tests (step-07) stay minimal.** Read one similar test file for conventions, create one happy-path test and one error-case test, skip edge cases unless critical.
5. **Validation stays full.** Typecheck, lint, and affected tests always run — economy mode never skips correctness checks.

Start each step with `⚡ ECONOMY MODE - Using direct tools, no subagents` so the user sees the mode is active.

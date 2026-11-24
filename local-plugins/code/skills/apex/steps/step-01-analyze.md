---
name: step-01-analyze
description: Pure context gathering - explore codebase to understand WHAT EXISTS
next_step: steps/step-02-plan.md
---

# Step 1: Analyze (Context Gathering)

Discover what currently exists — files, patterns, utilities — with file:line references for everything. No planning, no implementation decisions, no todos: report what IS, not what should be built.

If save_mode:
```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "01" "analyze" "in_progress"
```

## 1. Explore

**If economy_mode:** direct tools only — Glob/Grep with the task's keywords, Read the 3-5 most relevant files, web research only if stuck.

**Otherwise:** scale exploration agents to task complexity — between 1 and 10, all launched in parallel in a single message. Don't launch blindly; pick what the task actually needs (scope, unfamiliar libraries, patterns to integrate with, genuine uncertainties).

| Agent | Use for |
|-------|---------|
| `explore-codebase` | existing patterns, related files, utilities, test patterns |
| `explore-docs` | unfamiliar library APIs, current syntax, configuration |
| `websearch` | common approaches and gotchas |

| Task type | Agents |
|-----------|--------|
| Simple fix | 1-2 |
| Feature on a familiar stack | 2-3 |
| Feature with an unfamiliar library | 3-5 |
| Complex integration | 5-8 |
| Major multi-system feature | 6-10 |

Instruct explore-codebase agents to report files, patterns, utilities and test conventions with paths and line numbers, and NOT to suggest implementations.

When the change hooks a user action (a click, a toggle, a submit), have explore-codebase list every dispatch site that triggers it, including the shipped default templates, not only the component the ticket names.

## 2. Synthesize findings

Combine agent results into structured context with these sections: **Related Files Found** (file / lines / contains), **Patterns Observed**, **Utilities Available**, **Similar Implementations**, **Test Patterns**, **Documentation Insights**, **Research Findings**.

**If save_mode:** append the full synthesis to `{output_dir}/01-analyze.md` (replacing the placeholder text) BEFORE presenting any summary or loading step-02. Historically the most-skipped requirement — do not skip it.

## 3. Infer acceptance criteria

From the task and context, list specific measurable ACs (they get refined in planning). In ticket mode, do not infer them: use the ticket's acceptance criteria as written, and add one only when the spec requires it and the ticket left it out, saying so. If save_mode: append them to the same file, then:

```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "01" "analyze" "complete"
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "02" "plan" "in_progress"
```

## 4. Summary and proceed

Brief summary (files analyzed, patterns identified, key findings), then load step-02-plan directly — no confirmation.

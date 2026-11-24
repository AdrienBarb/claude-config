---
name: step-03-execute-teams
description: Execute implementation using Claude Code Agent Teams for parallel task execution
prev_step: steps/step-02b-tasks.md
next_step: steps/step-04-validate.md
---

# Step 3t: Execute with Agent Teams

You are the TEAM LEAD: coordinate, never implement. All code is written by teammates — you never use Edit/Write on source files in this step. If context was cleared via "Execute and clear context", first read the plan file and restore the state variables.

Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings.json (experimental feature). The team `apex-{feature_name}` was already created in step-02-plan — do NOT call TeamCreate again, it would reset the TaskList and lose every task.

If save_mode:
```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "03" "execute-teams" "in_progress"
```

## 1. Size the team

| Tasks | Teammates |
|-------|-----------|
| 1-2 | 1 |
| 3-4 | 2 |
| 5-8 | 3-4 |
| 9+ | 4-6 |

Never more than 6 — cap at the number of independent task groups, grouping related tasks if needed. 2-4 is right for most work; more adds overhead, not speed. Never assign tasks touching the same files to different teammates.

## 2. Spawn teammates

Always `subagent_type: "implementer"` — it's the dedicated APEX executor (claims tasks via TaskUpdate, respects file boundaries, reports via SendMessage, handles shutdown). Never general-purpose or another type.

Spawn all INDEPENDENT teammates in parallel (one message, multiple Task calls):

```
Task:
  subagent_type: "implementer"
  team_name: "apex-{feature_name}"
  name: "impl-{group-name}"          # e.g. impl-backend, impl-frontend
  mode: "bypassPermissions"          # avoids permission-prompt interruptions
  prompt: |
    You are impl-{group-name} in team apex-{feature_name}.

    **Task:** {task-id} - {title}
    **Objective / Plan / Acceptance Criteria:** {from the task file}
    **Files to Modify (YOUR boundary — only touch these):** {file list}
    **Patterns to Follow:** {from step-01 analysis}
    **Skill Hint:** {if relevant, e.g. "Use /frontend-design for UI components"}
    **Dependencies:** {completed dependencies and their outputs}
    **Checks:** only the test files you wrote or changed, one at a time. No type-check, lint or
    full suite: the lead runs those once, in step-04.

    Check TaskList, claim your task, implement, then report via SendMessage.
```

Each teammate needs ALL context in its prompt — it cannot see your conversation.

**Without TeamCreate / TaskList** (see step-02 §3): spawn with the `Agent` tool instead —
`subagent_type: "implementer"`, a `name`, `run_in_background: true` — and put the whole task in the
prompt (objective, file boundary, patterns, the test files to run, "do not commit"). Spawn dependent tasks
once their prerequisite reports done. Completion is the implementer's report, not a TaskList status:
re-run the checks yourself before trusting it. Tell the implementer there is no TaskList: it reports through SendMessage only.

## 3. Monitor

Teammate messages arrive automatically; don't poll. On a blocker report, analyze and answer via SendMessage. On a completion report, verify the task shows `completed` in TaskList (implementers mark their own). As tasks complete, spawn teammates for newly-unblocked dependent tasks.

## 4. Completion

The team stays ALIVE through validate, examine, resolve and verify — shutdown happens ONLY in step-09-finish. Never send shutdown_request here.

- auto_mode → proceed to step-04.
- Otherwise ask via AskUserQuestion: **Proceed to validation** (recommended) / **Assign additional tasks** / **Message a teammate**.

If save_mode: append the execution summary (team size, task results table, team status "Active") and a `## Step Complete` block to `{output_dir}/03-execute.md`, then:
```bash
bash {skill_dir}/scripts/update-progress.sh "{task_id}" "03" "execute-teams" "complete"
```

## Routing

Load `./step-04-validate.md`.

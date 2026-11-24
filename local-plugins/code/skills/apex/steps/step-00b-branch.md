---
name: step-00b-branch
description: Verify and setup git branch for APEX workflow
returns_to: step-00-init.md
---

# Step 0b: Branch Setup

Verify the current branch, create a feature branch if on main/master, set `{branch_name}`, return to step-00-init. No implementation work here.

## 1. Check current branch

```bash
git branch --show-current
```

**If NOT on main/master:** `{branch_name}` = current branch, display `✓ Already on branch: {branch_name}`, return.

**If on main/master:**

- auto_mode → `git checkout -b feat/{task_id}`, `{branch_name}` = `feat/{task_id}`.
- Otherwise ask via AskUserQuestion: **Create feat/{task_id}** (recommended) / **Custom branch name** (then ask for it and create) / **Stay on {current_branch}** (if pr_mode, warn: "⚠️ Creating PR from {current_branch} directly").

## 2. Confirm and return

Display `✓ Branch: {branch_name}`, then return to `step-00-init.md` with `{branch_name}` set.

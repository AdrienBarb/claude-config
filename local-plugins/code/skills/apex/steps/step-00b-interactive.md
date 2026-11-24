---
name: step-00b-interactive
description: Interactively configure APEX workflow flags
returns_to: step-00-init.md
---

# Step 0b: Interactive Configuration

Let the user toggle flags via AskUserQuestion, update the variables, return to step-00-init. No workflow steps start here.

## 1. Show current configuration

One table: each flag (Auto `-a`, Examine `-x`, Save `-s`, Test `-t`, Verify `-v`, Economy `-e`, Branch `-b`, PR `-pr`, Teams `-m`) with ✓ ON / ✗ OFF and its one-line description.

## 2. Ask for toggles

Two AskUserQuestion calls with multiSelect: true (4-option limit per question):

- First: toggle Auto / Examine / Save / Test / Verify — each option label states the flag, each description states whether selecting it enables or disables given the current value.
- Second: toggle Economy / Branch / PR / Teams, plus a "Done - keep current" option.

## 3. Apply changes

Flip each selected flag. Implications: teams_mode=true also sets tasks_mode=true; pr_mode=true also sets branch_mode=true.

## 4. Show final configuration and return

Display the updated table, then return to `step-00-init.md` with all flags updated.

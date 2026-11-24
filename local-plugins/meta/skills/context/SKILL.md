---
name: context
description: Review what fills Claude Code's context in a project and reduce it, from the current official docs alone.
argument-hint: "[what to review]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh *) Bash(cat ${CLAUDE_PLUGIN_ROOT}/finish.md)
---

# Context

Task: $ARGUMENTS

!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh ${CLAUDE_PLUGIN_DATA} doc:https://code.claude.com/docs/en/context-window.md doc:https://code.claude.com/docs/en/features-overview.md doc:https://code.claude.com/docs/en/best-practices.md doc:https://code.claude.com/docs/en/costs.md`

Anthropic publishes no skill for this, so the DOC pages are the only method. Read in full their sections on what loads into the context window, what each kind of extension costs, and how to reduce it. Then do the task with what those sections say and nothing else: measure the way they say to measure, and propose only changes they support, each with the section it comes from. Change nothing before the user approves it.

!`cat ${CLAUDE_PLUGIN_ROOT}/finish.md`

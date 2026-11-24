---
name: rule
description: Create or improve a Claude Code rule (.claude/rules/) from the current official docs alone.
argument-hint: "[what to create or improve]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh *) Bash(cat ${CLAUDE_PLUGIN_ROOT}/finish.md)
---

# Rule

Task: $ARGUMENTS

!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh ${CLAUDE_PLUGIN_DATA} doc:https://code.claude.com/docs/en/memory.md`

Anthropic publishes no skill for rules, so the DOC page is the only method. Read in full its sections on `.claude/rules/`, path-specific rules, how instruction files load, and how to write instructions Claude follows. Then do the task with what those sections say and nothing else: where they leave a choice open (which scope, which paths, one file or several), ask the user.

!`cat ${CLAUDE_PLUGIN_ROOT}/finish.md`

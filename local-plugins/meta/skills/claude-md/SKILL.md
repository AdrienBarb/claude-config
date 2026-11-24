---
name: claude-md
description: Audit, improve or update CLAUDE.md files with Anthropic's claude-md-management, then check them against the current official docs.
argument-hint: "[what to audit, improve or add]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh *) Bash(cat ${CLAUDE_PLUGIN_ROOT}/finish.md)
---

# CLAUDE.md

Task: $ARGUMENTS

!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh ${CLAUDE_PLUGIN_DATA} src:claude-md-management/skills/claude-md-improver src:claude-md-management/commands/revise-claude-md.md doc:https://code.claude.com/docs/en/memory.md doc:https://code.claude.com/docs/en/best-practices.md`

The SOURCE paths are Anthropic's claude-md-management, read from their plugin catalog as they are today. To audit or improve the files, read `SKILL.md` in the claude-md-improver folder whole and follow it; its `references/` resolve inside that folder. To record what this session taught, read `revise-claude-md.md` whole and follow it.

!`cat ${CLAUDE_PLUGIN_ROOT}/finish.md`

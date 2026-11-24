---
name: skill
description: Create or improve a Claude Code skill with Anthropic's skill-creator, then check it against the current official docs.
argument-hint: "[what to create or improve]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh *) Bash(cat ${CLAUDE_PLUGIN_ROOT}/finish.md)
---

# Skill

Task: $ARGUMENTS

!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh ${CLAUDE_PLUGIN_DATA} src:skill-creator/skills/skill-creator doc:https://code.claude.com/docs/en/skills.md doc:https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md`

The SOURCE folder is Anthropic's skill-creator, read from their plugin catalog as it is today. Read its `SKILL.md` whole and follow it for the task. Its relative paths (`scripts/`, `agents/`, `references/`, `eval-viewer/`, `assets/`) resolve inside that folder, and its Python commands run from that folder.

!`cat ${CLAUDE_PLUGIN_ROOT}/finish.md`

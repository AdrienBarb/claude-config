---
name: hook
description: Create or improve a Claude Code hook with Anthropic's hook-development, then check it against the current official docs.
argument-hint: "[what to create or improve]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh *) Bash(cat ${CLAUDE_PLUGIN_ROOT}/finish.md)
---

# Hook

Task: $ARGUMENTS

!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh ${CLAUDE_PLUGIN_DATA} src:plugin-dev/skills/hook-development doc:https://code.claude.com/docs/en/hooks-guide.md doc:https://code.claude.com/docs/en/hooks.md`

The SOURCE folder is Anthropic's hook-development, read from their plugin catalog as it is today. Read its `SKILL.md` whole and follow it for the task; its relative paths (`scripts/`, `references/`, `examples/`) resolve inside that folder.

It was written for hooks shipped inside a plugin. For a hook in a settings file, the DOC pages decide the file, the format and the event names. Run the hook once on a real input before reporting it done.

!`cat ${CLAUDE_PLUGIN_ROOT}/finish.md`

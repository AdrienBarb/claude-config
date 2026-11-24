---
name: plugin
description: Create or improve a Claude Code plugin with Anthropic's plugin-dev, then check it against the current official docs.
argument-hint: "[what to create or improve]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh *) Bash(cat ${CLAUDE_PLUGIN_ROOT}/finish.md)
---

# Plugin

Task: $ARGUMENTS

!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh ${CLAUDE_PLUGIN_DATA} src:plugin-dev/commands/create-plugin.md src:plugin-dev/skills/plugin-structure src:plugin-dev/skills/plugin-settings src:plugin-dev/skills/mcp-integration src:plugin-dev/agents/plugin-validator.md doc:https://code.claude.com/docs/en/plugins/create.md doc:https://code.claude.com/docs/en/plugins/components.md doc:https://code.claude.com/docs/en/plugins/manifest-reference.md doc:https://code.claude.com/docs/en/plugins/marketplace-reference.md`

The SOURCE paths are Anthropic's plugin-dev, read from their plugin catalog as they are today. `create-plugin.md` is the workflow: read it whole and follow it for the task. That plugin is not installed, so its references resolve this way:

- "Load the X skill": read `SKILL.md` in the SOURCE folder named X.
- "Use the X agent": launch a general-purpose subagent with the body of the SOURCE file `X.md` as its instructions.
- A skill, an agent or a hook of the plugin: build it the way `/meta:skill`, `/meta:agent` and `/meta:hook` do, by reading that entry's `SKILL.md` under `${CLAUDE_PLUGIN_ROOT}/skills/` and following it.

!`cat ${CLAUDE_PLUGIN_ROOT}/finish.md`

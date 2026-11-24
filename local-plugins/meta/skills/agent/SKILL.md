---
name: agent
description: Create or improve a Claude Code subagent with Anthropic's agent-development and agent-creator, then check it against the current official docs.
argument-hint: "[what to create or improve]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh *) Bash(cat ${CLAUDE_PLUGIN_ROOT}/finish.md)
---

# Agent

Task: $ARGUMENTS

!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh ${CLAUDE_PLUGIN_DATA} src:plugin-dev/skills/agent-development src:plugin-dev/agents/agent-creator.md doc:https://code.claude.com/docs/en/sub-agents.md`

The SOURCE paths are Anthropic's, read from their plugin catalog as they are today. Read `SKILL.md` in the agent-development folder whole and follow it for the task; its relative paths resolve inside that folder. `agent-creator.md` is Anthropic's subagent that drafts an agent from a description: that plugin is not installed, so to use it, launch a general-purpose subagent with the body of that file as its instructions.

Both were written for agents shipped inside a plugin. For an agent in `.claude/agents/` or `~/.claude/agents/`, the DOC page decides where the file goes and which frontmatter it takes.

!`cat ${CLAUDE_PLUGIN_ROOT}/finish.md`

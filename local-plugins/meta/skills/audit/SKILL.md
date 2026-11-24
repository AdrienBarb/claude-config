---
name: audit
description: Audit the Claude Code configuration with Claude Code's own instruction audit, then Anthropic's automation recommender.
argument-hint: "[path to audit, default: everything]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh *)
---

# Audit

Scope: $ARGUMENTS

!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh ${CLAUDE_PLUGIN_DATA} src:claude-code-setup/skills/claude-automation-recommender`

1. Run Claude Code's own instruction audit: invoke the `claude-api` skill with the arguments `prompt-audit`, followed by the scope when one was given. It reads the CLAUDE.md and AGENTS.md files, the rules, skills, subagents and output styles, and reports what is outdated, broken or contradictory.
2. Read `SKILL.md` in the SOURCE folder whole and follow it for the current project. It is Anthropic's automation recommender, read from their plugin catalog as it is today; its `references/` resolve inside that folder.
3. Report both sets of findings. Change nothing before the user approves it.

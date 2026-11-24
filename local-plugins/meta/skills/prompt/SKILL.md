---
name: prompt
description: Write or improve a prompt with prompt-creator, on top of Anthropic's current prompting docs.
argument-hint: "[what to write or improve, and for which model]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh *) Bash(cat ${CLAUDE_PLUGIN_ROOT}/finish.md)
---

# Prompt

Task: $ARGUMENTS

!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh ${CLAUDE_PLUGIN_DATA} doc:https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices.md doc:https://platform.claude.com/docs/llms.txt`

1. Read the sections of the best-practices DOC page that the task touches, in full.
2. When the prompt is for a Claude model, find that model's "Prompting ..." page in the `llms.txt` index, download it with `bash ${CLAUDE_PLUGIN_ROOT}/scripts/prepare.sh ${CLAUDE_PLUGIN_DATA} doc:<its URL>`, and read it.
3. Read `${CLAUDE_PLUGIN_ROOT}/vendor/prompt-creator/SKILL.md` whole and follow it for the task; its `references/` resolve inside that folder. It is a frozen copy from January 2026 with no upstream, so the DOC pages decide wherever the two differ.

!`cat ${CLAUDE_PLUGIN_ROOT}/finish.md`

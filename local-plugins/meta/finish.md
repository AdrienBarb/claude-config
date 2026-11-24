## Finish

Where a SOURCE and a DOC disagree, the DOC wins: it is today's documentation, and a SOURCE can lag behind it.

1. Have the result checked against the DOC pages by a subagent that has not seen this conversation. Give it the paths of the files created or changed and the DOC paths, and ask for each place where a file departs from what the pages say, with the section that says otherwise. The pages are long: it reads in full the sections the files touch. "No deviation" is a valid answer.
2. Fix each deviation the pages support.
3. When the files are instructions for Claude (a skill, a rule, a subagent, a CLAUDE.md, a prompt), run Claude Code's own instruction audit on them: invoke the `claude-api` skill with the arguments `prompt-audit <path>`. Apply a proposed edit only once the user approves it.
4. Report what was created or changed, the deviations found and fixed, the audit's findings, and every `DOC CHANGED` line printed above.

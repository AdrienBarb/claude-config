# MCP servers and personal space

Before adding, moving or removing an MCP server, pick its place with these rules.

## Where an MCP server lives

- Global (`claude mcp add --scope user`, stored in `~/.claude.json`): only for servers useful in any folder, not tied to one project (today: context7, treg, mobbin, rea, anytype).
- Repo (`claude mcp add --scope project`, the `.mcp.json` at the repo root): the default for anything tied to one project.
- Local (`claude mcp add --scope local`, stored in `~/.claude.json` under the project): only for a server of mine inside a team repo that the team shouldn't get (today: `tagada` and `inngest-cloud` in tagadapay-app). Never for a repo of mine: use its `.mcp.json`.
- claude.ai connectors (Slack, Gmail, Granola…) are managed at claude.ai > Settings > Connectors and load everywhere. Don't duplicate one as a local or repo server.

## Rules

- No token in clear in a `.mcp.json`: reference an environment variable (`${VAR}`).
- In a team repo, don't edit the shared `.mcp.json` to remove a server I don't use: disable it for me only with `disabledMcpjsonServers` in the repo's `.claude/settings.local.json`.
- When a project is abandoned, remove its servers instead of leaving them.

## Personal space

`~/code/AdrienBarb/perso` holds everything personal, not work: personal skills in `.claude/skills/` (get-news, finances…), personal MCP servers in `.mcp.json`, and their data. A new personal skill or MCP goes there, not in `~/.claude/skills` or the global scope.

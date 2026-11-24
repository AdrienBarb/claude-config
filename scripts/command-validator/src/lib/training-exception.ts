// The background sessions that build Pickles' training run in their own worktrees, and
// the validator's word matches (inside heredocs, grep patterns, file names) stopped them
// many times a day. Inside those worktrees only, a command the validator would ask about
// passes, unless it reaches outside the task: privileges, a push to main or a forced
// push, a deletion aimed at an absolute, home or parent path, Adrien's Claude settings or
// scripts, an env file, or a process other than the task's own test server.
const TRAINING_WORKTREE =
	/^\/Users\/adrien\/code\/AdrienBarb\/(motherlode-t\d+[a-z]?|motherlode\/\.claude\/worktrees\/[^/]+)(\/|$)/;

const STOP_TEST_SERVER = [
	/\bkill(\s+-(9|15|TERM|KILL))?\s+\$\(\s*lsof\s+-ti\s*(tcp)?:\s*31\d\d(\s+-sTCP:LISTEN)?\s*\)/g,
	/\blsof\s+-ti\s*(tcp)?:\s*31\d\d(\s+-sTCP:LISTEN)?\s*\|\s*xargs\s+(-r\s+)?kill(\s+-(9|15|TERM|KILL))?(?=\s|;|&|\||$)/g,
	/\bpkill\s+-f\s+(['"])next dev -p 31\d\d\1/g,
];

const NEVER_IN_A_TASK = [
	/\bsudo\b/,
	/\bgit\s+push\b[^;&|]*(\bmain\b|--force|\s-f\b)/,
	/\brm\b[^;&|]*\s(\/|~|\.\.)/,
	/\.claude\/(settings|scripts)/,
	/\.env\b/,
	/\b(kill|pkill|killall)\b/,
];

export function isTrainingException(command: string, cwd: string | undefined): boolean {
	if (!cwd || !TRAINING_WORKTREE.test(cwd)) return false;

	let rest = command;
	for (const pattern of STOP_TEST_SERVER) rest = rest.replace(pattern, " ");

	return !NEVER_IN_A_TASK.some((rule) => rule.test(rest));
}

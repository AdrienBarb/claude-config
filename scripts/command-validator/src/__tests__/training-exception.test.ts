import { describe, expect, it } from "bun:test";
import { isTrainingException } from "../lib/training-exception";

const worktree = "/Users/adrien/code/AdrienBarb/motherlode-t2";
const contentWorktree = "/Users/adrien/code/AdrienBarb/motherlode/.claude/worktrees/content-saying-no";
const mainCheckout = "/Users/adrien/code/AdrienBarb/motherlode";

describe("isTrainingException", () => {
	const allowed: Array<[string, string]> = [
		["kill $(lsof -ti tcp:3103) 2>/dev/null; sleep 2", worktree],
		["kill -9 $(lsof -ti tcp:3101)", worktree],
		["kill $(lsof -ti tcp:3109 -sTCP:LISTEN) 2>/dev/null; npm run training:import", worktree],
		["lsof -ti tcp:3109 -sTCP:LISTEN | xargs kill", worktree],
		["lsof -ti tcp:3105 | xargs kill", worktree],
		["lsof -ti:3106 | xargs -r kill -9; npm run build", worktree],
		["chmod +x scripts/check.sh && ./scripts/check.sh", worktree],
		["kill $(lsof -ti tcp:3104)", `${worktree}/src`],
		["kill $(lsof -ti tcp:3107)", contentWorktree],
		['pkill -f "next dev -p 3107" ; sleep 0; lsof -ti tcp:3107 | xargs kill 2>/dev/null; npm run lint', worktree],
		["grep -rn '[dD]oor' src", worktree],
		["git rm -f src/components/plus/OfferCard.tsx", worktree],
		["rm -rf node_modules/.cache .next/dev/cache", worktree],
		["cat > /tmp/x.md <<'EOF'\nadd the dd step\nEOF", worktree],
		["python3 -c \"print('chmod')\"", worktree],
		["git merge --ff-only training/t18", worktree],
		["git push origin dev", worktree],
	];

	for (const [command, cwd] of allowed) {
		it(`allows in a training worktree: ${command}`, () => {
			expect(isTrainingException(command, cwd)).toBe(true);
		});
	}

	const refused: Array<[string, string | undefined]> = [
		["rm -rf build", mainCheckout],
		["rm -rf build", "/Users/adrien/code/AdrienBarb/tagada/tagadapay-app"],
		["rm -rf build", undefined],
		["sudo reboot", worktree],
		["kill $(lsof -ti tcp:3103) && sudo reboot", worktree],
		["git push origin main", worktree],
		["git push --force origin dev", worktree],
		["git push -f origin dev", worktree],
		["rm -rf /", worktree],
		["rm -rf ~/code", worktree],
		["rm -rf ../motherlode", worktree],
		["cat ~/.claude/settings.json", worktree],
		["sed -i '' 's/a/b/' /Users/adrien/.claude/scripts/x.ts", worktree],
		["cat .env.local", worktree],
		["kill 1234", worktree],
		["kill $(lsof -ti tcp:5432)", worktree],
		["kill $(lsof -ti tcp:3000)", worktree],
		["pkill node", worktree],
		["killall node", worktree],
		['pkill -f "next dev"', worktree],
	];

	for (const [command, cwd] of refused) {
		it(`still asks: ${command} (${cwd ?? "no cwd"})`, () => {
			expect(isTrainingException(command, cwd)).toBe(false);
		});
	}
});

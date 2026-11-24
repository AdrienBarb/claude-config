import type { ValidationResult } from "./types";

const DANGEROUS_COMMANDS = [
	"sudo",
	"su",
	"chmod",
	"chown",
	"dd",
	"mkfs",
	"fdisk",
	"kill",
	"killall",
];

export class CommandValidator {
	validate(command: string, _toolName = "Unknown"): ValidationResult {
		const result: ValidationResult = {
			isValid: true,
			severity: "LOW",
			violations: [],
			sanitizedCommand: command,
			action: "allow",
		};

		if (!command || typeof command !== "string") {
			result.isValid = false;
			result.violations.push("Invalid command format");
			result.action = "deny";
			return result;
		}

		// rm -rf → DENY (blocked completely)
		if (this.containsRmRf(command)) {
			result.isValid = false;
			result.severity = "CRITICAL";
			result.violations.push("rm -rf is forbidden - use trash instead");
			result.action = "deny";
			return result;
		}

		// Other dangerous commands → ASK (ask for permission)
		const dangerousCmd = this.containsDangerousCommand(command);
		if (dangerousCmd) {
			result.isValid = false;
			result.severity = "HIGH";
			result.violations.push(`Potentially dangerous command: ${dangerousCmd}`);
			result.action = "ask";
			return result;
		}

		return result;
	}

	containsRmRf(command: string): boolean {
		// Check for rm -rf in any form (rm -rf, rm -fr, rm -r -f, etc.)
		const rmRfPatterns = [
			/\brm\s+(-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*|-[a-zA-Z]*f[a-zA-Z]*r[a-zA-Z]*)\s/i,
			/\brm\s+-r\s+-f\s/i,
			/\brm\s+-f\s+-r\s/i,
		];

		for (const pattern of rmRfPatterns) {
			if (pattern.test(command)) {
				return true;
			}
		}

		return false;
	}

	containsDangerousCommand(rawCommand: string): string | null {
		// Adding the execute bit to named files (agents making their own scripts runnable) changes no ownership and
		// opens nothing to others, so it never needs a human. Recursive or numeric modes still ask.
		const command = rawCommand.replace(/(^|[;&|(`\n])\s*chmod\s+[ugoa]*\+x(\s+[^\s;&|`)-][^\s;&|`)]*)+/g, "$1 ");
		const normalizedCmd = command.trim().toLowerCase();
		const parts = normalizedCmd.split(/\s+/);
		const mainCommand = parts[0].split("/").pop() || "";

		if (DANGEROUS_COMMANDS.includes(mainCommand)) {
			return mainCommand;
		}

		// Check in chained commands: only where a command starts (after ; & | ( ` $( or a new line), so that the word
		// inside a string, like DD in 'YYYY-MM-DD', is not taken for the command.
		for (const dangerous of DANGEROUS_COMMANDS) {
			const pattern = new RegExp(`(^|[;&|(\`\\n])\\s*(\\S*/)?${dangerous}(\\s|$)`);
			if (pattern.test(command)) {
				return dangerous;
			}
		}

		return null;
	}
}

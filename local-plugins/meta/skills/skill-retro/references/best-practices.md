# Anthropic Agent Skills — distilled best practices

Snapshot date: **2026-08-06**. Refresh rule: before proposing a structural change, re-verify (WebFetch) any claim that decides it **if the snapshot is more than ~3 months old** — §9 claims are the most drift-prone. A fresh snapshot is authoritative on its own. Sources:

- https://code.claude.com/docs/en/skills — Claude Code skills reference (frontmatter, locations, listing economics)
- https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices — authoring best practices
- https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills — progressive disclosure, degrees of freedom
- https://code.claude.com/docs/en/features-overview — skills vs CLAUDE.md vs subagents vs hooks
- https://agentskills.io — Agent Skills open standard + eval methodology

## Contents

1. Structure and size
2. Frontmatter (Claude Code, current)
3. Descriptions and triggering
4. Progressive disclosure
5. Body writing
6. Evaluation and iteration signals
7. Right mechanism — skill vs CLAUDE.md vs subagent vs hook
8. Grading checklist (anti-patterns)
9. Changed recently — stale advice to distrust
10. Local conventions (this machine)

## 1. Structure and size

- A skill = a directory whose entrypoint is `SKILL.md`; optional `references/` (loaded on demand), `scripts/` (executed, source never enters context), `assets/` (used in output, never loaded), `examples/`.
- Three loading levels: metadata (name + description, ~100 words, always in context) → SKILL.md body (on trigger) → bundled files (on demand). Bundled content is effectively free until read.
- SKILL.md body: **under 500 lines / <5k words**; ideal 300–400 lines; split into references when approaching the limit.
- Reference files: 100–500 lines each; **>100 lines → table of contents at the top** (partial reads still reveal scope); >10k words → put grep patterns in SKILL.md.
- Once loaded, skill content **stays in context for the rest of the session** — every line is a recurring cost, so write standing instructions, not one-time narration.
- Never bundle README, CHANGELOG, setup or meta docs — only what the agent needs for the job.
- Locations and precedence on name collision: enterprise > personal `~/.claude/skills/` > project `.claude/skills/` > plugin (`plugin:skill`). Nested `.claude/skills/` in monorepo subdirs get directory-qualified names. Body edits are picked up at the next invocation; description/listing changes typically need a new session to affect auto-triggering — verify before claiming an immediate fix.

## 2. Frontmatter (Claude Code, current)

All fields optional; `description` is the one that matters. Key fields and exact semantics:

| Field | Semantics |
| --- | --- |
| `name` | Display only in personal/project skills — **the command comes from the directory name**. Lowercase/numbers/hyphens, ≤64 chars, no "anthropic"/"claude". |
| `description` | What it does + when to use it. ≤1,024 chars. If omitted, first body paragraph is used. |
| `when_to_use` | Extra trigger phrases appended to the listing; description + when_to_use truncate at **1,536 chars** in the listing. |
| `argument-hint` | Autocomplete hint, e.g. `[issue-number]`. |
| `arguments` | Named positional args for `$name` substitution. |
| `disable-model-invocation` | `true` = user-only; description removed from context (zero cost until invoked). For side-effect workflows (`/deploy`, `/commit`). |
| `user-invocable` | `false` = hidden from the `/` menu; Claude-only background knowledge. |
| `allowed-tools` / `disallowed-tools` | Pre-approved / removed tools — **turn-scoped: the grant clears on the next user message** even though skill content persists. |
| `model`, `effort` | Overrides for the rest of the turn. |
| `context: fork` + `agent` + `background` | Run body as a subagent prompt (no conversation history; background by default). Only for skills with explicit task instructions. |
| `paths` | Globs; auto-load only when working on matching files. |
| `hooks`, `shell`, `metadata`, `license`, `compatibility` | Lifecycle hooks; shell for `` !`cmd` ``; free-form/spec fields. |

- Substitutions available in body: `$ARGUMENTS`, `$ARGUMENTS[N]`, `$N`, `$name`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`; dynamic injection via `` !`command` `` runs before Claude sees the content.
- **Portability warning**: claude.ai uploads / Skills API accept only the spec's six fields (`name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`) and hard-fail on extras like `argument-hint`. Claude Code-only features don't travel.
- **Malformed YAML → the body still loads with empty metadata: auto-triggering silently dies while `/name` keeps working.** Always re-validate frontmatter after edits. Avoid `: ` (colon + space) inside plain-scalar descriptions.

## 3. Descriptions and triggering

- Always **third person** ("Queries prod Postgres…"), never "I can…" / "You can…".
- Formula: what the skill does + when to use it, with the **verbatim words users actually type** as triggers. Vague descriptions ("Helps with documents") never fire.
- **Front-load the key use case** — the listing truncates at 1,536 chars, and the whole skill listing shares a budget of ~1% of the context window; overflow drops least-invoked skills' descriptions first (`/doctor` reports the cost).
- The description carries the entire routing decision among 100+ skills; implementation detail belongs in the body.
- Not triggering → add the user's natural keywords; verify by asking "what skills are available?". Over-triggering → narrow the description or set `disable-model-invocation: true`.
- Sibling overlap is a routing defect: each description should name what it does NOT cover and which sibling to use instead (see §10 house style).

## 4. Progressive disclosure

- Every bundled file must be **linked from SKILL.md with a one-line statement of when to read it** — unlinked files are invisible.
- **References one level deep only** (`SKILL.md → file.md`, never chained `a.md → b.md`): nested chains get partial reads.
- No duplication between SKILL.md and references — each fact lives in exactly one place.
- Keep mutually exclusive contexts in separate files (per-domain, per-variant) so only the relevant one loads.
- Relative paths in links; descriptive filenames (`form-validation-rules.md`, never `doc2.md`, `misc.md`).

## 5. Body writing

- Imperative/infinitive form throughout; concise — "the context window is a public good"; assume Claude is already smart; challenge every paragraph's token cost.
- Match **degrees of freedom** to fragility: heuristics when many approaches work; pseudocode/parameterized patterns when one is preferred; exact scripts when operations are fragile and order matters.
- Prefer **"Do X because Y" over bare ALWAYS/NEVER** — models comply better when they understand why; reserve caps-lock rules for the few hard gates.
- 2–4 input/output examples whenever output format matters; exact templates for strict formats, "sensible default" phrasing when adaptation is fine.
- Checklists for multi-step workflows; explicit decision points for branching; validator-fix-repeat loops for quality gates.
- Scripts: state whether to **execute or read**; solve errors inside the script; no magic constants; list required packages; idempotent; test by running them.
- No time-sensitive info in the body (no "new as of June"); consistent terminology throughout.

## 6. Evaluation and iteration signals

- Measure two things **separately**: (a) does it trigger on the right prompts, (b) is the output right when it does. Both by **baseline comparison** — same prompts in a fresh session with vs without the skill (authoring-session context masks gaps).
- Official tooling since 2026-03: the **skill-creator plugin** (`/plugin install skill-creator@claude-plugins-official` — distinct from any local skill-creator skill) automates evals — `evals/evals.json` test cases, isolated runs with token/duration tracking, assertion grading, with/without benchmark, blind A/B between two skill versions, and description tuning (should-trigger vs should-not-trigger prompt sets).
- Iteration signals from real trajectories:
  - a reference file **re-read constantly → merge into SKILL.md**;
  - a bundled file **never touched → delete**;
  - unexpected read order → structure is unintuitive;
  - high variance across runs → ambiguous instructions, add examples;
  - **pass rates plateau despite more rules → the skill is over-constrained: remove instructions**;
  - every run rewrites the same helper → bundle it as a script;
  - the base model succeeds without the skill → the skill is dead weight.
- Write assertions after seeing first outputs; objective and countable; grade with evidence, no benefit of the doubt.
- Test with every model that will run the skill (Haiku needs more guidance than Opus). Re-run evals on model updates to catch regressions and obsolescence.
- Session mechanics relevant to "it stopped working mid-session": re-invocation adds a note, not a duplicate; compaction re-attaches each skill's most recent invocation, first 5,000 tokens each within a 25,000-token combined budget, least-recent dropped first. If a skill must not be forgotten, hooks — not repetition — are the guarantee.

## 7. Right mechanism — skill vs CLAUDE.md vs subagent vs hook

| Symptom | Mechanism |
| --- | --- |
| Convention corrected twice (tone, format, naming, preference) | CLAUDE.md rule (keep CLAUDE.md < ~200 lines; facts, not procedures) |
| Same prompt retyped / same playbook pasted again | Skill |
| CLAUDE.md section grew into a procedure | Move it to a skill (costs nothing until used) |
| Side task floods the context | Subagent (skills load into your window; subagents return summaries) |
| Must happen deterministically every time | Hook — a skill is a request, a hook is a guarantee |
| Second repo needs the same setup | Plugin |
| Always-on but only for some paths | `.claude/rules/` file with `paths` frontmatter |

- Slash commands are no longer a separate concept: a skill IS the command (`.claude/commands/` still works but is legacy — migrate opportunistically).
- `context: fork` composes skills with subagents, but only for self-contained task bodies — never for anything that must see the conversation.

## 8. Grading checklist (anti-patterns)

Structural: SKILL.md >500 lines; duplicated content; unlinked or chained references; generic filenames; README/CHANGELOG clutter; auxiliary run outputs or `node_modules/` inside the skill dir.
Descriptions: first person; vague scope; no verbatim triggers; key use case buried past the truncation point; overlap with a sibling and no DO NOT USE boundary.
Body: markdown narration of things the model already knows; vague hedges ("try to", "if possible"); ALL-CAPS rules without reasons; missing success criteria; missing examples where format matters; time-stamped facts that rot.
Scripts: hardcoded paths, silent failures, magic numbers, non-idempotent, never actually run.
Frontmatter: broken YAML (silent auto-trigger death); `: ` inside plain scalars; portability-breaking fields on skills meant to be shared; `disable-model-invocation` missing on side-effect workflows.

## 9. Changed recently — stale advice to distrust

1. Slash commands merged into skills; `.claude/commands/` is legacy-but-working.
2. `name` no longer sets the command in personal/project skills — the directory name does.
3. Newer frontmatter fields exist: `when_to_use`, `arguments`, `effort`, `background`, `paths`, `shell`, `disallowed-tools`, `hooks` — older field lists are incomplete.
4. `allowed-tools` is turn-scoped now, not session-scoped.
5. Forked skills run in the background by default.
6. Evaluation went from "roll your own" to the official skill-creator eval loop (March 2026).
7. Listing economics (1,536-char cap, 1% budget, least-used dropped first) are new — front-load descriptions.
8. Guidance now favors reasoned instructions ("X because Y") and **removing** rules from over-constrained skills, over piling on MUST/NEVER.

## 10. Local conventions (this machine)

- Personal skills: `~/.claude/skills/<dir>/SKILL.md`. Project skills: `<repo>/.claude/skills/`. Legacy commands: `~/.claude/commands/*.md` (works; migrate to skills when touched). A skill in the listing but in none of these locations is either a plugin skill (check `~/.claude/plugins/…`; names carry a `plugin:` prefix) or built into Claude Code. Both are read-only here: for built-ins the only proposal is a personal override skill with the same name; plugin skills are maintained in their plugin.
- House description style (established by the tagadapay project skills, apply when editing any skill here): one opening sentence stating exactly what the skill does and its scope → `USE WHEN` + concrete situations → `Triggers —` verbatim quoted user phrasings (English AND French — the user writes both) → the single tool it owns, if any → `DO NOT USE for` each exclusion naming the sibling skill to use instead.
- Known overlap cluster to disambiguate against when touching anything frontend: frontend-patterns, react-patterns, react-testing, frontend-design, impeccable, vercel-react-best-practices, plus the react-build/review/test commands.
- Hygiene precedent: never let a skill dir accumulate `node_modules/` or run outputs (see job-hunt, 2,900+ files); run outputs and state files live outside skill dirs (skill-retro keeps its own log in `~/.claude/skill-retro-data/`).
- If a project documents its skills (tagadapay-app lists them in CLAUDE.md), creating/renaming/deleting a project skill must propose the registry update too.

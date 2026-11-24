---
name: skill-retro
description: Retrospective on skill usage in the current conversation — grades every skill that fired or should have fired, detects repeated asks and corrections, and proposes evidence-based improvements — edits, merges, splits, deletions, new skills, CLAUDE.md rules, or hooks — grounded in Anthropic's current Agent Skills best practices. USE WHEN the user asks to review how skills performed in this conversation — "skill retro", "retro des skills", "analyse les skills", "review skill usage", "did the skills work well", "quels skills améliorer", "propose skill improvements", "skill cleanup". Proposes first, edits files only after explicit approval. DO NOT USE to author a brand-new skill with no conversation to analyze (use skill-creator), to edit a named skill on direct request outside a retro (use skill-manager), to discover or install skills (use find-skills), or to improve a standalone prompt (use prompt-creator).
argument-hint: "[skill names to focus on | blank = all]"
disable-model-invocation: true
---

<objective>
Run an evidence-based retrospective on how skills performed in THIS conversation, then turn it into concrete maintenance — edits, merges, splits, deletions, new skills, CLAUDE.md rules, or hooks. Every claim must be backed by a quotable moment from the conversation. Propose first; touch no skill, rule, or hook file until the user approves specific proposals.
</objective>

<workflow>
1. **Scope** — $ARGUMENTS names specific skills to focus on; blank means all skill activity in the conversation.
2. **Reconstruct skill activity** from the conversation history:
   - Invocations: every Skill tool call, `/command` block, and skill-load marker visible in the history.
   - Misses: moments where the task matched a listed skill's description but the work was done manually — including when a skill's owned tool (its single MCP tool or bundled script) was called directly without the skill ever loading.
   - Wrong picks: a skill fired where a sibling was the right one.
   - Friction: every user correction or repeated instruction, whether or not a skill was involved. Count repetitions and keep the user's verbatim wording.
   - If the conversation has no invocations and no plausible misses, say so and fall back to retro-log-only proposals (recurrent findings, skills untouched across 3+ logged runs) — or report that there is nothing to grade.
3. **Read the retro log** (path in <retro_log>). A finding already present in an earlier entry is recurrent and outranks everything found only once.
4. **Read before judging** — for each skill under review, read its actual SKILL.md plus any bundled file the conversation used. Check locations in the loader's collision-precedence order, and always judge and edit the copy that actually loads: personal `~/.claude/skills/<name>/`, then project `.claude/skills/<name>/`, then plugin trees (`~/.claude/plugins/…`; names carry a `plugin:` prefix), then legacy `~/.claude/commands/*.md`. A listed skill found in none of these is built into Claude Code — read-only; the only possible proposal is a personal override skill with the same name (plugin skills are maintained in their plugin). If an invoked skill's source is nowhere on disk, grade Outcome only, mark the other axes n/a, and report the source as unlocatable. Never propose an edit to a file not read this session.
5. **Grade** each skill with <rubric>. Read `references/best-practices.md` before grading structure or description quality and before drafting any proposal; obey its refresh rule if the snapshot is stale.
6. **Detect creation and deletion candidates** with <creation_signals>.
7. **Report** using <report_format>, then ask which proposals to apply.
8. **Apply only approved proposals.** New skills: invoke the skill-creator skill. After any edit, re-check the result against reference §2 (frontmatter) and §8 (grading checklist), and validate the frontmatter mechanically — `python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]).read().split('---')[1])" SKILL.md`, or without PyYAML confirm the skill still shows its description in a fresh session's listing (malformed YAML silently kills auto-triggering while `/name` keeps working). Description changes typically need a new session to affect auto-triggering — do not claim an immediate fix. If the project documents its skills in a registry (e.g. a CLAUDE.md table), propose updating it too. Finally append the run to the retro log, recording each proposal's outcome (applied | rejected | deferred).
</workflow>

<rubric>
Grade each skill on five axes; verdict = worked | partial | failed | missed | untested. "Untested" = named in $ARGUMENTS but no activity this conversation — record the verdict, propose nothing.

- **Triggering** — fired at the right moment? Compare the user's actual wording against the description. Three miss diagnoses: a miss despite matching vocabulary = routing/description defect; a miss with different vocabulary = add the user's verbatim phrase as a trigger; vocabulary matched but the skill's owned tool was called directly = bypass → propose a PreToolUse hook on the owned tool (or record it as a compliance note), not a description edit. Explicitly user-invoked skills: triggering n/a; grade the remaining axes.
- **Compliance** — did the run follow the skill's instructions, or deviate, flounder, or re-derive information the skill already contains? Re-derivation means the information is buried: wrong file, nested too deep, or not linked from SKILL.md.
- **Outcome** — did the user accept the result, or correct and redo it? Each correction is evidence; two or more corrections of the same kind mean the skill (or a rule) must encode it.
- **Context economy** — lines loaded versus lines used. A reference file re-read constantly should merge into SKILL.md; a bundled file never touched is a deletion candidate; a SKILL.md near 500 lines should split.
- **Freshness** — stale paths, commands, URLs, or facts the run had to work around → update proposal.
</rubric>

<creation_signals>
Route repeated needs to the right mechanism — not everything deserves a skill (decision table in reference §7):

- Same instruction or correction ≥2 times about tone, format, length, or preference → rule territory. **First read the user-level and project CLAUDE.md.** If an equivalent rule already exists, the finding is non-compliance, not absence: quote the existing rule, diagnose why it failed (buried, vague, contradicted by another rule), and propose strengthening or relocating it — or converting it to a hook. Never propose a duplicate rule. If no rule exists, propose one (user-level if project-independent).
- Recurring multi-step procedure done by hand, or the same prompt re-typed across sessions → **new skill**, description drafted in the house style (reference §10). Recurrence evidence = the retro log OR the user's explicit in-conversation statements about prior sessions, quoted verbatim.
- A recurring end-to-end pipeline that sequences existing skills → **new orchestrator skill** that delegates to the named siblings and lists them in its DO NOT USE line.
- Something that must happen deterministically every time → **hook**, not a skill (reference §7).
- A CLAUDE.md section that has grown into a procedure → move it to a skill.
- Deletion/merge candidates: overlapping skills that caused a wrong pick, skills superseded by a sibling or by model ability, skills untouched across three or more retro-log runs.
</creation_signals>

<report_format>
Write the report in the language the user writes in. Keep everything before the proposals to one screen.

**Verdict line** — X skills invoked, Y worked, Z with problems, N proposals.
**Friction line** — N repeated corrections, the most-repeated one quoted verbatim.

| Skill | Verdict | Evidence (one line) |
| --- | --- | --- |

**Proposals** — numbered P1…Pn, highest impact first, recurrent findings on top. Per proposal, ≤6 lines for the header; exact replacement text, description drafts, and file plans go in a fenced block below the header, uncapped:
- **Target** — skill path, "new skill", CLAUDE.md, or hook
- **Type** — edit | create | delete | merge | split | relocate | convert-to-rule | convert-to-hook
- **Evidence** — quoted conversation moment(s), plus "recurrent, Nth run" when the retro log confirms it
- **Effect** — what improves next time

Close by asking which proposals to apply (or none).
</report_format>

<retro_log>
Path: `~/.claude/skill-retro-data/retro-log.md` — deliberately outside the skill directory so run outputs never accumulate in it (reference §8/§10). Create the directory if missing. Read only the newest 10 entries; when the file exceeds 30 entries, delete the oldest. Append one block per run, at the END of the run — after the user's apply/reject decision:

```
## <date> — <project dir> — <one-line conversation topic>
graded: <name>=<verdict>, …
findings: one line each
proposals: P1 <summary> (applied|rejected|deferred), …
```

Statuses matter — a proposal rejected twice is not re-proposed without new evidence; a recurrent finding is announced as such and leads the report.
</retro_log>

<constraints>
- Never edit, create, or delete any skill, rule, hook, or registry file before the user approves the specific proposal — the report is the default deliverable. Exception: the retro log (this skill's own state file, outside the skill dir) is written at the end of every run without asking.
- Never invent evidence. A claim that cannot be tied to a quotable moment is dropped.
- Judge only skills with activity in the conversation (or that plausibly should have fired). Do not audit the whole library uninvited — except to flag overlap directly implicated in a wrong pick.
- This skill depends on the live conversation history: never run it forked, in a subagent, or from a summary.
- Proposals must comply with `references/best-practices.md`; when it conflicts with a project's own established skill style, follow the project style and say so in the proposal.
- Distinguish skill defects from everything else: a skill that was fine while the user's request was out of its scope is "worked", not "failed" — the gap belongs to routing, rules, or a missing sibling skill.
</constraints>

<reference_guides>
- `references/best-practices.md` — Anthropic Agent Skills best practices, distilled and dated, with source URLs and a refresh rule. Read before grading structure or descriptions and before writing any proposal.
</reference_guides>

<success_criteria>
- Every invoked, missed, bypassed, or misrouted skill appears in the table with a verdict and quoted evidence.
- Every repeated user correction (≥2) yields exactly one proposal, routed to skill, new rule, strengthened-existing-rule, or hook — never silently dropped, and never a duplicate of a rule that already exists.
- Proposals are concrete enough to apply without further questions (exact text for description edits, name + description + file plan for creations).
- No skill, rule, or hook file was modified without explicit approval of the specific proposal; the retro log gained one entry at run end with real outcomes.
</success_criteria>

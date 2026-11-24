---
name: review
description: Review code changes with parallel reviewers on separate axes - does it do what the spec asked, logic and edge cases, security, repo standards and clean code, maintainability, and the domains the diff touches. Use when the user asks to review code, a diff, a branch or a PR, or to check quality or security. Reports findings; fixes nothing.
argument-hint: "[PR number | branch | commit | file paths] [spec or ticket reference]"
---

# Review

One review of a code change, on several axes that each run in their own subagent so they do not colour each other. This skill reports. It changes no code: the caller, a person or `code:apex`, decides what to fix.

## 1. Pin the change

Decide what is under review, in this order:

1. What the caller passed: a PR number (`gh pr diff <n>`), a branch or commit (`git diff <ref>...HEAD`, three dots, so the comparison is against the merge-base), or file paths.
2. Otherwise, the uncommitted changes: `git diff` plus `git diff --cached`.
3. Otherwise, the current branch against the default branch's merge-base.

Check the diff is not empty before going further. If it is, ask what to review. Note the diff command and the list of changed files: every reviewer gets the same ones.

## 2. Find the spec

The spec axis needs to know what was asked. Look, in this order:

1. A spec, ticket or plan reference the caller passed.
2. A ticket or issue reference in the commit messages, fetched the way the tracker record says. The tracker record is the file that the `### Issue tracker` section of `CLAUDE.md`, `CLAUDE.local.md` or `AGENTS.md` points to, which may sit outside the repo; without such a section, it is `docs/agents/issue-tracker.md`.
3. A feature folder matching the branch name, under `.scratch/` or wherever the tracker record keeps features: its `spec.md`, the ticket being worked, and `runs/<ticket>/plan.md` if present.

If nothing is found, ask once. If there is no spec, skip the spec axis and say so in the report.

## 3. Choose the axes

| Axis | When | Reference to pass |
| --- | --- | --- |
| **Spec** | a spec, ticket or plan was found | the spec, ticket and plan themselves |
| **Logic and edge cases** | always | none |
| **Standards and clean code** | always | `references/clean-code-principles.md`, `references/code-quality-metrics.md`, plus every file in the repo that documents how code is written (`CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `.claude/rules/`) |
| **Maintainability** | always | `references/maintainability-rubric.md` |
| **Security** | the diff touches backend code, auth, API routes, env handling, crypto or payments | `references/security-checklist.md` |
| **Backend** | the diff touches API, database or service code | `references/backend-patterns.md` |
| **UX/UI** | the diff touches `.tsx`, `.jsx`, `.css` or component folders | `references/ux-ui-checklist.md` |

For a tiny change (one or two files, under 50 lines), run only Spec and Logic.

When the diff touches React or Next.js code and the `vercel-react-best-practices` skill is available, tell the Standards reviewer to load it too.

## 4. Send the reviewers

Launch every chosen axis in one message, one subagent each, with `subagent_type: "code-reviewer"`. If that agent type is not available, use a general-purpose subagent with the same prompt. Start each with a fresh context window.

Each prompt contains: the axis, the diff command, the list of changed files, the absolute paths of its reference files (this skill's folder plus the path in the table), and its brief. Reviewers read the changed files in full, not only the diff.

Briefs:

- **Spec**: "Report (a) what the spec asked for that is missing or partial, (b) behaviour in the diff nobody asked for, (c) requirements that look implemented but are implemented wrongly. Quote the spec line for each finding."
- **Logic and edge cases**: "Assume bugs exist and find what the tests miss: empty, null and boundary inputs, race conditions, off-by-one and inverted conditions, missing error handling, state bugs, wrong assumptions about the shape of the data."
- **Standards and clean code**: "Report every place the diff breaks a rule the repo documents, citing the file and the rule. Then apply the reference checklists. A documented repo rule always wins over a generic principle. Skip anything a linter or formatter already enforces."
- **Maintainability**: "Apply the rubric strictly to the changed files. Look for the restructuring that would make this change dramatically simpler, and prefer deleting complexity to rearranging it."
- **Security**, **Backend**, **UX/UI**: "Apply your reference checklist to the changed files."

Every prompt ends with: "For each finding give file:line, severity (CRITICAL: security or data loss; HIGH: a real bug; MEDIUM; LOW), what is wrong, why it matters, and a concrete fix. Report only what you are at least 80% sure of. No style nitpicks. If you find nothing, say so explicitly. Return findings only, one short block each, most severe first, fifteen at most: no account of what you read, no summary, no praise."

## 5. Report

Do not take a finding at face value: for each one, open the cited line and mark it **Real**, **Noise** (wrong, or already handled) or **Uncertain**, with one line of justification. Never drop a finding without saying why.

Present, in this order:

1. **Spec**: its findings on their own, never merged with the rest. Code can be clean and still build the wrong thing, and one axis must not hide the other.
2. **Code**: one table for all the other axes, sorted by severity: id, severity, axis, location, issue, validity, fix. When two axes flag the same line, keep the most precise finding and name both axes.
3. One closing line: findings per severity, how many are Real, and the worst one on each side.

When the caller gave a folder for working notes, or the change belongs to a feature folder, write the report to `review.md` there (`<feature folder>/runs/<ticket>/review.md` for a ticket).

Stop there. Do not fix anything.

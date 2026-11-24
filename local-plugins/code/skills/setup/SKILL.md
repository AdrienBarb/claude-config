---
name: setup
description: Set up a repo for the code skills by recording where its specs and tickets live and how a change is verified in the running app. Run once per repo, or again to change either.
disable-model-invocation: true
---

# Setup

Record, once per repo, two things the other code skills read: where specs and tickets live, and how a change is verified in the running app.

The first record is one file: `docs/agents/issue-tracker.md`. Without it, the other skills fall back to local files under `.scratch/`, so this skill is only required to choose something else, or to make the local convention explicit in the repo.

## 1. Look at the repo

Read what is there before asking anything:

- `docs/agents/issue-tracker.md`, or the file an `### Issue tracker` section of `CLAUDE.md`, `CLAUDE.local.md` or `AGENTS.md` points to: is the repo already set up?
- `git remote -v`: GitHub, GitLab, or no remote?
- `.scratch/`: are local specs and tickets already in use?
- `.gitignore`: is `.scratch/` ignored?
- `CLAUDE.md` and `AGENTS.md` at the root: which one exists, and does it already have an `## Agent skills` section?

If `docs/agents/issue-tracker.md` already exists, show its first lines and ask whether to keep it or replace it. On "keep", go straight to step 4. Treat an existing `docs/agents/verify.md` the same way: show it, and on "keep" skip step 4.

## 2. Ask where specs and tickets live

One question, with the recommended answer first so one word accepts it.

- **Local files** (recommended when nothing else is in use): everything under `.scratch/<feature-slug>/` in the repo. No account, no network, works offline.
- **GitHub issues**: propose it when a remote points at GitHub and the user tracks work there. Uses `gh`.
- **GitLab issues**: same, for a GitLab remote. Uses `glab`.
- **Other** (Linear, Jira, …): ask the user to describe it in a few lines: which tool or MCP server, which team or project, which labels or statuses mean "open", "in progress" and "done".

For local files, ask one more question: is `.scratch/` committed with the code (recommended: yes)? Committed, every session and every worktree sees the same specs and tickets after a pull, and the history of a feature stays with the code. Ignored, each worktree keeps its own private copy.

For GitHub or GitLab, check the CLI reaches the repo (`gh repo view` / `glab repo view`) before writing anything. If it does not, stop and say what is missing.

## 3. Write the record

Write `docs/agents/issue-tracker.md` from the matching template in this skill's folder:

- [issue-tracker-local.md](./issue-tracker-local.md)
- [issue-tracker-github.md](./issue-tracker-github.md)
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md)

For "other", write the file from the user's description, keeping the same headings as the templates so every skill finds the same operations: where the spec goes, how to create a ticket, how blocking is expressed, how to find the next ticket, how to claim one, how to resolve one.

For local files, apply the commit choice: remove `.scratch/` from `.gitignore` when committed, add it when ignored.

## 4. Record how a change is verified

`code:verify` plays a change in the running app. What it needs to know about this repo goes in `docs/agents/verify.md`. Without that file it works things out from the repo each time, so this step saves that work and removes the guessing.

Find the answers before asking for them: the scripts in `package.json`, the sections of `CLAUDE.md` and `AGENTS.md` about running or testing the app, any skill or script of the repo that already tests in a browser, seed scripts, dev-only pages. Draft the file from [verify.md](./verify.md), keeping only the sections that apply and filling them with what you found. If the repo already has its own browser-test skill or procedure, the file mostly points to it.

Show the draft and let the user correct it before writing. Leave out any section you could not establish; do not guess.

## 5. Point to it

Add this block to `CLAUDE.md` if it exists, otherwise to `AGENTS.md`. If neither exists, ask which one to create. If an `## Agent skills` section is already there, update its `### Issue tracker` and `### Verification` parts in place instead of adding a second section.

```markdown
## Agent skills

### Issue tracker

[One line: where specs and tickets live]. See `docs/agents/issue-tracker.md`.

### Verification

[One line: how a change is played in the running app]. See `docs/agents/verify.md`.
```

## 6. Done

Say in three lines where specs and tickets now live, how a change gets verified, and that both files under `docs/agents/` can be edited by hand later.

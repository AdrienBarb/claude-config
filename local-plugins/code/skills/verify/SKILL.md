---
name: verify
description: Verify a change by using the running app the way a real user would - a real browser for a UI, real requests for an API, real commands for a CLI - and report PASS or FAIL per acceptance criterion, with proof. Use when the user asks to test, verify, try or check a change or a feature in the browser or in the running app.
argument-hint: "[what to verify | ticket reference]"
---

# Verify

Types, lint and tests passing is where testing starts. A change is verified when someone has used it, in the running app, the way its user would. This skill does that and reports. It fixes nothing: the caller, a person or `code:apex`, fixes a failure and calls this skill again.

## 1. Know what is being verified

**The criteria.** Take them, in this order, from: the ticket passed as argument and its acceptance criteria; the spec of the feature; the request made in this conversation. If none exists, derive the criteria from the diff, state them, and say they were inferred. Keep the original request at hand: the verdict is against what was asked, not only against the criteria.

**The change.** List the changed files (`git diff --name-only` against the base) and work out which screens, endpoints or commands they reach. Those are what gets played.

## 2. Learn how this repo is verified

The verification record is the file that the `### Verification` section of `CLAUDE.md`, `CLAUDE.local.md` or `AGENTS.md` points to, which may sit outside the repo; without such a section, it is `docs/agents/verify.md`.

If it exists, follow it. It says how to start the app, how to sign in, how to reach a state, which screen sizes matter, what else to check, and what is off-limits. If it hands verification to a skill of the repo, call that skill with the criteria and go straight to step 5 with what it returns.

If it does not exist, work it out from the repo: the sections of `CLAUDE.md` and `AGENTS.md` about running or testing the app, the scripts in `package.json`, the README. Then proceed; do not ask the user to run `code:setup` first.

Two rules hold in every repo:

- **Never production.** If the only environment you can reach is production, stop and say so.
- **Respect how servers are run.** If the repo says a server is managed by a tool or must not be started by hand, do not start one yourself.

## 3. Reach the code under test

Before playing anything, prove that the app in front of you runs the changed code. A server serves one checkout: when the change sits in another worktree or on another branch, a page that loads proves nothing. Look for a marker only the change produces (a new label, a new route, a new field in a response), or check which folder the serving process runs from.

Take the highest rung that reaches the change, and fall back only after a rung was tried and failed:

1. The running app on the changed code, through its real interface.
2. The same app's API, called with a real session, when no screen can express the case.
3. Rung 1 or 2 after seeding the data the case needs.
4. An integration test on a real database with one third party mocked. Name which one.
5. A unit test. It proves the function, never the pipeline that feeds it, and never suffices alone for a change a user can see.

Report which rung produced the result. "I could not test it" is not a result: before saying it, name each rung you tried and what stopped it. A rung you assumed would fail does not count as tried.

## 4. Play

Hand the play to one subagent with a fresh context window: the session that wrote the code sees what it expects to see. Its prompt contains the criteria, the original request, how to reach the app (steps 2 and 3), the screens to play, the rules below, and the folder where screenshots go. The player writes the full account of the play to `verify.md` in that folder itself, and returns only the table of step 5, so this session stays small. If this session cannot start subagents, play it yourself and say so in the report.

For a web interface, drive a real browser with the tool the repo names; by default, the `dev-browser` skill. For an API, real HTTP requests. For a CLI, the real command.

Rules of play:

- **As a user.** Click, type, navigate. Never reach a result by calling an internal function or editing the database by hand, except to set up a starting state the repo's record allows.
- **The whole path.** Play each criterion from where the user enters to where they leave.
- **Every state.** Look at each touched screen in each state it can be in: empty, filled, loading, error, disabled.
- **Then try to break it.** Every button, link and field on the touched screens; the back button; a refresh in the middle of the flow; the screen's URL typed directly; signed out, and as another account, where that matters; nothing typed, too much typed, pasted text, emoji; a double click on a submit; a slow network; two tabs.
- **Sizes.** The ones the repo names; otherwise, for a responsive interface, a phone width (390 × 844) and a desktop width (1440 × 900).
- **Keyboard.** Tab through each touched screen once: every control reachable, focus visible.
- **Watch while playing.** The browser console, failed requests, the server's output. An error or a warning coming from our code is a failure even when the screen looks right.
- **Check what was written.** When the change writes something (a row, an email, a job, an event), look at what was written, not only at the screen.
- **Keep the proof.** A screenshot per screen and state, saved to the folder given, and for each criterion what was done and what was seen.
- **Clean up.** At the end, close every page of the browser opened for the play (a browser name for this player alone; never stop another session's browser), delete every copy or scratch file made for it, end every background command, and say so in the report.

Play the change, not the whole app. A bug seen on the way that the change did not cause is noted separately, not chased.

## 5. Report

Do not relay the play as fact. Open the screenshot behind every FAIL, and behind enough PASSes to trust the rest. A claim with no proof behind it is NOT VERIFIED, never PASS.

Present:

1. One table: criterion, what was done, what was seen, PASS / FAIL / NOT VERIFIED, proof (path to the screenshot or the output).
2. The environment and the rung reached.
3. What is missing or wrong against the original request, beyond the criteria.
4. Errors seen in the console, the network or the server output.
5. "Also seen": bugs the change did not cause.

The verdict is PASS only when every criterion is PASS and no error came from our code. Anything else is FAIL, with the exact list of what to fix.

When the change belongs to a feature folder, the report lives at `<feature folder>/runs/<ticket>/verify.md`: add the verdict at its top and keep the screenshots in `screenshots/` beside it. When the caller gave a folder for working notes, use that one.

Stop there. A FAIL is fixed by the caller and played again; it is never reported as done.

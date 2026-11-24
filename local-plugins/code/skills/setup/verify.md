# Verification

How a change is verified in the running app of this repo. `code:verify` reads this file before it plays anything.

Keep only the sections that apply, and fill them with what is true here. A section left as a guess is worse than a missing one.

## Use the repo's own procedure

_Only when this repo has its own skill or script for testing in a browser._ Name it and say that all verification goes through it. The rest of this file can then stay short.

## Start the app

The command, the URL, and how to tell it is up (a health URL, a log line). Who starts it: the agent, or a tool that must not be bypassed.

## Which code the app serves

Which checkout or branch the running server serves. How to get the app running on a branch or a worktree: a second server, a preview deployment, a command.

## Sign in

The test account and how to sign in with it. Where one-time codes or test emails can be read.

## Reach a state

How to start from a given state without replaying a whole flow: seed scripts, fixtures, a dev page, a way to move time.

## Screens and sizes

The screen sizes that matter, and where the mockups or the design reference live.

## Beyond the screen

What to check besides the page: the database, sent emails, queued jobs, logs. How to read each one.

## Off-limits

The URLs, environments, databases and files that must never be touched.

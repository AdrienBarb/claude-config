# The briefs

A subagent sees nothing of the lead's conversation: its brief is its whole world. Fill one of these in and pass it as the whole prompt. What stands between `<` and `>` comes from the preparation and from the progress file.

## Contents

- The builder's brief: one ticket, in a lane
- The corrections brief: a lot of findings that is not a ticket
- The player's brief: the short pass in a browser

## The builder's brief

```
Work ticket <ticket reference> in <lane folder>. It is a copy of the repo on its own branch; other
builders work in other copies at this moment. You know nothing of the conversation that sent you:
everything you need is in the files named here.

- Read first: <the repo's rule files>, the ticket, its spec at <spec reference>, and the `## Report`
  of each ticket that blocks it.
- Build it with the skill `code:apex -a -e -t <ticket reference>`. `-e` is required: you cannot
  launch subagents. An independent review reads your work later, with the tickets around it, and
  the user plays it in the browser at the end of the batch: do not play it yourself, whatever the
  repo's documents say about playing a ticket. Open each screen you touched once, to see that it
  renders without an error, and stop there. Do not run the production build: I run it.
- Stay in your lane's folder. Never commit, never push, never merge, never change branch: I do.
  Edit no ticket file but your own: what a later ticket must know goes in your report, and I
  write it there.
- What the copies share: <the test command, through locked.sh; your port <port> for a dev server
  and what it needs to run there; when a real call to a paid service is allowed; the one ticket
  that may change the schema>. The test command waits for its turn behind the other copies: run
  it in the background, or with the longest timeout. Stop your dev server by its port before
  your last message.
- Follow the repo's rules, in particular: <check policy; servers not to start; design rules or
  skills to apply; anything else the preparation noted>.
- Never run <the stalling commands>: each one halts the whole run until a human answers. <The
  allowed alternatives.> Never run <what the machine lets through and the run forbids>.
- Never ask a question: the decisions are in the ticket and the spec. If a decision is missing, or
  the same error survives two fixes, set the ticket to `blocked`, write under `## Blocked` what
  blocks, what you tried and what is needed, and stop.
- Finish by appending a `## Report` to the ticket: what was done, what differs from the ticket and
  why, the problems found, what was checked, and what later tickets must know. Leave the ticket
  `claimed`: I resolve it after checking.
- Put your working files in <the ticket's notes folder, inside your lane>, and your scratch files
  in <scratch folder>.
- Clean up before your last message: delete what you made in your scratch folder and nothing
  outside it, close every page of your headless browser (one browser name for you alone), end
  every background command. Your last message says what you cleaned.
- Your last message is short, because the detail is in your `## Report`: the files you changed,
  each acceptance criterion with what you saw, one line each (a criterion that only the browser
  can show: "left to the browser"), and what differs from the ticket. No logs.
```

## The corrections brief

For the findings of a review checkpoint, a failed build or a failed pass in a browser: work that belongs to no single ticket. The file of corrections must be committed on the base branch and the lane refreshed before the builder starts, or the lane does not hold it.

```
Correct what <absolute path of the corrections file> lists, in <lane folder>. It is a copy of the
repo on its own branch; other builders work in other copies at this moment. You know nothing of
the conversation that sent you: everything you need is in the files named here.

- Read first: <the repo's rule files>, the corrections file, the findings it points to at
  <review.md, or the player's notes>, and for each finding the ticket and the spec it concerns.
- Correct each line and nothing beside it. A finding you believe wrong is not corrected: say why
  in your report.
- <The same lines as the builder's brief for: staying in the lane and never committing; what the
  copies share; the repo's rules; the commands never to run; never asking a question; the
  scratch folder and the clean-up.>
- Finish by writing <report file, beside the corrections file>: each line of the corrections file
  with what you changed and how you checked it. Edit no ticket file.
- Your last message: the files you changed, each correction with what you saw, and what you did
  not correct and why. No logs.
```

## The player's brief

```
Open, in a browser, what was added to the app since <commit or "the start">, in <lane folder>, a
copy of the repo that holds it all. You built none of it. You know nothing of the conversation
that sent you.

- Read first: <the repo's rule files on running and playing the app>, then the `## Report` of
  each of these tickets, for the screens and routes it added or changed: <tickets>.
- Start the app on port <port> <and what it needs to run there>. Reach each state the way the
  repo says (its dev tools, its test accounts); everything you type is invented.
- Open every screen and call every route those tickets added or changed, once each. For each one:
  does it render, does the console show an error from our code, does a request fail. This is not
  the acceptance play: do not work through the tickets' criteria.
- Change no file of the repo. <The commands never to run, and the scratch folder.>
- Write <notes folder>/pass.md: one line per screen or route, PASS or FAIL with what you saw, and
  a screenshot per screen beside it.
- Stop the app by its port and close your browser's pages before your last message, which lists
  the FAILs only, each with its screenshot's path.
```

# Issue tracker: local files

Specs and tickets for this repo live as markdown files under `.scratch/`.

## Layout

```
.scratch/<feature-slug>/
├── spec.md                  the spec
├── challenge.md             findings from the review of the spec
├── issues/
│   ├── 01-<slug>.md         one file per ticket, numbered from 01, blockers first
│   └── 02-<slug>.md
└── runs/
    └── 01-<slug>/           working notes for one ticket: plan.md, review.md, verify.md
```

One feature per folder. Two features never share a file.

## Ticket header

Every ticket file starts with:

```
# <NN>: <title>

Spec: ../spec.md
Status: open
Blocked by: none
```

- `Status:` is `open`, `claimed`, `blocked` or `resolved`.
- `Blocked by:` lists ticket numbers (`01, 03`) or `none`.

## Operations

- **Publish a spec**: write `.scratch/<feature-slug>/spec.md`, creating the folder if needed. If the folder already holds a spec, update it; never create a second one.
- **Publish a ticket**: write one file under `issues/`. Never a single combined tickets file.
- **Fetch a ticket**: read the file. The user passes a path, a ticket number, or just the feature slug.
- **Next ticket**: scan `issues/` in number order; take the first file with `Status: open` whose blockers are all `Status: resolved`.
- **Claim**: set `Status: claimed` and save before any other work, so another session skips it.
- **Resolve**: append a `## Report` section (what was done, what differs from the ticket and why, the problems found, what was checked), then set `Status: resolved`. The next ticket's builder reads it.
- **Block**: when the same error survives two fixes, or a decision belongs to the user, set `Status: blocked` and write under `## Blocked` what blocks, what was tried and what is needed.
- **Change a later ticket**: when the work changes what a later ticket assumes, edit that ticket under a `## Changed by <NN>` heading that says what changed and why.
- **Comment**: append under a `## Comments` heading at the bottom of the file.

# Issue tracker: GitHub

Specs and tickets for this repo live as GitHub issues. Use the `gh` CLI for every operation. `gh` infers the repo from `git remote -v` when run inside a clone.

Before the first `gh issue create` of a session, check the target with `gh repo view --json nameWithOwner`. In a fork, `gh` can default to the upstream parent: confirm with the user if the target is not their repo.

## Operations

- **Publish a spec**: `gh issue create --title "..." --body "..."`, with a heredoc for the body. The spec is the parent issue of its tickets.
- **Publish a ticket**: `gh issue create --parent <spec> --title "..." --body "..."`. With `gh` older than 2.94, create the issue then put `Part of #<spec>` at the top of its body.
- **Blocking**: GitHub's native dependencies. `gh issue create --blocked-by <n>,<n> ...` or `gh issue edit <ticket> --add-blocked-by <blocker>`. Where dependencies are not available, a `Blocked by: #<n>, #<n>` line at the top of the body.
- **Fetch a ticket**: `gh issue view <number> --json number,title,body,labels,comments`.
- **Next ticket**: list the spec's open sub-issues, drop any with an assignee or an open blocker (`gh api repos/<owner>/<repo>/issues/<n> --jq .issue_dependencies_summary.blocked_by`, 0 means startable); the lowest number wins.
- **Claim**: `gh issue edit <n> --add-assignee @me`, before any other work.
- **Resolve**: `gh issue comment <n> --body "<what was done, commit or branch>"`, then `gh issue close <n>`. Comment first: `gh issue close --comment` drops the comment on an already-closed issue.
- **Comment**: `gh issue comment <n> --body "..."`.

## Working notes

Plans and code reviews for a ticket are not posted to the issue. They go to `.scratch/<spec-number>/runs/<ticket-number>/` in the repo.

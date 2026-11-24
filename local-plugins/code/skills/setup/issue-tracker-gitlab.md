# Issue tracker: GitLab

Specs and tickets for this repo live as GitLab issues. Use the `glab` CLI for every operation. `glab` infers the repo from `git remote -v` when run inside a clone. GitLab calls comments "notes" and pull requests "merge requests".

## Operations

- **Publish a spec**: `glab issue create --title "..." --description "..."`, with a heredoc for the description. The spec is the parent of its tickets.
- **Publish a ticket**: `glab issue create --title "..." --description "..." --linked-issues <spec> --link-type relates_to`, with `Part of #<spec>` at the top of the description.
- **Blocking**: the `/blocked_by #<n>` quick action posted as a note: `glab issue note <ticket> --message "/blocked_by #<blocker>"`. Native blocking links need Premium or Ultimate; elsewhere, a `Blocked by: #<n>, #<n>` line at the top of the description.
- **Fetch a ticket**: `glab issue view <number> --comments`. Add `-F json` for machine-readable output.
- **Next ticket**: list the issues linked to the spec (`glab api projects/:id/issues/<spec>/links`), keep the open ones with no assignee and no open blocker; the lowest number wins.
- **Claim**: `glab issue update <n> --assignee @me`, before any other work.
- **Resolve**: `glab issue note <n> --message "<what was done, commit or branch>"`, then `glab issue close <n>`. `glab issue close` takes no closing comment, so the note comes first.
- **Comment**: `glab issue note <n> --message "..."`.

## Working notes

Plans and code reviews for a ticket are not posted to the issue. They go to `.scratch/<spec-number>/runs/<ticket-number>/` in the repo.

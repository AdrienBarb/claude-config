---
name: spec
description: Turn the current conversation into a spec and publish it where the repo keeps its specs. No interview, only synthesis of what was already decided.
disable-model-invocation: true
---

# Spec

Take what this conversation and the codebase already established and write the spec. Do not interview the user: decisions are made upstream, typically with `/grill-me`.

If a decision the spec needs was never made, do not invent it. List what is missing and stop: the user settles it, or runs `/grill-me`, then calls this skill again.

## Where the spec goes

The tracker record is the file that the `### Issue tracker` section of `CLAUDE.md`, `CLAUDE.local.md` or `AGENTS.md` points to, which may sit outside the repo; without such a section, it is `docs/agents/issue-tracker.md`. If it exists, follow its "Publish a spec" operation.

If it does not exist, use local files, no setup needed: the spec is `.scratch/<feature-slug>/spec.md`, where `<feature-slug>` is a short kebab-case name for the feature. If that folder already holds a spec, update it; never write a second one.

## Process

### 1. Explore

If you have not already, read the code the feature touches, so the spec describes the system as it is. Every statement about what exists today must come from code you read, not from the conversation.

### 2. Agree the test seams

A seam is the public boundary a test observes behaviour through. List the seams this feature will be tested at. Prefer existing seams to new ones, and the highest seam possible: the fewer, the better; one is ideal. Give each a line on what it catches and what it misses, then check with the user that they match what they expect before writing.

### 3. Write the spec

Use the template below. Two rules apply to the whole document:

- **Self-contained.** A competent engineer who has never seen this project must be able to say back what the feature is and why. Define every project-specific term the first time it appears, or link to where it is defined. No "as discussed".
- **No file paths, no code.** They go stale. The exception is a snippet that states a decision more exactly than prose can (a schema, a state machine, a type shape): inline only the part that carries the decision.

<spec-template>

# <Feature name>

## Problem

The problem, from the point of view of the person who has it.

## Solution

What they will be able to do once it ships, from their point of view.

## Goals and non-goals

What this feature delivers, then what it deliberately does not. A non-goal is something a reader could reasonably expect and will not get.

## User stories

A numbered list, long enough to cover every part of the feature:

1. As a <actor>, I want <capability>, so that <benefit>.

## Implementation decisions

The decisions already made: modules built or changed, their interfaces, schema changes, API contracts, architectural choices, clarifications from the developer. One decision per bullet, stated so that nobody has to decide it again.

## Alternatives considered

Mandatory. Each option that was looked at and rejected, with the concrete reason: complexity, cost, performance, scope. A spec with a single path and no rejected alternative is not finished.

## Risks and limits

How this can fail and what it does not handle: failure modes, security implications, scale limits. For each, the mitigation, or the plain statement that the risk is accepted.

## Testing decisions

The agreed seams, what makes a good test here (external behaviour, not implementation details), and prior art for similar tests in the codebase.

## Further notes

Anything else a reader needs. Omit when empty.

</spec-template>

### 4. Publish

Publish the spec where step "Where the spec goes" says. Tell the user the path or the link.

### 5. Offer the challenge

Ask one question: have the spec attacked by reviewers with no context before any code is written? Recommend yes for anything larger than a single session of work. On yes, call the Skill tool with `code:challenge` and the spec's path or reference.

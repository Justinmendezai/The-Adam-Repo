---
name: grill-with-docs
description: Grilling session that lands in CONTEXT.md and ADRs. Sharpens shared language with the agent and documents hard-to-explain decisions. Use when starting a non-trivial change, when the codebase has rich domain language, or when the user wants the grilling output durable.
---

# grill-with-docs

Adapted from [Matt Pocock's grill-with-docs](https://github.com/mattpocock/skills). A [`grill-me`](../grill-me/SKILL.md) session that builds two artifacts as it runs:

- `CONTEXT.md` — the project's shared language.
- `docs/adr/NNNN-*.md` — one ADR per non-obvious decision.

**When to use:** **Required** at [`packet-intake`](../packet-intake/SKILL.md) start of every build (default). Also during packet authoring before the run. **Never** mid-build — mid-run judgment goes to `human-queue.md` at the end.

This is the most leveraged skill in the set. A good `CONTEXT.md` from upfront grilling cuts subagent token usage by 30–50% and is what makes the autonomous build loop possible.

## Workflow

### 1. Establish the lay of the land

Before grilling, read or dispatch an `explore` subagent to read:
- `README.md`, `package.json`, top-level folder names.
- Any existing `CONTEXT.md` or `docs/`.

This gives you the existing vocabulary. Don't invent new terms when one already exists.

### 2. Grill, but log

Run a `grill-me` session. After each resolved question:

- If the answer introduces a new noun or verb you'll use repeatedly → add it to `CONTEXT.md`.
- If the answer is a non-obvious tradeoff → start an ADR.

### 3. CONTEXT.md format

```markdown
# CONTEXT — <project name>

## Glossary

- **Slice** — one independently-shippable unit of work in a adam build, defined by `slices/<id>/SPEC.md`.
- **Materialization cascade** — the chain of effects when a draft lesson becomes real.
- **Builder** — a Composer 2 subagent dispatched against one slice.

## Architecture in one paragraph

We use ... with ... boundaries. Data flows from ... to ... via ...

## Conventions

- All times stored as UTC ISO 8601 strings.
- DB IDs are uuid v4.
- We never throw inside React renders; errors bubble through ErrorBoundary.

## Out-of-scope concepts

Things the project explicitly does not implement. Mention them so future agents don't try to wire them up. Example: "We do not have user organizations. There is one user per resource."
```

Keep it tight. **Under 150 lines**. If a term appears once, it doesn't belong here. If a term appears in three places with three definitions, that's the real bug — fix it.

### 4. ADR format

```markdown
# ADR NNNN: <one-line title>

- Status: proposed | accepted | superseded
- Date: YYYY-MM-DD

## Context
Why was this decision forced? What did we learn during grilling?

## Options
- A — short pros/cons
- B — short pros/cons

## Decision
<choice>. Because <one-sentence reason>.

## Consequences
What gets easier. What gets harder.
```

Number sequentially. ADRs are append-only — to "change" a decision, write a new ADR with `Status: supersedes NNNN` and update the old one's status.

## When to start an ADR

Trigger words during grilling:
- "We could either X or Y."
- "I considered Z but decided against it because..."
- "This pattern is non-standard, but in this project we do it because..."

Each of those is an ADR. Catch them in the moment.

## Anti-patterns

- Long CONTEXT.md. If it's >200 lines, it's documentation, not a glossary. Trim.
- Inventing terms that conflict with the codebase's existing names.
- Writing ADRs for trivial decisions (file naming style, etc.) — only for ones a future agent might reasonably reverse.

## Output

`CONTEXT.md` updated, one or more `docs/adr/*.md` files updated. Required output of intake grilling before the autonomous build phase begins.

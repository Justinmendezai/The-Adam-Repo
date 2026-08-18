---
name: to-prd
description: Synthesize the current conversation into a PRD without re-interviewing the user. Use after a grilling session, after a long planning conversation, or when the user says "write up what we just discussed" or "turn this into a PRD".
---

# to-prd

Adapted from [Matt Pocock's to-prd](https://github.com/mattpocock/skills). No interview. The conversation already happened — your job is to crystallize it into a doc.

## When to use

- Right after a [`grill-me`](../grill-me/SKILL.md) or [`grill-with-docs`](../grill-with-docs/SKILL.md) session.
- After any planning conversation that resolved decisions.
- When the user wants something durable to share or reference.

Not when the conversation hasn't actually settled anything — grill first.

## PRD format

```markdown
# PRD: <short, declarative title>

- Author: <agent + user>
- Date: <YYYY-MM-DD>
- Status: draft | approved | shipped
- Linked ADRs: <list, if any>

## Problem
One paragraph. Whose pain is this? What evidence do we have it's real?

## Goal
One paragraph. What success looks like. Tie to a metric or behavior.

## Non-goals
Bulleted. The things this PRD explicitly is NOT solving.

## Proposed solution
One to three paragraphs. The shape of the change. Not the implementation — the user-facing shape and the system-level architecture in broad strokes.

## Success criteria
Bulleted, each measurable:
- SC-1: <description> — <how we'll measure>
- SC-2: ...

## Risks and mitigations
- Risk 1 — Mitigation
- Risk 2 — Mitigation

## Open questions
Anything still unresolved. Flag clearly. The reader should know what's settled vs. deferred.

## Modules touched
List of files or modules this PRD will affect. (This is the module-design check from Matt's original — caring about modules at PRD time.)
```

## Workflow

1. Skim the conversation. Identify decisions, not narrative.
2. Map decisions to PRD sections.
3. Quote the user's words for goals and non-goals where you have them — don't paraphrase to soften.
4. List modules the change will touch. If you can't, dispatch an `explore` subagent to find them.
5. Show the draft. Let the user redline.

## Anti-patterns

- Inventing content the conversation didn't resolve. If a section is empty, leave it empty and flag it under Open questions.
- Re-interviewing. The whole point is to skip that.
- Module list as "everything." Be specific. If the change touches 30 files, the slice is too big — go back to grilling.

## Output

A PRD doc, by default in `docs/prd/<slug>.md` of the project repo (or wherever the project's convention puts them). Status `draft`, ready for the user to redline.

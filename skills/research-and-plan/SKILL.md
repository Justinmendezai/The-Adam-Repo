---
name: research-and-plan
description: Fan out parallel explore subagents to research the codebase and domain, then fold their findings into plan.md, CONTEXT.md, and ADRs. Use after packet-intake completes, or when asked to "research and plan" for a adam project.
---

# research-and-plan

Token-cheap planning. The high-level agent (you) reads almost nothing directly. You dispatch `explore` subagents in parallel, each with a narrow research question, then fold their summaries into a plan.

## When to use

- Right after `packet-intake` produces `scratch/intake-notes.md`.
- Or when the user says "plan it" with a packet present.
- Not for tiny one-file changes — drop straight to `slice-to-tasks` for those.

## Inputs

- `packet/PACKET.md`
- `scratch/intake-notes.md`
- The repo at `tech_context.repo_path`

## Workflow

### 1. Decompose into research questions

Read the packet and intake notes. Generate a list of narrow research questions, each scoped tightly enough that an `explore` subagent can answer it in one pass. Examples:

- "What is the existing auth flow? List the entry points, the session/token shape, and the middleware that enforces it."
- "Find every place we mutate the `users` table. List file:line."
- "What testing framework does this repo use? Where do tests live? What's the run command?"
- "Survey existing UI primitives — buttons, form fields, modals. Where are they defined?"

Aim for **5–12 questions**. More than that means the questions aren't narrow enough.

### 2. Fan out explore subagents in parallel

Use the `Task` tool with `subagent_type: explore` and `readonly: true`. One subagent per question. Send them all in a single batch.

Each subagent's prompt should include:
- The narrow question.
- The repo path.
- A required output shape: short summary + bulleted findings + `file:line` citations.
- Instruction to NOT speculate beyond what they read.

### 3. Fold results

Once subagents return, merge their summaries into:

- **`plan/CONTEXT.md`** — the shared language doc. Define every term you'll use. (See [`grill-with-docs`](../grill-with-docs/SKILL.md) for the format.)
- **`plan/plan.md`** — the implementation plan. Sections:
  - Approach (one paragraph)
  - Architecture (a Mermaid diagram or short list of modules and their boundaries)
  - Risks
  - Slice candidates (rough — `slice-to-tasks` will refine)
  - Open questions remaining
- **`plan/adr/NNNN-<short-name>.md`** — one ADR per non-obvious decision (DB choice, framework choice, isolation boundaries, async vs sync, etc.).

### 4. ADR template

```markdown
# ADR NNNN: <short title>

- Status: proposed | accepted | superseded
- Date: YYYY-MM-DD

## Context
What forced the decision? What did the research turn up?

## Options considered
- Option A — pros, cons
- Option B — pros, cons

## Decision
The choice and the one-sentence reason.

## Consequences
What now becomes easier. What now becomes harder.
```

### 5. Proceed to slicing (default: auto)

- **Default:** ADRs ship as `Status: accepted`. Proceed directly to [`slice-to-tasks`](../slice-to-tasks/SKILL.md) without operator go/no-go.
- **Opt-in gate:** when `packet.orchestration.require_plan_approval: true` or `.cursor/adam.json` has `"require_plan_approval": true`, show `plan.md` headings + ADR titles and wait for go/no-go before slicing.

Write a one-line plan summary to `scratch/last-run.md`. The operator reviews architecture at **final handoff** ([`e2e-acceptance`](../e2e-acceptance/SKILL.md) + `scratch/taste-review.md`), not mid-run.

## Token discipline

- The high-level agent should not read source files. If a question demands it, that's a sign the question wasn't narrow enough — split it and dispatch.
- Subagent prompts should ask for **summaries with citations**, not raw quotes.
- Cap each subagent at one focused question. Re-dispatch on follow-ups rather than expanding scope mid-flight.

## Output

`plan/plan.md`, `plan/CONTEXT.md`, and one or more `plan/adr/*.md` files exist (ADRs `accepted` unless plan approval was required). Proceed to `slice-to-tasks` autonomously.

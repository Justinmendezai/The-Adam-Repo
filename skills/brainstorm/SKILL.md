---
name: brainstorm
description: Strategy-first mode — zoom out, no code, deterministic-over-inference, decisions before implementation. Use for brainstorm, zoom out, don't jump to code, or strategy not implementation.
origin: adam
disable-model-invocation: true
---

# brainstorm

**Strategy mode** (distinct from code-context [`zoom-out`](../zoom-out/SKILL.md)).

## Contract

- Read `plan/CONTEXT.md`, `packet/PACKET.md`, or named idea doc only.
- **No code edits** unless user pivots mid-thread.
- **Deterministic over inference** — schemas, gates, checklists before LLM judgment.
- Don't relitigate settled `adam/memory/decisions/` or `plan/adr/`.
- Max 2 questions when a real fork exists.

## Workflow

1. Restate the question in one sentence.
2. Ground in existing plan / council `final-output`.
3. Options table: approach / pros / cons / recommendation.
4. Explicit **out of scope** line.
5. Next step: `/council`, `/intake`, `/slice-to-tasks`, or `/handoff-prompt`.

## Escalate

| Signal | Command |
|--------|---------|
| Structured disagreement needed | `/grill-then-council` |
| Raw idea not in packet | `/intake` |
| Ready to build | `/orchestrate` + `/tests-first` path |

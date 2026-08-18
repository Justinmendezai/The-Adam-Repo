---
name: grill-then-council
description: Grill the operator on open decisions first, then run council on resolved INPUT. Use for grill me first then council or make council pass worth it.
origin: adam
disable-model-invocation: true
---

# grill-then-council

Two-phase gate: **close forks with the operator before spending seven perspectives.**

## Phase 1 — Grill

Run [`grill-me`](../grill-me/SKILL.md) or [`grill-with-docs`](../grill-with-docs/SKILL.md):

1. Read draft INPUT + linked plan docs.
2. Interview until branches are closed.
3. Write `council/runs/<id>/grill-resolutions.md` (or `decisions.md`).

Stop Phase 2 until operator says done.

## Phase 2 — Council

Run [`council`](../council/SKILL.md):

1. Rewrite `INPUT.md` with **settled** constraints from grill.
2. Seven perspectives → synthesis → `final-output.md`.

## Output

- Grill resolutions file
- Council terminal artifact
- One line: ready for `/slice-to-tasks` or `/orchestrate`?

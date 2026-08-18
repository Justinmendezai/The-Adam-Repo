---
name: steward
description: Sync project docs after a build wave — agent-control, orchestration-runs, next brief. Alias for session-steward in operator vocabulary. Use for steward, sync docs, or refresh next brief.
origin: adam
disable-model-invocation: true
---

# steward

Post-wave **doc sync** — no product code, no worker dispatch.

**Implementation:** run [`session-steward`](../session-steward/SKILL.md). This skill exists as the operator-facing command name (`/steward`).

## When

- Build orchestrator finished a bounded cycle
- Operator asks to refresh `next-orchestrator-brief.md`
- After `/repo-truth` when docs lag git

## Optional prelude

Run [`repo-truth`](../repo-truth/SKILL.md) first if merge state unknown.

## Output

Per session-steward: `orchestration-runs/run-NNN/` + updated `agent-control/next-orchestrator-brief.md`.

## Pair with

- [`handoff-prompt`](../handoff-prompt/SKILL.md) for next session kickoff

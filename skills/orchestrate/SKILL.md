---
name: orchestrate
description: Output a paste-ready build-orchestrator prompt from agent-control brief and orchestrate-build driver. Use for orchestrate, kick off build orchestrator, or tier-1 prompt for next wave.
origin: adam
disable-model-invocation: true
---

# orchestrate

Produce the **full paste-ready orchestrator prompt** — not a summary.

## Sources (read in order)

1. `agent-control/next-orchestrator-brief.md` (canonical)
2. `agent-control/active-sprint.md`, `agent-control/slice-status.md`
3. [`orchestrate-build`](../orchestrate-build/SKILL.md) — driver contract
4. `packet/PACKET.md` constraints

If brief missing → run [`session-steward`](../session-steward/SKILL.md) first or ask operator for objective.

## Output

1. Full prompt in a **copy-paste code block**.
2. Save to `scratch/handoff/KICKOFF-<slug>.md`.
3. Remind: orchestrator passes **paths, not file contents**, to workers.

## Prompt must include

- Read-first file list
- This run does only (3–10 bullets)
- Done means (verifiers / commands)
- Do not (scope traps)
- Operator queue from `agent-control/human-queue.md`

## Pair with

- [`handoff-prompt`](../handoff-prompt/SKILL.md) when closing planning session.

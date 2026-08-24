---
name: intake
description: Process a raw idea or brainstorm doc into plan updates — critical review, gap analysis, packet or plan edits. Use for idea intake, process ideas, or critical review before building. Follow from natural language; do not ask for /intake.
origin: adam
---

# intake

Route by context:

| Context | Workflow |
|---------|----------|
| Product repo with `packet/PACKET.md` | [`packet-intake`](../packet-intake/SKILL.md) |
| Raw idea in `ideas/` (harness) or user paste | **This skill** |

## Procedure

1. **Read** the idea fully (`ideas/<file>.md` or pasted doc).
2. **Identify** target artifact: `packet/PACKET.md`, `plan/plan.md`, or new ADR in `plan/adr/`.
3. **Cross-reference** `plan/CONTEXT.md`, `adam/memory/`, existing slices — no full-repo reads.
4. **Critical review**: gap vs code, in-scope vs defer, settled decisions in `adam/memory/decisions/`.
5. Propose surgical edits; apply only after approval.
6. Log intake summary in `scratch/intake-notes.md`.
7. Escalate to [`grill-then-council`](../grill-then-council/SKILL.md) if tradeoffs remain soft.

## Output

- One paragraph: what the idea is, recommended home (packet / plan / defer).
- Proposed file edits (paths only) before applying.
- Max 2 open questions unless council warranted.

## Efficiency

- Read `adam/context/*` in calibrated projects.
- Grep before deep reads; cite `path:line` for code claims.

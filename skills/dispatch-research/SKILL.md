---
name: dispatch-research
description: Fan out a research pod to land findings in scratch/research. Use for dispatch research, research brief, or bring back info on a topic.
origin: adam
disable-model-invocation: true
---

# dispatch-research

Research pod → **`scratch/research/<topic>.md`** — not product code.

Prefer [`research-and-plan`](../research-and-plan/SKILL.md) when the goal is a full plan; use this skill for **narrow factual briefs**.

## Brief structure

```markdown
# Research brief — <topic>
- Date:
- Question:
- Sources (URLs only):

## Findings
## Implications for this project
## Recommended next (/intake, /council, defer)
```

Also append index line in `scratch/intake-notes.md` if material.

## Rules

- Public sources; no verbatim copy of proprietary prose.
- Grep `scratch/research/` first — don't duplicate.
- Paid APIs: note cost; no live calls without approval.

## After

- [`intake`](../intake/SKILL.md) if packet/plan should change
- [`council`](../council/SKILL.md) if tradeoffs remain

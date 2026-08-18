---
name: go
description: Proceed with the last proposed plan without re-explaining — minimal ack, execute. Use when user says go, yes, yep go ahead, proceed, approved, lgtm, or sounds good.
origin: adam
disable-model-invocation: true
---

# go

**Approval shorthand.** User decided; do not re-pitch unless blocked.

## Behavior

1. One-line ack: "Proceeding."
2. Execute the **last explicit plan** (or attached plan file).
3. No recap essay.
4. If ambiguous → **one** clarifying question only.

## Defaults

- Last assistant "Want me to…?" awaiting yes
- Last `/handoff-prompt`, `/intake`, `/council` output pending approval
- Attached plan file → treat as approved

## Do not

- Re-read full context files unless required for the task.
- Re-ask permission for same-thread approved edits.

---
name: go
description: Proceed with the last proposed plan without re-explaining — minimal ack, execute. Use when user says go, yes, yep, keep going, do it, go ahead, proceed, approved, lgtm, or sounds good. On Codex/ChatGPT this is ordinary yes — never ask them to type /go.
origin: adam
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

On Codex / ChatGPT, “yes” / “keep going” **is** this skill. Do not tell them to type `/go`.

## Do not

- Re-read full context files unless required for the task.
- Re-ask permission for same-thread approved edits.

---
name: handoff-prompt
description: Write a handoff doc plus a paste-ready orchestrator kickoff prompt, optionally switch workspace and continue in the same chat. Use when the user says handoff-prompt, wants handoff and prompt, kick off next agent, or one handoff file and a prompt to pass.
origin: adam
disable-model-invocation: true
---

# handoff-prompt

Handoff **plus** kickoff prompt — use when a wave closes and the next session needs a paste-ready driver.

## Output (always both)

1. **Handoff doc** — [`handoff`](../handoff/SKILL.md) template; save to:
   - `adam/memory/handoffs/<topic>-<YYYY-MM-DD>.md` (harness-level)
   - `scratch/handoff/handoff-<YYYYMMDD-HHmm>.md` (product repo)
2. **Kickoff prompt file** — `scratch/handoff/KICKOFF-<topic>.md` with the **full paste-ready orchestrator prompt** (not a summary).
3. **Chat block** — print kickoff prompt in a fenced code block for copy/paste.

## Kickoff prompt sources

- `agent-control/next-orchestrator-brief.md` (canonical in product repos)
- [`orchestrate-build`](../orchestrate-build/SKILL.md) driver preamble
- `plan/ORCHESTRATOR.md` if the repo defines one
- Branch rules from `foundation/repo/folder-contract.md` (`adam/<slice-id>`)

Include: mission, read-first paths, slice scope, stop conditions, operator gates.

## Cross-workspace continuation

**No API spawns a fresh agent chat in another repo with a preloaded prompt.** Options:

| Mode | What happens |
|------|----------------|
| **A — Copy/paste** (default) | New chat in target repo; `@` handoff + KICKOFF; paste prompt |
| **B — Same chat switch** | User approves → `cursor-app-control` **`move_agent_to_root`** → continue kickoff here |
| **C — Multi-root** | `move_agent_to_root` with `rootPaths: [harness, product-repo]` |

Do **not** call `move_agent_to_root` without explicit user approval.

## Quality bar

- Handoff under 150 lines; kickoff may be long.
- **Next concrete step** at top of both files.

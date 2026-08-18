---
name: session-steward
description: Lightweight context steward — compress the latest orchestrator run into `orchestration-runs/` and refresh `agent-control/next-orchestrator-brief.md`. Does not write product code or dispatch subagents. Run between bounded build orchestrator sessions.
---

# session-steward

**Meta orchestrator = memory manager, not implementer.** Long-term continuity lives in **`agent-control/`**, **`orchestration-runs/`**, git, and tests — not in one endless chat.

Use this skill **after** a build orchestrator finishes a bounded cycle (or when the human asks for the next brief).

## Explicit non-goals

- No edits to production `src/`, `app/`, etc.
- No `dispatch-builder` / `dispatch-parallel`.
- No slice spec or test file changes.
- Minimal reasoning: compress, file, link — do not replan the whole product.

## When to use

- A build orchestrator completed **one** objective in `agent-control/active-sprint.md` (or stopped with a clear blocker).
- Token pressure: you want a **fresh** build orchestrator with a tight brief.
- After `e2e-acceptance` or a major test pass — roll results into `agent-control/test-status.md`.

## Inputs (read-only)

- `agent-control/active-sprint.md`, `agent-control/current-state.md`, `agent-control/completed-work.md`
- `agent-control/slice-status.md` — final registry state
- `agent-control/human-queue.md` — open operator items
- `agent-control/rework-ledger.md` — agentic review/rework rows this run (create empty template if missing)
- Latest `orchestration-runs/run-*` folder (if any)
- `scratch/last-run.md`, `scratch/handoff/primer-*.md` (most recent optional)
- `slices/README.md`, `plan/CONTEXT.md` (one screen each)
- `scratch/e2e-acceptance.md` or `scratch/run-results/e2e-*.json` if present
- `packet/PACKET.md` `verification` / `e2e` for test layer names

## Context budget (soft)

| Output | Target |
|--------|--------|
| `next-orchestrator-brief.md` | ~20k–30k **characters**; bullets first |
| `orchestration-runs/run-NNN/summary.md` | ~2k–4k characters |
| Bullet lists | **10 bullets max** for “what happened” and “what’s next” |

Do not rely on live token meters — use character caps and short bullets.

## Workflow

### 1. Allocate run id

- Pick the next folder: `orchestration-runs/run-003/` (zero-pad or use date — match existing convention in the repo).
- If the build orchestrator **already** created this folder and filled files, **update in place** instead of duplicating.

### 2. Write `orchestration-runs/run-NNN/`

Minimum:

- **`summary.md`** — objective, outcome (shipped / blocked / partial), 10 bullets max on what changed, links to PRs/commits if known. Include a **Rework roll-up** line: top 1–3 `class` values from `agent-control/rework-ledger.md` this run (or `none`).
- **`commits.md`** — high-level commit list or `git log --oneline -20` paste; or “see summary”.
- **`test-results.md`** — commands run, pass/fail, paths to HTML reports if any.
- **`open-issues.md`** — new or unresolved items for the human / next run. If rework classes recur (≥2 rows same `class`), propose one concrete `system_fix` (skill line / HANDOFF clause / SPEC gate) — do not invent a product feature.

Link to `scratch/run-results/*.json` instead of pasting JSON.

### 3. Refresh `agent-control/`

- **`current-state.md`** — phase, branch/SHA if known, **last run** = `run-NNN`, blockers (≤5 bullets), slice-status roll-up, **open human-queue count**.
- **`completed-work.md`** — append a short entry linking `orchestration-runs/run-NNN/summary.md`.
- **`slice-status.md`** — **do not rewrite** rows; the orchestrator owns those. Only confirm the file's final state matches what `summary.md` claims. If rows are stale (e.g., the loop stopped mid-wave), note the gap in `current-state.md` rather than editing the registry.
- **`test-status.md`** — update rows for each verification layer you have evidence for (`e2e`, `api_e2e`, etc.).
- **`security-status.md`** — if a security audit or acceptance ran, link `scratch/security-audit/` and open critical/high counts.
- **`next-orchestrator-brief.md`** — **canonical** entry for the *next* fresh build orchestrator:
  - Read-first list (this file + `packet/PACKET.md` + `active-sprint.md` + `agent-control/slice-status.md` + `slices/README.md` + `plan/CONTEXT.md`).
  - **This run does only** — 3–10 bullets aligned with the **next** `agent-control/active-sprint.md` (human should edit `active-sprint.md` first if the next objective changed).
  - Done means — concrete checkboxes or commands.
  - **Do not** — scope traps for the next session.
  - **Operator queue** — copy open rows from `agent-control/human-queue.md` (final UI/UX/taste/live session).
  - **Rework classes** — if `rework-ledger.md` has ≥2 rows this run, list top classes + whether a system_fix is pending.
  - **Driver:** point at [`orchestrate-build`](../orchestrate-build/SKILL.md) when the next session should drive the registry.

### 4. Single source of truth

- **`agent-control/next-orchestrator-brief.md`** is the **canonical** “start here” for adam.
- Do **not** leave contradictory instructions in `scratch/handoff/` — if a primer exists, optionally add one line at top: `Canonical brief: agent-control/next-orchestrator-brief.md`.

## Anti-patterns

- Rewriting `mission.md` without human direction.
- Pasting entire `plan.md` into the brief — link it.
- Turning session-steward into a second full build (new slices, new code).

## Output

- `orchestration-runs/run-NNN/` populated with `summary.md` (+ optional `commits.md`, `test-results.md`, `open-issues.md`).
- `agent-control/next-orchestrator-brief.md` and `agent-control/current-state.md` updated.
- Human can start a **new** chat: read `agent-control/next-orchestrator-brief.md` and continue.

## Related

- [`context-primer`](../context-primer/SKILL.md) — session escape hatch; should **point at** or **mirror into** `agent-control/` (see that skill).
- [`setup-adam`](../setup-adam/SKILL.md) — seeds `agent-control/` templates.
- Docs: [`foundation/repo/folder-contract.md`](../../foundation/repo/folder-contract.md).

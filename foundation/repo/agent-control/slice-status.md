# Slice status registry

**Canonical, on-disk status table** for the Tier-1 [`orchestrate-build`](../../../skills/orchestrate-build/SKILL.md) loop. One row per slice. The orchestrator walks this file; nothing else.

This is the entire working memory of the orchestrator. It must survive across agent restarts (durable, version-controlled, small markdown only). If two orchestrators ever drive the same file at once they will double-dispatch — **one driver per registry**.

## Allowed status values

| status | meaning |
|---|---|
| `ready` | tests-first has populated red tests; deps satisfied or empty; eligible for the next wave |
| `dispatched` | a manager (Tier 2) or worker (Tier 3) is in flight |
| `done` | the orchestrator independently re-ran the verifier and it exited 0 |
| `blocked` | verifier non-zero, worker emitted BLOCKED, or out-of-scope violation; needs [`babysit-builders`](../../../skills/babysit-builders/SKILL.md) |
| `human-gated` | legacy/terminal only (`integration-live`); mid-run items go to `human-queue.md` instead |
| `escalate` | re-dispatched ≥2x for the same slice; needs a human decision |
| `cancelled` | spec retracted; row preserved for history |

## Rows

| id | depends_on | status | branch | verify_exit | operator_command | notes |
|---|---|---|---|---|---|---|
| <slice-id> | <comma list or `-`> | `ready` | `-` | `-` | `-` | <one phrase> |

## How it gets updated

- **`slice-to-tasks`** seeds one `ready` row per slice (see [skill step 6](../../../skills/slice-to-tasks/SKILL.md)).
- **`orchestrate-build`** is the **only** writer during the loop: flips `ready` → `dispatched` → (`done` | `blocked`). `CODE-COMPLETE` items append to **`human-queue.md`**; slice row → `done` when mock verifier is green.
- **`babysit-builders`** may flip `blocked` → `ready` after fixing scope, or → `escalate` after the third failed retry (queues to `human-queue.md`, does not interrupt operator).
- **`session-steward`** reads the final state at run close and rolls it into `current-state.md` + the next brief; it does **not** rewrite history rows.
- Subagents (managers and workers) **never** write to this file.

## Rules

- Append rows in dependency order so a top-to-bottom read is a topological walk.
- Keep `notes` to one phrase. If you need a paragraph, link to `slices/<id>/SPEC.md` or `scratch/run-results/<id>.manage.json`.
- When a slice's `verify_exit` flips to 0, the row is `done` for this run. Don't reopen a `done` row from inside the loop; if a regression surfaces, open a new slice.

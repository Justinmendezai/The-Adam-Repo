# Rework ledger — agentic team closed loop

Append-only. One row when a review **blocks**, a babysitter **re-dispatches**, or Tier-1 **re-routes** after fail. Not for operator taste/creds (those stay in `human-queue.md`).

Goal: builder → review → rework becomes **system patches** (skills, SPEC/HANDOFF, gates), not only fixed slices.

## Classes (pick one)

| class | meaning |
|---|---|
| `spec_gap` | SPEC/HANDOFF underspecified or ambiguous |
| `truth_drift` | Wrong live state / stale context / ignored schema truth |
| `scope_creep` | Built past done-when / out of scope |
| `gate_skip` | Claimed done without green verifier / skipped tests |
| `contract_mismatch` | Wrong API, schema, or cross-repo assumption |
| `taste` | Operator standard reject (rails may have been fine) |
| `infra` | Env, secrets, managed Postgres, OAuth — not agent competence |
| `review_fp` | Reviewer wrong; note so we don't overfit |

## Ledger

| date | slice_or_pod | stage | class | one_liner | system_fix |
|---|---|---|---|---|---|
| — | — | — | — | *(empty — append during run)* | — |

### stage values

- `graph-review` — [`review-via-graph`](../../../skills/review-via-graph/SKILL.md) `verdict: block`
- `runtime-review` — [`review-runtime`](../../../skills/review-runtime/SKILL.md) AC fail / send-back
- `e2e` — [`e2e-acceptance`](../../../skills/e2e-acceptance/SKILL.md) `verdict: block` / Hold for fixes
- `babysit` — [`babysit-builders`](../../../skills/babysit-builders/SKILL.md) redirect / auto-retry
- `orchestrator` — Tier-1 re-dispatch when no review/babysit row was written yet

## Rules

- Append **before** re-dispatching the fix. One row per rework event (not per finding).
- If the file is missing, create it from this template (or copy from `~/adam/foundation/repo/agent-control/rework-ledger.md`).
- `system_fix` may be `none` mid-run; end-of-run / [`session-steward`](../../../skills/session-steward/SKILL.md) fills top recurring classes → skill/HANDOFF patches.
- **Writers:** review skills, `babysit-builders`, Tier-1 `orchestrate-build`, `session-steward`. **Not** Tier-2 managers or Tier-3 workers.

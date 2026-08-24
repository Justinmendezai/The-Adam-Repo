---
name: orchestrate-build
description: Tier-1 set-and-forget driver. Walk the slice dependency graph, dispatch per-slice managers (Tier 2) for every newly-unblocked slice, independently re-run each slice's verifier, flip status in agent-control/slice-status.md, and fan out the next wave. Use when the build orchestrator has slices ready and wants one lean loop driving every phase from scaffold to handoff without holding any slice's spec body in context.
---

# orchestrate-build

The **Tier-1 orchestrator** loop. Permanently lean: it never reads a slice `SPEC.md` body, never writes product code, never trusts a worker's self-report. It walks the dependency graph in `agent-control/slice-status.md`, hands **paths** (not contents) down to per-slice managers, then **re-runs each slice's verifier itself** before flipping a status row.

## The invariant

**Information flows down as file paths, not file contents.** The orchestrator passes a slice id and a list of paths to its manager. Each lower tier reads what it needs by path. Nobody pastes a 400-line spec into a prompt.

## Topology

```
Tier 1 — orchestrate-build (this skill, you)
  holds: dep graph + 1-line statuses (agent-control/slice-status.md)
  does:  dispatch managers, re-run verifiers, flip statuses
        |
        | slice id + paths only
        v
Tier 2 — dispatch-manager (per slice, disposable)
  holds: ONE slice SPEC.md
  does:  build worker prompt, dispatch worker, return one-line summary
        |
        | scoped prompt
        v
Tier 3 — worker (composer-2-fast, best-of-n-runner)
  holds: ONE SPEC + in-scope files
  does:  write code, commit, emit <adam>COMPLETE</adam>
```

Fallback path: when `topology_depth: 2` is set in `adam.json`, the orchestrator dispatches workers directly via [`dispatch-builder`](../dispatch-builder/SKILL.md) / [`dispatch-parallel`](../dispatch-parallel/SKILL.md) and skips the manager hop.

## Preconditions

Before running this skill:

- [`slice-to-tasks`](../slice-to-tasks/SKILL.md) has produced `slices/<id>/SPEC.md` + `slices/<id>/verify.sh` (or an inline `verify` one-liner in `SPEC.md`) for every slice.
- [`tests-first`](../tests-first/SKILL.md) has populated `slices/<id>/tests/` with red tests.
- `agent-control/slice-status.md` exists (created by [`setup-adam`](../setup-adam/SKILL.md), one row per slice).
- `agent-control/human-queue.md` exists (seeded by adam-foundation-sync) for batched operator items.
- `adam.json` has `topology_depth` (default `3`) and `verifier_convention` (default `slices/<id>/verify.sh`).

## Start: fork-self (default for multi-slice builds)

For any build with **more than one slice**, fork yourself **before** the first dispatch wave — do not wait for the operator to restart the loop:

```
Task(
  subagent_type: "generalPurpose",
  description: "orchestrate-build background driver",
  prompt: "Resume orchestrate-build. Read agent-control/slice-status.md and keep running the dispatch loop until every row is done or escalate. Merge green slices to main per merge-when-green. One driver only.",
  resume: "self",
  run_in_background: true
)
```

Single-slice hotfixes may run in the foreground. The forked self uses the same tools and state files — no handoff loss.

## What this skill holds in context

Only:

- The current row state of `agent-control/slice-status.md` (one line per slice).
- The dependency edges from `slices/README.md` (Mermaid is fine — read once, hold the edges only).
- One-line manager summaries as they return.

**Never** in context:
- Any `SPEC.md` body.
- Any worker diff.
- Any test log beyond pass/fail counts.

## The dispatch loop

Repeat until all rows are `done` or `escalate` (operator queue in `human-queue.md`).

### 1. Read the registry

Read `agent-control/slice-status.md`. Identify the **wave**: every slice whose status is `ready` and whose `depends_on` rows are all `done`.

Cap the wave at `max_parallel_builders` from `adam.json` (default 4).

### 2. Dispatch managers (paths, not contents)

For each slice in the wave, dispatch a Tier-2 manager. **Do not read the SPEC.** Pass only paths:

```
Task(
  subagent_type: "generalPurpose",
  model: <managers can use a small model — composer-2-fast is fine>,
  description: "Manage slice <id>",
  prompt: |
    You are a adam Tier-2 manager for slice <id>.
    Run the dispatch-manager skill (skills/dispatch-manager/SKILL.md).
    Read these paths to do your job; do not read anything else:
    - slices/<id>/SPEC.md
    - slices/<id>/verify.sh
    - plan/CONTEXT.md
    - packet/PACKET.md
    - adam.json
    Paths out of scope for any worker you dispatch:
    - <every OTHER slice directory under slices/>
    - packet/, plan/, agent-control/, orchestration-runs/, slices/<id>/SPEC.md, slices/<id>/tests/
    Return ONE line: "<status>: <slice-id> branch=<branch> verify=<exit>"
  ,
  run_in_background: true
)
```

When `topology_depth: 2`: skip step 2 and call [`dispatch-builder`](../dispatch-builder/SKILL.md) / [`dispatch-parallel`](../dispatch-parallel/SKILL.md) directly.

### 3. While managers run

Use the time to stage the next wave (write more failing tests for downstream slices via [`tests-first`](../tests-first/SKILL.md)), draft ADRs, or run [`context-primer`](../context-primer/SKILL.md) if token budget is past 50–60%.

**Monitoring:** every `Task(..., run_in_background: true)` in step 2 must have a watcher armed in the same turn — see **Long-running task monitoring** in [`foundation/AGENTS.md`](../../foundation/AGENTS.md). For dispatch drivers and poll loops, use `notify_on_output` on a tick/fail pattern; for dev servers the workers depend on, `Await` on a ready line before assuming green.

### 4. As each manager returns

For each completed manager:

1. **Read only its one-line summary** (and `scratch/run-results/<slice-id>.json` for the verifier exit code).
2. **Re-run the verifier yourself** in your own shell:
   ```bash
   bash slices/<slice-id>/verify.sh
   ```
   Exit `0` → green. Non-zero → not green. **Never trust the worker's self-report.** This single discipline catches most "agent said done but isn't" failures.
3. **Flip the status row** in `agent-control/slice-status.md`:
   - Exit 0 → `done`
   - Non-zero → `blocked` with a one-line reason
   - Worker emitted `<adam>BLOCKED</adam>` → `blocked`
   - Worker emitted `<adam>CODE-COMPLETE</adam>` → append to `agent-control/human-queue.md`; flip to `done` if mock-path verifier is green (else `blocked` → babysit). **Do not** flip to `human-gated` mid-run unless `integration-live` terminal slice.
   - Out-of-scope violation → `blocked`; hand to [`babysit-builders`](../babysit-builders/SKILL.md)
4. Queue review ([`review-via-graph`](../review-via-graph/SKILL.md) or [`review-runtime`](../review-runtime/SKILL.md)) for green slices in topological merge order.
5. **Merge to main** when `auto_merge_to_main` is not `false` (default `true`): after review `verdict: approve`, run [`merge-when-green`](../merge-when-green/SKILL.md) (PR or `adam/<slice-id>` branch). Do not ask the operator for merge approval.
6. **Rework ledger on fix routing:** when a review returns `verdict: block` or you re-dispatch after a non-zero verifier / babysit handoff, confirm `agent-control/rework-ledger.md` already has a row for this event (review/babysit usually wrote it). If missing, append one row yourself (`stage=orchestrator`, one `class` from that file's taxonomy, `system_fix=none`). Create the file from `~/adam/foundation/repo/agent-control/rework-ledger.md` if absent. Do not double-count.

### 5. Fan out the next wave

Re-read the registry. Any slice whose deps are now `done` is eligible. Go to step 1.

### 6. Phase progression

This loop runs across **every phase** of the build, not just dispatch. Slices in `agent-control/slice-status.md` can belong to any phase, and the orchestrator drives them all the same way:

| Phase | Typical slice kinds | Verifier examples |
|---|---|---|
| scaffold | dev-launch fixups, env wiring | `bash scripts/dev-up.sh && curl -fsS localhost:3000` |
| plan | research, ADRs | `test -f plan/adr/0001-*.md` |
| slice | spec authoring, test stubs | `test -f slices/<id>/tests/*.test.ts` |
| build | implementation slices | `npm test -- slices/<id>` / `pytest tests/<id>` |
| review | graph + runtime review | `test -f scratch/review-evidence/<id>/finding-count.txt` |
| e2e | acceptance suite | `npx playwright test e2e/<id>-*.spec.ts` |
| security | audit + acceptance | `python -m security_acceptance --slice <id>` |
| handoff | session-steward roll-up | `test -f orchestration-runs/run-<NNN>/summary.md` |

Phase-specific dispatcher skills ([`dispatch-builder`](../dispatch-builder/SKILL.md), [`security-audit`](../security-audit/SKILL.md), [`e2e-acceptance`](../e2e-acceptance/SKILL.md), [`session-steward`](../session-steward/SKILL.md)) are still the right way to **execute** a slice; this skill is what **drives** them by flipping status rows.

## Deferred human work (not mid-run gates)

Live creds, taste, and SME judgment **queue** to [`agent-control/human-queue.md`](../../foundation/repo/agent-control/human-queue.md). The operator clears them in **one final session** ([`e2e-acceptance`](../e2e-acceptance/SKILL.md) + `scratch/taste-review.md`).

During the build:

1. Feature slices use mocks; verifiers pass without live accounts.
2. `CODE-COMPLETE` → append human-queue row; mark slice `done` when mock verifier is green.
3. Terminal `integration-live` slice (only slice with `human_gated: true` by default) validates live wiring at the end.

Independent branches never wait on operator queue items.

## Fork-self for long autonomous runs

See **Start: fork-self** above. Optional foreground use for single-slice work only.

## Failure modes & guardrails

| Risk | Guardrail |
|---|---|
| Worker claims done but isn't | Step 4.2: re-run the verifier yourself. |
| Worker edits out-of-scope files | Step 2 prompt: `paths_out_of_scope` is every other slice dir + control plane. |
| Orchestrator context creep | Step 1 only loads status rows; never reads SPEC bodies or diffs. |
| Two agents dispatch the same slice | One driver per `slice-status.md`. Fork-self is exactly one extra driver only when the foreground exits. |
| Human-gated slice stalls the whole build | Queue to `human-queue.md`; mock path → `done`; keep rolling. |
| Oversized slice overflows a worker | Tier-2 manager owns sub-task fan-out (see [`dispatch-manager`](../dispatch-manager/SKILL.md)). |
| Lost state on restart | `agent-control/slice-status.md` is a file on disk — survives any agent restart. |

## Output

- `agent-control/slice-status.md` advances until every row is `done` or `escalate` (queue items in `human-queue.md`).
- `agent-control/rework-ledger.md` gains a row for each review-block / babysit-retry / orchestrator re-route (agentic closed loop).
- `scratch/run-results/*.json` written by every dispatch and review.
- When done: hand off to [`session-steward`](../session-steward/SKILL.md) to compress the cycle into `orchestration-runs/run-NNN/` and refresh `agent-control/next-orchestrator-brief.md`.

## Related

- [`dispatch-manager`](../dispatch-manager/SKILL.md) — Tier 2, per-slice disposable manager.
- [`dispatch-builder`](../dispatch-builder/SKILL.md) / [`dispatch-parallel`](../dispatch-parallel/SKILL.md) — Tier 3 dispatch, called directly when `topology_depth: 2` or by the manager when `topology_depth: 3`.
- [`babysit-builders`](../babysit-builders/SKILL.md) — triage path for `blocked` rows.
- [`session-steward`](../session-steward/SKILL.md) — runs after the loop drains.
- [`foundation/repo/folder-contract.md`](../../foundation/repo/folder-contract.md) — registers `agent-control/slice-status.md`.

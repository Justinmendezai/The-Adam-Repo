---
name: slice-to-tasks
description: Decompose an approved plan into independently shippable vertical slices, each with file paths, acceptance criteria, dependency edges, and a stub for the failing test suite. Use after research-and-plan is approved, or when asked to "slice the plan" or "break this into tasks".
---

# slice-to-tasks

Turn an approved `plan/plan.md` into a folder of slice briefs. Each slice is one Composer 2 subagent's worth of work. Each slice is independently shippable when its dependencies are met.

## Definition of a slice

A vertical slice:

- Touches as much of the stack as needed to deliver one user-visible behavior or one acceptance criterion.
- Has explicit `paths_in_scope` and `paths_out_of_scope`.
- Has an explicit `acceptance` block — what tests must pass and what runtime behavior must hold.
- Has a runnable **verifier** (`slices/<id>/verify.sh` or an inline `verify` one-liner) that exits `0` when ACs hold. This is the **done-signal** the Tier-1 [`orchestrate-build`](../orchestrate-build/SKILL.md) loop re-runs independently — distinct from the full unit/E2E suite.
- Declares its dependencies on other slices by id.
- Is small enough for a Composer 2 subagent to complete in one go (< ~500 LOC change in most cases). Larger slices declare a `sub_tasks:` block so the Tier-2 [`dispatch-manager`](../dispatch-manager/SKILL.md) can fan out sequentially.

## Workflow

### 1. Read

- `plan/plan.md`
- `plan/CONTEXT.md`
- `packet/PACKET.md` `success_criteria`

### 2. Draft slices

For each success criterion, identify the smallest chunk of work that proves it. Then split anything still too big. Group foundation work (types, schemas, scaffolding) into early slices that others depend on.

Aim for **3–10 slices** per build. More than that is usually a sign you're slicing horizontally (by layer) instead of vertically (by behavior).

### 2b. Mock-first; one terminal live slice

**Default slicing policy** (minimize mid-run operator gates):

- Build slices use **mocks/stubs** for OAuth, DNS, Stripe, GSC, and other live integrations. Verifiers must pass against mocks in CI/local.
- Defer real credentials, taste judgment, and SME sign-off to **one terminal slice** at the end of the DAG:

```
integration-live   # human_gated: true, depends_on: [<all feature slices>]
```

That slice's verifier may require live env; everything else stays mock-green. Items that still need operator action append to [`agent-control/human-queue.md`](../../foundation/repo/agent-control/human-queue.md) — the build loop does not pause.

- Do **not** scatter `human_gated: true` across feature slices unless physically unavoidable. Prefer mock + queue.

### 3. Build the dependency graph

For each slice, list which other slices it depends on. Surface the graph as a Mermaid diagram in `slices/README.md`. The orchestrator's `dispatch-parallel` skill uses this to fan out independent slices.

### 4. Write a slice brief per slice

Folder per slice:

```
slices/<slice-id>/
├── SPEC.md       # the brief; never modified by subagents
├── verify.sh     # runnable done-signal; the Tier-1 orchestrator re-runs this independently
└── tests/        # stubbed by tests-first; populated with failing tests
```

`SPEC.md` template:

```markdown
---
id: <slice-id>             # kebab-case, unique
title: <short title>
depends_on: [<other-slice-id>, ...]
parallel_safe: true | false
estimated_loc: <rough int>
human_gated: false         # set true when finishing requires a human action (2FA, real creds, DNS, etc.)
verify: bash slices/<slice-id>/verify.sh   # one-liner shell command that exits 0 when ACs hold
# Optional — for oversized slices the Tier-2 manager fans out sequentially:
# sub_tasks:
#   - id: 01-types
#     paths_in_scope: [src/types/]
#     output: scratch/handoff/<slice-id>/01-types.md
#   - id: 02-impl
#     depends_on: [01-types]
#     paths_in_scope: [src/services/]
#     input: scratch/handoff/<slice-id>/01-types.md
---

# <title>

## Summary
One paragraph: what user-visible behavior this delivers.

## Acceptance criteria
- AC-1: ...
- AC-2: ...

## Paths in scope
- src/foo.ts
- src/bar/

## Paths out of scope (do not touch)
- src/legacy/
- migrations/

## Failing tests the subagent must turn green
- tests/<slice-id>/foo.test.ts
- tests/<slice-id>/bar.test.ts

## Verifier (done-signal)
The orchestrator re-runs this independently in step 4 of [`orchestrate-build`](../orchestrate-build/SKILL.md). Keep it cheap (seconds) and deterministic. Distinct from the full suite — it answers "did this slice's ACs land?" with one exit code.

- Command: `bash slices/<slice-id>/verify.sh`
- Or inline (frontmatter `verify:` key): a single shell line that exits 0 on green.

Example `verify.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
npm test -- --run slices/<slice-id>/tests >/dev/null
curl -fsS http://localhost:3000/api/<slice-feature> >/dev/null
```

## Playwright E2E (when `packet/PACKET.md` defines `e2e`)
List orchestrator-owned specs under `e2e/` (or `e2e.spec_dir`) that prove this slice's user-visible ACs. Subagents do not edit these files.

- e2e/<slice-id>-*.spec.ts

## Backend / API tests (when `packet/PACKET.md` defines `verification` or this slice is service-heavy)
List pytest (or equivalent) paths for **api_e2e**, **integration**, and **contract** coverage — not Playwright.

- tests/api/<slice-id>_test.py
- tests/integration/<slice-id>_scenario_test.py

## Hints
Optional. Pointers to existing code, similar patterns, gotchas. Keep terse.

## Operator command (only when `human_gated: true` on terminal `integration-live`)

The exact live step deferred to operator final review. Worker stubs/mocks during build; emits `<adam>CODE-COMPLETE</adam>` with this command; orchestrator appends to `agent-control/human-queue.md` and marks slice `done` when mock verifier is green.

- Example: `aws iam create-access-key --user-name builder && paste into scratch/secrets/aws.env`

## Done signal
Subagent emits `<adam>COMPLETE</adam>` after the verifier exits 0, all listed tests pass, and `paths_out_of_scope` is untouched. For `human_gated: true` slices, the subagent instead emits `<adam>CODE-COMPLETE</adam>` with the operator command.
```

### 5. Update slices/README.md

Index of slices, dependency Mermaid diagram, and a "ready to dispatch" list.

### 6. Seed the status registry

For every slice, append a row to `agent-control/slice-status.md` (template in [`foundation/repo/agent-control/slice-status.md`](../../foundation/repo/agent-control/slice-status.md)):

| id | depends_on | status | branch | verify | notes |
|---|---|---|---|---|---|
| <slice-id> | <comma list or `-`> | `ready` | `-` | `-` | <one phrase> |

`status` starts at `ready` once tests-first has populated red tests. The Tier-1 [`orchestrate-build`](../orchestrate-build/SKILL.md) loop owns flipping it from there.

### 7. Hand off to tests-first

`slice-to-tasks` does not write the actual failing tests. That's [`tests-first`](../tests-first/SKILL.md). After all SPECs exist, run `tests-first` against the slice list to populate `tests/` with red tests.

## Anti-patterns

- **Horizontal slicing.** "Add the API layer" is not a slice. "Let a logged-in user create a project, persisted to DB, visible on the dashboard" is.
- **Slices without acceptance.** If you can't list ACs, you don't understand the slice yet. Sharpen first.
- **Slices that touch huge surface area.** > 500 LOC is usually a sign to split. Re-slice.
- **Implicit dependencies.** Always declare `depends_on` so dispatch can be parallelized correctly.
- **Slices that force the worker to guess.** Workers are non-interactive — they cannot ask. A slice is not ready if a worker would have to invent an architecture decision (data model, API shape, library choice, error-handling strategy) to finish it. Resolve the decision first: capture it in `plan/adr/` or the SPEC `Hints`, never leave it to worker discretion. This is the "think before coding / ask before assuming" discipline applied at the only layer that can act on it — spec authoring.

## Output

`slices/<id>/SPEC.md` + `slices/<id>/verify.sh` for every slice; `slices/README.md` with the dependency graph; `agent-control/slice-status.md` seeded with one `ready` row per slice; terminal `integration-live` slice when live creds are needed. Proceed to [`tests-first`](../tests-first/SKILL.md) autonomously.

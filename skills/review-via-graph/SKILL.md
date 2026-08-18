---
name: review-via-graph
description: Structural review of a builder subagent's branch using the code-review-graph MCP. Use after dispatch-builder or dispatch-parallel returns a green slice, before merging, or when you want to review without reading every line of the diff.
---

# review-via-graph

Token-cheap structural review. Lean on the `code-review-graph` MCP to find issues a green test suite alone won't catch: dead code, callers of removed/changed APIs, layering violations, dependency cycles, etc.

This is the orchestrator's *first* review pass. Runtime review (`review-runtime`) comes after.

## Reviewer contract

The failure mode of an LLM reviewer is *noise*: manufactured findings that train the orchestrator to ignore reviews. Hold every finding to this contract before recording it.

### Pre-report gate (all four must be "yes")

1. **Can I cite the exact location?** A `file:line` (or symbol) from the MCP. "Somewhere in the auth layer" is not actionable; drop it.
2. **Can I name the concrete failure mode?** The input, state, and bad outcome. If you cannot name the trigger, you are pattern-matching, not reviewing.
3. **Have I checked the surrounding context?** Callers, importers, and the slice's tests. Many apparent issues are already guarded one frame up.
4. **Is the severity defensible?** A missing doc-comment is never `critical`. Severity inflation erodes trust faster than a missed nit.

`critical` findings must include the location, the specific failure scenario, and why existing guards (types, validation, the test suite) do not catch it. If you cannot produce all three, demote to `warning` or drop.

### Skip these (common false positives)

- "Consider adding error handling" where the caller, framework, or an upstream boundary already handles it.
- "Missing input validation" on internal functions whose callers already validate (trace one caller first).
- "Function too long" for exhaustive switches, config objects, or test tables. Length is not complexity.
- Stylistic preferences that do not violate `plan/CONTEXT.md` or project rules.
- Issues in **unchanged** code outside the slice, unless `critical` security. Record those in `scratch/review-debt.md`, not as slice findings.

### Zero findings is a valid review

A clean, well-scoped, green slice with no structural issues should return zero findings and verdict `approve`. Do not manufacture findings to justify the pass.

## Inputs

- A slice with `result.branch` set in its `SPEC.md` (e.g. `adam/<slice-id>`).
- All tests for that slice are green on that branch.

## Workflow

### 1. Read the slice context

Open `slices/<id>/SPEC.md`. Note `paths_in_scope`, `paths_out_of_scope`, and ACs. You'll match findings against these.

### 2. Diff envelope

Run `git diff --stat main..<branch>` to get the file-level shape. Verify:
- Every changed file is in `paths_in_scope`.
- No file under `tests/` was modified.
- LOC delta is roughly in line with `estimated_loc` (an order of magnitude is fine; 10x off is suspicious).

If any of those fail, escalate to `babysit-builders`.

### 3. Call the code-review-graph MCP

Use `CallMcpTool` with the appropriate `code-review-graph` tool. Read the tool descriptor first (under `~/.cursor/projects/empty-window/mcps/`) to see the exact API. Typical asks:

- "List all callers of functions I changed in this branch."
- "Are there any new orphaned exports (no callers) introduced by this branch?"
- "Are there any cross-module references that violate the layering listed in `plan/CONTEXT.md`?"
- "What public types changed shape between main and this branch?"

### 4. Triage findings

For each finding:
- If it points at a real problem in the slice's scope → log it under `## Review notes` in `SPEC.md`, decide whether to fix here or in a follow-up slice.
- If it points at a pre-existing problem outside the slice → record it in `scratch/review-debt.md` for later. Do not bloat the current slice.

### 5. Decide

Assign one **verdict** from the fixed vocabulary, derived only from findings that survived the reviewer contract:

| Verdict | Condition | Routing action |
|---|---|---|
| `approve` | No `critical` and no `warning` findings (including a clean zero-finding review) | Ready for `review-runtime` |
| `warning` | `warning` findings only, no `critical` | Mergeable with caution; note the findings, let the orchestrator decide whether to fix here or follow up |
| `block` | One or more `critical` findings | Dispatch a follow-up via `dispatch-builder` with the specific findings, or `escalate` for a user decision |

Do not withhold `approve` to appear rigorous. A clean diff gets `approve`.

**Rework ledger (on `block` only):** before re-dispatching the fix, append one row to `agent-control/rework-ledger.md` (create from `~/adam/foundation/repo/agent-control/rework-ledger.md` if missing). `stage=graph-review`, pick one `class` from that file's taxonomy, `one_liner` = top critical finding, `system_fix=none` unless you patch a SPEC/skill this turn. One row per rework event — not per finding.

### 6. Append to run-result

Append to `scratch/run-results/<slice-id>.json` (or write a sibling `scratch/run-results/<slice-id>.review.json` with `kind: "review"`):
- `verdict` — `approve` | `warning` | `block` (the machine-readable gate the orchestrator reads).
- `review_findings` — array of surviving findings, each with `severity`, `source: "code-review-graph"`, `summary`, and `location` (`file:line`).

The orchestrator gates on `verdict`, not on prose. A `block` verdict keeps the slice off `done` in `agent-control/slice-status.md`.

## What this skill won't catch

- Visual/UX bugs → `review-runtime`
- Wrong behavior under real data → `review-runtime`
- Performance regressions → `review-runtime` with profiling, or a dedicated `diagnose` follow-up
- Logic that has good types and good structure but is still wrong → only the test suite catches that, which is why `tests-first` is strict

## Anti-patterns

- Reading the full diff yourself before consulting the MCP. Token-expensive and reproduces what the MCP can summarize.
- Re-running the test suite during this skill — that's the subagent's job during build, and `review-runtime`'s job during integration.

## Output

`SPEC.md` has a `## Review notes` block. The run-result carries a `verdict` (`approve` | `warning` | `block`) plus the surviving `review_findings`. The orchestrator reads the verdict to decide whether the slice advances to `review-runtime`, gets a fix dispatch, or is escalated. On `block`, `agent-control/rework-ledger.md` has a new row.

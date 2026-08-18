---
name: dispatch-manager
description: Tier-2 per-slice manager. Reads exactly one slices/<id>/SPEC.md, constructs a tightly-scoped worker prompt (reproducing the verifier verbatim), dispatches the worker subagent, runs the verifier once, and returns a single-line summary to the Tier-1 orchestrator. Owns sub-task fan-out for oversized slices. Use when topology_depth=3 in .cursor/adam.json and orchestrate-build hands you a slice id.
---

# dispatch-manager

The **Tier-2 disposable manager**. One slice in, one line out. The manager exists so the Tier-1 orchestrator never has to read a `SPEC.md` body — its entire context dies with this subagent when the slice finishes.

This skill is invoked by [`orchestrate-build`](../orchestrate-build/SKILL.md). It is **not** invoked by the human directly; the human invokes the orchestrator and the orchestrator dispatches managers.

## What this manager holds in context

- Exactly **one** `slices/<id>/SPEC.md`.
- `slices/<id>/verify.sh` (or the inline `verify` one-liner from the SPEC frontmatter).
- `plan/CONTEXT.md` (one screen).
- `packet/PACKET.md` `success_criteria` block only.
- `.cursor/adam.json` (runtime defaults).

**Never** in context:
- Any other slice's spec.
- Any other slice's tests.
- The orchestrator's status registry.
- `orchestration-runs/`.

## Inputs (passed by the orchestrator as paths only)

```
slice_id:               <id>
spec_path:              slices/<id>/SPEC.md
verifier_path:          slices/<id>/verify.sh
context_path:           plan/CONTEXT.md
packet_path:            packet/PACKET.md
config_path:            .cursor/adam.json
paths_out_of_scope:     <list of every other slice dir + packet/, plan/, agent-control/, orchestration-runs/, slices/<id>/SPEC.md, slices/<id>/tests/>
```

## Workflow

### 1. Read the spec (and only the spec)

Read `slices/<id>/SPEC.md`. Note:

- `paths_in_scope` (the only files the worker may write).
- `paths_out_of_scope` from the spec (merge with the orchestrator's list).
- Acceptance criteria.
- Failing test paths the worker must turn green.
- **`verify` block** — the runnable done-signal (a one-liner or a path to `verify.sh`).
- Any `sub_tasks:` frontmatter block (see "Oversized slices" below).
- `human_gated: true` flag, if present.

If the spec is missing any of these, return immediately:

```
blocked: <slice-id> reason=spec-missing-<field>
```

### 2. Build the worker prompt

Use the [`dispatch-builder`](../dispatch-builder/SKILL.md) template. Three additions specific to the manager hop:

1. **Reproduce the verifier verbatim** in the prompt under a `## Verifier (done-signal)` section. The worker must run this and see exit 0 before emitting the completion signal.
2. **Reproduce `paths_out_of_scope` verbatim** — combining the spec's list with the orchestrator's list of every other slice directory.
3. **Reproduce the house rules verbatim** (from `.cursor/rules/adam.md` and the spec): surgical and simple — minimum code, no speculative abstractions, every changed line traces to the SPEC, don't refactor what isn't broken, prefer minimal diffs over rewrites, and emit `<adam>BLOCKED</adam>` instead of guessing anything the SPEC didn't call for.

The worker prompt must contain **paths, not file bodies**. The worker reads its own spec by path.

### 3. Dispatch the worker

```
Task(
  subagent_type: "best-of-n-runner",
  model: "composer-2-fast",
  description: "Build slice <id>",
  prompt: <prompt from step 2>,
  run_in_background: true
)
```

Use `generalPurpose` instead of `best-of-n-runner` only when the spec is a tiny single-file change and the orchestrator passed `runtime_override: generalPurpose`.

### 4. Wait for the worker's done-signal

Arm monitoring per **Long-running task monitoring** in [`foundation/AGENTS.md`](../../foundation/AGENTS.md) when dispatching in step 3. Wait for one of:

- `<adam>COMPLETE</adam>` — worker claims green.
- `<adam>BLOCKED</adam>` — worker hit a scope or context wall.
- `<adam>CODE-COMPLETE</adam>` — worker did all it could; an `operator_command` follows (human-gated slice).

Confirm the worker wrote `scratch/run-results/<id>.json` matching [`schemas/run-result.schema.json`](../../schemas/run-result.schema.json). Missing or malformed → treat as `blocked`.

### 5. Run the verifier once

Run the verifier in your shell:

```bash
bash slices/<id>/verify.sh
```

Record the exit code and any stderr. **Append** to the worker's `scratch/run-results/<id>.json` a `manager_verify` block:

```json
"manager_verify": {
  "command": "bash slices/<id>/verify.sh",
  "exit_code": <int>,
  "stderr_tail": "<last 400 chars or empty>"
}
```

The Tier-1 orchestrator will **re-run the verifier independently** — your run is the manager's smoke check, not the trusted gate.

### 6. Write the run-result update

Also write a `scratch/run-results/<id>.manage.json` matching the `kind: "manage"` shape:

```json
{
  "kind": "manage",
  "id": "<slice-id>",
  "timestamp": "<ISO 8601>",
  "status": "success | fail | blocked | code-complete",
  "summary": "<one short paragraph>",
  "subagent": { "type": "best-of-n-runner", "model": "composer-2-fast" },
  "verifier": { "command": "bash slices/<id>/verify.sh", "exit_code": <int> },
  "operator_command": "<only if status=code-complete>"
}
```

### 7. Return one line up to the orchestrator

The **only** thing the orchestrator sees from you:

```
<status>: <slice-id> branch=<branch> verify=<exit-code>
```

Examples:

```
success: auth-session-cookie branch=builder/auth-session-cookie verify=0
blocked: stripe-webhook branch=builder/stripe-webhook verify=2 reason=secrets-missing
code-complete: dns-rotation branch=builder/dns-rotation verify=1 operator=run-dns-flush.sh
```

Do not narrate. Do not paste diffs. The orchestrator reads `scratch/run-results/<id>.manage.json` if it needs more.

## Oversized slices — sub-task fan-out (within this tier)

If the spec has a `sub_tasks:` block, the slice is too big for one worker. The manager dispatches **one worker per sub-task with sequential hand-offs**, where sub-task N+1 consumes sub-task N's output file.

```yaml
# example sub_tasks: block in SPEC.md
sub_tasks:
  - id: 01-types
    paths_in_scope: [src/types/]
    output: scratch/handoff/<slice-id>/01-types.md
  - id: 02-impl
    depends_on: [01-types]
    paths_in_scope: [src/services/]
    input: scratch/handoff/<slice-id>/01-types.md
  - id: 03-glue
    depends_on: [02-impl]
    paths_in_scope: [src/routes/]
```

For each sub-task in order:

1. Build a sub-prompt: same rules as the parent worker prompt, but `paths_in_scope` is narrowed to the sub-task's list, and `input` is reproduced verbatim if present.
2. Dispatch a worker; wait for its done-signal.
3. Confirm its `output` file exists (if declared).
4. Continue to the next sub-task.

After the last sub-task: run the parent verifier once (step 5) and return one line (step 7). The orchestrator never sees the sub-task boundary.

**Hard rule:** sub-tasks always hand off through files in `scratch/handoff/<slice-id>/`, never through prompt text. This keeps the manager's context flat across the chain.

## CODE-COMPLETE / terminal live slices

If `human_gated: true` (terminal `integration-live` only) or the worker emits `<adam>CODE-COMPLETE</adam>`:

- Capture the `operator_command` the worker printed.
- Return `code-complete: <slice-id> ... operator=<command>` so the orchestrator appends to `human-queue.md` and flips `done` when mock verifier is green.

## Hard rules

- **Never** modify `slices/<id>/SPEC.md`. If the spec is wrong, return `blocked: <id> reason=spec-fix-needed` and let the orchestrator escalate.
- **Never** modify any other slice's files.
- **Never** write to `agent-control/` or `orchestration-runs/` (including `rework-ledger.md` — review/babysit/Tier-1 own that).
- **Never** retry a worker more than once from the manager. After one retry, return `blocked` and let [`babysit-builders`](../babysit-builders/SKILL.md) take over.
- **Never** narrate up. The orchestrator's context is the bottleneck; one line up only.

## When to skip this skill (2-tier fallback)

If `.cursor/adam.json` has `topology_depth: 2`, the orchestrator dispatches workers directly via [`dispatch-builder`](../dispatch-builder/SKILL.md) / [`dispatch-parallel`](../dispatch-parallel/SKILL.md). The manager hop adds context isolation; in small builds (≤5 slices, tiny SPECs) it's pure overhead. Probe both depths on the first wave and lock the choice in `.cursor/adam.json` for the rest of the build.

## Output

- `scratch/run-results/<slice-id>.json` (worker, extended with `manager_verify`).
- `scratch/run-results/<slice-id>.manage.json` (manager's own run-result).
- A **one-line** summary returned to the orchestrator.
- For sub-task fan-out: `scratch/handoff/<slice-id>/*` hand-off files.

## Related

- [`orchestrate-build`](../orchestrate-build/SKILL.md) — Tier 1; calls this skill.
- [`dispatch-builder`](../dispatch-builder/SKILL.md) — Tier 3 prompt template; reused here.
- [`slice-to-tasks`](../slice-to-tasks/SKILL.md) — defines the `verify` block and optional `sub_tasks:` block.
- [`schemas/run-result.schema.json`](../../schemas/run-result.schema.json) — `kind: "manage"` shape.

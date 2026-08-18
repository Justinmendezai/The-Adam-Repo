---
name: dispatch-builder
description: Launch a single Composer 2 subagent to implement one slice. Use when dispatching a single ready slice or running a sequential slice that depends on another in-progress slice. For multiple independent slices at once, use dispatch-parallel.
---

# dispatch-builder

One slice, one Composer 2 subagent. The subagent works in isolation (worktree by default), turns the failing tests green, and emits the completion signal.

## Tier in the topology

This skill is **Tier 3** (the worker dispatch). It can be called two ways:

- **From the Tier-2 manager** ([`dispatch-manager`](../dispatch-manager/SKILL.md)) when `.cursor/adam.json` has `topology_depth: 3`. The manager has already read the slice's `SPEC.md` and built the scoped prompt; this skill's template is what the manager fills in.
- **Directly from the Tier-1 orchestrator** ([`orchestrate-build`](../orchestrate-build/SKILL.md)) when `topology_depth: 2`. Use 2-tier for small builds (≤5 slices, tiny SPECs) where the manager hop is pure overhead. Probe both depths on the first wave and lock the choice in `.cursor/adam.json` for the rest of the build.

Either way, the prompt template below is the contract for the worker.

## When to use

- A single slice with no parallel siblings.
- A slice that depends on another in-progress slice and must run after it.
- The first dispatch of a new build (smoke-test the loop before going parallel).

For multiple independent slices, use [`dispatch-parallel`](../dispatch-parallel/SKILL.md).

## Inputs

- `slices/<id>/SPEC.md` (must exist)
- `tests/<id>/` populated and red
- `plan/CONTEXT.md`
- `.cursor/adam.json`

## Workflow

### 1. Pick runtime

| Choice | Use when |
|---|---|
| `best-of-n-runner` (worktree, branch isolation) | Default. Anything multi-file, anything that might collide with parallel work. |
| `generalPurpose` (in-place) | Tiny single-file change, debugging an in-progress slice, or when you want the subagent to see your live edits. |

### 2. Build the prompt

Use this template. Every section is required. **Paths, not contents:** never paste the SPEC body into the prompt; the worker reads it by path. Reproduce the verifier and `paths_out_of_scope` verbatim so the worker doesn't have to infer them.

```
You are a Composer 2 subagent implementing slice {{SLICE_ID}} of a adam build.

## Repo
{{REPO_PATH}}

## Read these (paths only)
- slices/{{SLICE_ID}}/SPEC.md          # the full spec — read it first
- slices/{{SLICE_ID}}/verify.sh        # the done-signal you must pass
- plan/CONTEXT.md                      # conventions and shared language
- .cursor/rules/adam.md          # house rules

## Paths in scope (only files you may write)
{{PATHS_IN_SCOPE — copied verbatim from SPEC.md}}

## Paths out of scope (never modify)
{{PATHS_OUT_OF_SCOPE — SPEC.md list plus every OTHER slices/<other-id>/ directory plus packet/, plan/, agent-control/, orchestration-runs/, slices/{{SLICE_ID}}/SPEC.md, slices/{{SLICE_ID}}/tests/, slices/{{SLICE_ID}}/verify.sh}}

## Verifier (the done-signal)
This exact command must exit 0 before you emit COMPLETE. Reproduced verbatim from slices/{{SLICE_ID}}/SPEC.md `verify:` block:

    {{VERIFIER_COMMAND}}

The orchestrator will re-run this independently after you finish. It will not trust your self-report.

## Hard rules
1. Run the verifier after each meaningful change. Do not declare done while it exits non-zero.
2. Make the failing tests at the paths listed in the spec turn green. Do NOT edit those test files.
3. Stay within `Paths in scope`. If you genuinely need to touch a path that isn't in scope, stop and emit `<adam>BLOCKED</adam>` with a one-paragraph explanation.
4. Surgical and simple. Write the minimum code that turns the tests green — no speculative abstractions, configurability, or error handling the SPEC didn't ask for. Every changed line must trace to the SPEC. Don't refactor what isn't broken, match the existing style, and only remove orphans your change created. Prefer minimal diffs over rewriting files. If the SPEC didn't call for something and you can't proceed without it, emit `<adam>BLOCKED</adam>` rather than guessing.
5. Match the conventions in plan/CONTEXT.md and the rules in .cursor/rules/adam.md.
6. If the slice's SPEC has `human_gated: true` (terminal `integration-live` only) or live creds are needed, stub/mock first, emit `<adam>CODE-COMPLETE</adam>` with the live `operator_command`, append to `agent-control/human-queue.md`. Mock-path verifier green → still emit COMPLETE when possible.

## Run-result contract
Before emitting the completion signal, write scratch/run-results/{{SLICE_ID}}.json matching ~/adam/schemas/run-result.schema.json with:
- kind: "dispatch"
- id: "{{SLICE_ID}}"
- status: "success" | "blocked" | "fail" | "code-complete"
- branch, commits, files_changed, files_created, tests, summary
- verifier: { command: "<verifier>", exit_code: <int> }
Also append a one-paragraph entry to scratch/last-run.md.

## Completion signal
When the verifier exits 0, the test suite for this slice is green, you have not modified any forbidden path, and the run-result is written, emit exactly:

<adam>COMPLETE</adam>

For terminal live slices: emit `<adam>CODE-COMPLETE</adam>` followed by `operator_command: <command>` and append to `human-queue.md`.

## Token discipline
- Do not narrate. Read. Edit. Run. Report only the final outcome.
- Commit your work in logical chunks; do not push.
```

### 3. Launch with `Task`

For worktree mode:

```
Task(
  subagent_type: "best-of-n-runner",
  model: "composer-2-fast",
  description: "Build slice {{SLICE_ID}}",
  prompt: <prompt above>,
  run_in_background: true
)
```

For in-place:

```
Task(
  subagent_type: "generalPurpose",
  model: "composer-2-fast",
  description: "Build slice {{SLICE_ID}}",
  prompt: <prompt above>,
  run_in_background: true
)
```

`run_in_background: true` is the default — it keeps you free to do other work while it runs.

### 4. While it runs

Arm monitoring in the same turn — see **Long-running task monitoring** in [`foundation/AGENTS.md`](../../foundation/AGENTS.md). Cursor notifies on subagent completion; if the slice needs a dev server or docker stack, start it in a background shell and `Await` the ready line before treating the worker as unblocked.

Use any idle time to stage the next slice (write more failing tests, draft ADRs).

### 5. On completion — re-run the verifier yourself

This is the hard gate. **Never trust the worker's self-report.** Re-run the verifier in your own shell on the worker's branch:

```bash
git checkout adam/<slice-id>
bash slices/<slice-id>/verify.sh
echo "verifier exit=$?"
```

Then:

- Exit 0 + `<adam>COMPLETE</adam>` + `scratch/run-results/<slice-id>.json` valid → hand off to review ([`review-via-graph`](../review-via-graph/SKILL.md), [`review-runtime`](../review-runtime/SKILL.md), or [`e2e-acceptance`](../e2e-acceptance/SKILL.md)), then [`merge-when-green`](../merge-when-green/SKILL.md) when `auto_merge_to_main` is not `false`. Flip `agent-control/slice-status.md` row to `done` after merge lands on `main`.
- Exit non-zero (regardless of what the worker emitted) → flip the row to `blocked` and hand to [`babysit-builders`](../babysit-builders/SKILL.md).
- `<adam>CODE-COMPLETE</adam>` → append `human-queue.md`; flip to `done` if mock verifier green; hand to [`babysit-builders`](../babysit-builders/SKILL.md) if not
- `<adam>BLOCKED</adam>` → read the explanation, decide if scope needs updating or if a follow-up dispatch can resolve it. Do not silently expand the slice.
- Run-result missing or malformed → contract violation; re-dispatch with a focused fix prompt.

### 6. Branch handling

`best-of-n-runner` creates a branch like `adam/<slice-id>` (or its own naming). Note the branch name in `slices/<id>/SPEC.md` under a new `result:` block:

```markdown
## Result
- branch: adam/<slice-id>
- commits: <count>
- review: pending | passing | failing
```

## Output

The slice's branch has commits. The slice's tests pass on that branch. Status is recorded in `SPEC.md`. The slice is queued for review.

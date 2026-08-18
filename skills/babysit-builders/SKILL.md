---
name: babysit-builders
description: Watch in-flight Composer 2 builder subagents, redirect on failure or blocker, collect commits, and triage. Auto-retries before escalating; human items queue to agent-control/human-queue.md instead of blocking the run.
---

# babysit-builders

Builders fail. Builders ask for clarification. Builders sometimes touch paths they shouldn't. This skill keeps them on track **autonomously** — re-dispatch with fixes, queue human-only work for final review, never stop the loop to ask the operator mid-run.

## Triggers

- Subagent emits `<adam>BLOCKED</adam>` with a reason.
- Subagent finishes without the completion signal.
- Subagent's tests are still red after it claims complete.
- **The Tier-1 orchestrator's independent re-run of `slices/<id>/verify.sh` exits non-zero** even though the worker emitted `<adam>COMPLETE</adam>` — this is the most common failure mode.
- Subagent touched a `paths_out_of_scope` file.
- Subagent's branch has merge conflicts with `main` after wave completion.
- **Row stuck in `dispatched`** in `agent-control/slice-status.md` (manager/worker hung).
- Worker emitted `<adam>CODE-COMPLETE</adam>` — queue to `human-queue.md`; do not pause independent branches.

In the 3-tier topology, you may be triaging the **manager's** one-line summary rather than the worker's output directly. The manager's full run-result lives at `scratch/run-results/<slice-id>.manage.json`; the worker's at `scratch/run-results/<slice-id>.json`. Read those, not the chat scrollback.

## Rework ledger (agentic closed loop)

On every **auto-retry / focused re-dispatch** (and on flip to `escalate` after the 3rd fail), append one row to `agent-control/rework-ledger.md` **before** the follow-up dispatch. Create the file from `~/adam/foundation/repo/agent-control/rework-ledger.md` if missing. `stage=babysit`, pick one `class` from that file's taxonomy, `one_liner` = symptom + resolution hint, `system_fix=none` unless you patch SPEC/CONTEXT/skill this turn. Do **not** double-count a row already written by `review-via-graph` / `review-runtime` for the same event.

## Human queue (batched final review)

Append to `agent-control/human-queue.md` instead of stopping for the operator:

```markdown
| HQ-NNN | <slice-id> | live-integration | <one line> | <operator_command> | open | |
```

Kinds: `live-integration`, `taste`, `judgment`, `credentials`. The build keeps rolling; the operator clears the queue in one session at [`e2e-acceptance`](../e2e-acceptance/SKILL.md) handoff.

## Triage by symptom

### Symptom: BLOCKED with reasonable scope question

Read the explanation. Most often it's:
- A path the slice needs that wasn't listed in scope. → Update `SPEC.md` `paths_in_scope`, dispatch follow-up.
- A missing piece in `CONTEXT.md`. → Update `CONTEXT.md`, dispatch follow-up.
- An ambiguity in an AC. → **Resolve from intake grilling notes / ADRs first.** If truly new, write an ADR and dispatch follow-up — do not ask the operator mid-run.

The follow-up dispatch is a fresh `dispatch-builder` call with a focused prompt: "Resume slice X. The previous run blocked on Y. Here is the resolution: Z. Continue."

### Symptom: Tests still red after claimed complete

Either the subagent lied or our tests don't run the way it thought. Check:
- Is the test command in `plan/CONTEXT.md` correct?
- Did the subagent run the tests at all? (Check its output for the test command.)

If the subagent skipped running tests, dispatch a follow-up that hard-requires running the suite.

### Symptom: Orchestrator's independent verifier re-run failed

The worker emitted `COMPLETE` and the manager's smoke run passed, but the Tier-1 orchestrator's re-run of `slices/<id>/verify.sh` exited non-zero. Triage:

- Read `scratch/run-results/<id>.json` for the worker's `verifier.exit_code` (was it 0 on its branch?).
- Diff the verifier on the worker's branch vs. main — did the worker modify `verify.sh` (forbidden)?
- Check for state pollution: did the worker rely on a side-effect (DB row, env var, server running) that wasn't reproducible in the orchestrator's shell? Tighten `verify.sh` to set up its own state.
- If the verifier is itself flaky, fix the verifier (in the orchestrator's working copy), then re-run on the worker's branch.

### Symptom: Touched a forbidden path

Hard violation. Check the diff for that path with `git diff main..builder/<id> -- <path>`. Decide:
- The change is benign and necessary. → Update `paths_in_scope`, accept.
- The change is wrong. → Reset the path on the branch (`git checkout main -- <path>`), dispatch a follow-up to re-attempt without that file.

### Symptom: Hung / timed out

Read the last output of the subagent. If it's mid-thought, the issue is likely a long-running command that idle-timed out. Dispatch a follow-up with `idleTimeoutSeconds` raised, or split the slice further. Use **Long-running task monitoring** from [`foundation/AGENTS.md`](../../foundation/AGENTS.md) — arm `Await`/`notify_on_output` when re-dispatching.

### Symptom: Merge conflicts after parallel wave

Two builders touched related code. Resolve with a focused `generalPurpose` dispatch on the conflict, or merge manually — do not ask the operator unless both auto-fix attempts fail.

### Symptom: `CODE-COMPLETE`

Worker finished mock/stub path but live step remains:

1. Append row to `agent-control/human-queue.md`.
2. If verifier exit 0 (mock path green) → flip slice row to `done`; merge via [`merge-when-green`](../merge-when-green/SKILL.md) when review passes.
3. If verifier non-zero only because live creds missing → flip to `done` with note `live-verify deferred`, queue item stays `open`.
4. Keep rolling on independent branches.

## Hard rules

- Never silently expand a slice's scope. If you change `paths_in_scope`, log it in the slice's `SPEC.md` under a `## Scope changes` section.
- Never edit the test files to make them pass. Tests are the contract.
- Never accept a slice as complete without confirming the **Tier-1 orchestrator's independent re-run of the verifier** is green on the slice's branch (or explicitly deferred live-verify with mock path green).
- Never modify `agent-control/slice-status.md` outside of changing one row's status to `ready` (after a fix) or `escalate` (after the third failed retry). The orchestrator owns the file during the loop. **Exception:** append-only writes to `agent-control/human-queue.md` and `agent-control/rework-ledger.md` are required by this skill.
- **Auto-retry up to 3 times** per slice (scope fix, verifier fix, focused re-dispatch). On the 4th failure, flip to `escalate` and append a one-line entry to `human-queue.md` — do not interrupt the operator mid-run. Every retry/escalate also appends `agent-control/rework-ledger.md` (see Rework ledger above).
- Never ask the operator to resolve BLOCKED ambiguities when intake grilling or ADRs already cover the decision.

## Output

The slice ends in a green branch with passing tests (mock path), merged to `main` when configured, or queued in `human-queue.md` for final operator review. Escalated slices have a one-paragraph summary in the queue, not a chat interrupt.

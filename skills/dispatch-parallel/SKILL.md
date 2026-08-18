---
name: dispatch-parallel
description: Fan out N independent slices to N Composer 2 subagents in parallel, each in its own worktree branch. Use when multiple slices in slices/ are marked ready to dispatch and have no unresolved depends_on edges between them.
---

# dispatch-parallel

The aggressive default. Independent slices ship at the same time, each in its own `best-of-n-runner` worktree, each on a branch named `adam/<slice-id>`. The orchestrator stays free to plan the next wave or write more failing tests while builders run.

## Tier in the topology

This skill is **Tier 3** parallel dispatch. As with [`dispatch-builder`](../dispatch-builder/SKILL.md), it's called two ways:

- **From Tier-2 managers** (one per slice) when `topology_depth: 3` is set in `.cursor/adam.json`. Each manager dispatches its own worker in parallel; the Tier-1 [`orchestrate-build`](../orchestrate-build/SKILL.md) loop fans out N managers.
- **Directly from Tier-1** when `topology_depth: 2`. The orchestrator skips the manager hop and fans out workers itself.

The prompt and the verifier-verbatim contract are the same as `dispatch-builder`; the difference is the wave dispatch and merge ordering covered below.

## When to use

- After [`tests-first`](../tests-first/SKILL.md) marks two or more slices as `ready to dispatch`.
- The slices have **no unresolved `depends_on` edges among each other**.
- The repo can tolerate parallel branches (worktrees handle isolation, but if there are repo-level locks like a single migrations table, see Cautions below).

For a single slice or a sequential dependency, use [`dispatch-builder`](../dispatch-builder/SKILL.md).

## Workflow

### 1. Pick the wave

Read `agent-control/slice-status.md` (the canonical registry; `slices/README.md` is the Mermaid for humans). Find every slice with status `ready` whose `depends_on` rows are all `done`. That's your wave. Cap at `max_parallel_builders` from `.cursor/adam.json` (default 4).

### 2. Build prompts

For each slice in the wave, build the same prompt as [`dispatch-builder`](../dispatch-builder/SKILL.md) — same hard rules, same completion signal, same path discipline.

### 3. Launch them in a single message

Send all `Task` calls in one batch. Each one:

```
Task(
  subagent_type: "best-of-n-runner",
  model: "composer-2-fast",
  description: "Build slice <id>",
  prompt: <slice prompt>,
  run_in_background: true
)
```

`best-of-n-runner` worktrees mean each builder gets its own branch and working directory — no collisions on file edits.

### 4. While they run

Arm monitoring per **Long-running task monitoring** in [`foundation/AGENTS.md`](../../foundation/AGENTS.md). Use the time to stage the next wave's failing tests or draft ADRs.

### 5. As completions arrive — re-run each verifier yourself

You'll get one notification per subagent. For each one, **do not trust the worker's self-report**. Re-verify on the worker's branch in your own shell:

```bash
git checkout adam/<slice-id>
bash slices/<slice-id>/verify.sh
echo "verifier exit=$?"
```

Then for each completed slice:

- Confirm `scratch/run-results/<id>.json` was written by the subagent and parses against the schema (see [`schemas/run-result.schema.json`](../../schemas/run-result.schema.json)).
- Flip the row in `agent-control/slice-status.md`:
  - verifier exit 0 + `COMPLETE` → `done`
  - non-zero or `BLOCKED` → `blocked` (hand to [`babysit-builders`](../babysit-builders/SKILL.md))
  - `CODE-COMPLETE` → append `human-queue.md`; `done` if mock verifier green
- Record the branch/commits in `slices/<id>/SPEC.md` under `## Result`.
- Queue review (`review-via-graph` or `e2e-acceptance`) if green.
- When review `verdict: approve` and `auto_merge_to_main` is not `false`, merge to `main` via [`merge-when-green`](../merge-when-green/SKILL.md) in dependency order.

### 6. Trigger the next wave

When all slices in this wave are reviewed and their dependents now have empty `depends_on`, dispatch the next wave. Repeat until the graph is drained. Operator queue items in `human-queue.md` do not block independent branches.

## Cautions

- **Shared resources.** If two slices both write database migrations, both edit the same config file, or both rebuild a generated artifact, they will conflict on merge. Mark such pairs as serial in the dependency graph during `slice-to-tasks`.
- **Test pollution.** If your test suite has shared fixtures or DB state, parallel test runs may interfere even though file edits don't. Address in `tests-first` by namespacing fixtures per slice.
- **Branch fan-out.** Many simultaneous branches make merge order matter. After all reviews pass, merge in dependency-graph topological order.

## Output

A wave of branches `adam/<slice-id>` exist, each with passing tests on its branch. Each slice's `SPEC.md` records the outcome. Reviews are queued.

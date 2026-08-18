---
name: setup-adam
description: One-time per-repo setup for the Adam orchestration loop. Use when a project does not yet have packet/, plan/, slices/, or agent-control/, or when starting a new build for the first time.
origin: adam
---

# setup-adam

Run once per product repo before the build loop. Idempotent — safe to re-run.

## What it creates

```
packet/
plan/
  plan.md
  CONTEXT.md
  adr/
slices/
  README.md
agent-control/          # templates from ~/adam/foundation/repo/agent-control/
orchestration-runs/
scratch/
  intake-notes.md
  research/
  handoff/
adam/
  context/              # copy templates if missing
  memory/               # empty bucket READMEs if missing
.cursor/
  adam.json
```

## Workflow

1. Confirm target repo path (cwd if git root).
2. If `packet/` etc. exist, only add missing dirs — never destroy content.
3. Seed `agent-control/` and `orchestration-runs/README.md` **copy-if-missing** from `~/adam/foundation/repo/` (includes `slice-status.md`, `human-queue.md`, `rework-ledger.md`, and other control-plane templates).
4. Seed `adam/context/` templates from `~/adam/adam/context/*.template.md` if files absent.
5. Run [`adam-foundation-sync`](../adam-foundation-sync/SKILL.md).
6. Write `.cursor/adam.json`:

   ```json
   {
     "subagent_runtime_default": "best-of-n-runner",
     "subagent_model_default": "composer-2-fast",
     "completion_signal": "<adam>COMPLETE</adam>",
     "max_parallel_builders": 4,
     "tests_first_strict": true,
     "review_mcps": ["code-review-graph", "log-reader-mcp", "playwright"],
     "browser_mcp": "playwright",
     "topology_depth": 2,
     "verifier_convention": "slices/<id>/verify.sh",
     "auto_merge_to_main": false,
     "operator_runs_commands": false,
     "require_plan_approval": false,
     "require_intake_grilling": true
   }
   ```

   **`topology_depth: 2`** — orchestrator → worker (recommended public default). Set `3` to enable Tier-2 `dispatch-manager` for large builds.

   **`auto_merge_to_main: false`** — safer default for OSS users; enable when you trust CI + gates.

7. Append `scratch/` to `.gitignore` if missing. Track `agent-control/`, `adam/context/`, and `plan/` unless the user opts out.

8. Print summary: next steps = fill `packet/PACKET.md`, run `packet-intake` or `grill-with-docs`, read `agent-control/next-orchestrator-brief.md`.

## Conventions

- High-level agent writes plan, slices, tests; workers write implementation only.
- `packet/` read-only for all agents.
- Run-results → `scratch/run-results/<slice-id>.json` per `~/adam/schemas/run-result.schema.json`.
- Branch namespace: `adam/<slice-id>`.

## Related

- [`foundation/cursor/rules.md`](../../foundation/cursor/rules.md)
- [`foundation/repo/folder-contract.md`](../../foundation/repo/folder-contract.md)

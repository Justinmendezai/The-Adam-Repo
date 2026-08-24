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
adam.json               # canonical project config
.cursor/adam.json       # Cursor mirror
.agents/adam.json       # Codex mirror
.claude/adam.json       # Claude Code mirror
```

## Workflow

1. Confirm target repo path (cwd if git root).
2. If `packet/` etc. exist, only add missing dirs — never destroy content.
3. Seed `agent-control/` and `orchestration-runs/README.md` **copy-if-missing** from `~/adam/foundation/repo/` (includes `slice-status.md`, `human-queue.md`, `rework-ledger.md`, and other control-plane templates).
4. Seed `adam/context/` templates from `~/adam/adam/context/*.template.md` if files absent.
5. Run [`adam-foundation-sync`](../adam-foundation-sync/SKILL.md).
6. Write `adam.json` from [`foundation/adam.json`](../../foundation/adam.json) if missing. Mirror the same file to `.cursor/adam.json`, `.agents/adam.json`, and `.claude/adam.json` (create dirs; overwrite mirrors only when they match an older Adam template, never when the user customized them).

   **`topology_depth: 2`** — orchestrator → worker (recommended public default). Set `3` to enable Tier-2 `dispatch-manager` for large builds.

   **`auto_merge_to_main: false`** — safer default for OSS users; enable when you trust CI + gates.

7. Append `scratch/` to `.gitignore` if missing. Track `agent-control/`, `adam/context/`, and `plan/` unless the user opts out.

8. If `packet/PACKET.md` is missing: do **not** tell the operator to copy a template. When invoked from [`calibrate`](../calibrate/SKILL.md), calibrate drafts it. When invoked standalone and `adam/context/founder.md` exists, draft a minimal `PACKET.md` from that context. Otherwise create `packet/` and stay in conversation to fill the brief in plain language.

9. Tell the operator in one sentence that the project folder is ready. Do not hand them a skill-name checklist.

## Conventions

- High-level agent writes plan, slices, tests; workers write implementation only.
- `packet/` read-only for all agents.
- Run-results → `scratch/run-results/<slice-id>.json` per `~/adam/schemas/run-result.schema.json`.
- Branch namespace: `adam/<slice-id>`.
- Project config path: first existing of `adam.json`, `.agents/adam.json`, `.cursor/adam.json`, `.claude/adam.json` ([`AGENTS.md`](../../AGENTS.md) Host paths). Do not rename Cursor paths on Codex/Claude — the mirrors already exist.

## Related

- [`foundation/rules.md`](../../foundation/rules.md)
- [`foundation/repo/folder-contract.md`](../../foundation/repo/folder-contract.md)
- [`foundation/codex/AGENTS.section.md`](../../foundation/codex/AGENTS.section.md)
- [`foundation/claude/CLAUDE.md`](../../foundation/claude/CLAUDE.md)

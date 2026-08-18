# adam repo folder contract

Standard layout for a project running the adam loop. Created by [`setup-adam`](../../skills/setup-adam/SKILL.md) and synced by [`adam-foundation-sync`](../../skills/adam-foundation-sync/SKILL.md).

## Required structure

```
project-root/
├── adam/                     # CALIBRATION + MEMORY — human + orchestrator
│   ├── context/              # user profile, technical level, prefs (read every session)
│   └── memory/               # durable buckets: architecture, bugs, decisions, features, gtm, handoffs, research
├── packet/                   # INPUT — human-owned, agent read-only
│   ├── PACKET.md
│   ├── refs/                 # supporting docs, screenshots, transcripts
│   ├── data/                 # CSVs, JSON, sample inputs
│   └── schemas/              # API contracts, type defs
├── plan/                     # PLANNING — orchestrator-owned
│   ├── plan.md
│   ├── CONTEXT.md
│   └── adr/
│       ├── 0001-<name>.md
│       └── 0002-<name>.md
├── slices/                   # WORK BREAKDOWN — orchestrator-owned
│   ├── README.md             # index + dependency Mermaid
│   └── <slice-id>/
│       ├── SPEC.md           # the brief; subagents read but never modify
│       ├── verify.sh         # runnable done-signal; Tier-1 orchestrator re-runs independently
│       └── tests/            # failing tests; subagents read but never modify
├── scratch/                  # WORKING NOTES — orchestrator + subagent write
│   ├── intake-notes.md
│   ├── research/             # explore-subagent dumps
│   ├── run-results/
│   │   └── <slice-id>.json   # one per dispatch, schema in ~/adam/schemas/
│   ├── review-evidence/
│   │   └── <slice-id>/       # screenshots, profile dumps, MCP findings
│   ├── handoff/
│   │   └── primer-<ts>.md    # context-primer output (ephemeral); may mirror agent-control
│   └── last-run.md           # latest human-readable summary
├── agent-control/            # META + DURABLE — orchestrator-owned; subagents read-only
│   ├── mission.md            # north star; links packet
│   ├── current-state.md      # phase, blockers, last run id
│   ├── task-graph.md         # high-level themes / link to slices
│   ├── active-sprint.md      # ONE bounded objective (10-bullet max)
│   ├── completed-work.md     # rolling log / pointers to run folders
│   ├── decisions.md          # ADR pointers
│   ├── open-issues.md       # cross-run backlog
│   ├── slice-status.md       # CANONICAL status registry for orchestrate-build (one row per slice)
│   ├── test-status.md        # verification / e2e roll-up
│   ├── security-status.md    # audit + security-acceptance roll-up (seeded copy-if-missing)
│   ├── dev-launch-ledger.md  # path-unblocker ledger (seeded copy-if-missing)
│   ├── human-queue.md        # batched operator items (taste, live creds, judgment) — append during run
│   ├── rework-ledger.md      # agentic review/rework closed loop — append on block/retry
│   └── next-orchestrator-brief.md  # canonical entry for fresh build orchestrator
├── orchestration-runs/       # DURABLE — one folder per bounded orchestrator cycle
│   ├── README.md
│   └── run-<NNN>/
│       ├── summary.md
│       ├── commits.md        # or diffs.md
│       ├── test-results.md
│       └── open-issues.md     # delta
├── src/                      # PROJECT CODE — subagents write within slice scope
└── .cursor/
    ├── adam.json       # project config (subagent defaults, MCP list, signals)
    └── rules/                # synced from ~/adam/foundation/cursor/rules.md
```

## Permissions

| Path | Orchestrator | Subagent |
|---|---|---|
| `packet/` | read | read |
| `plan/` | read/write | read |
| `slices/<id>/SPEC.md` | read/write | read |
| `slices/<id>/verify.sh` | read/write | read |
| `slices/<id>/tests/` | read/write | read |
| `agent-control/` | read/write | read |
| `orchestration-runs/` | read/write | read |
| `scratch/` | read/write | read/write (their slice's subdir) |
| `src/` | read | read/write (within slice scope) |
| `.cursor/` | read | read |

## Hard rules (mirrors `foundation/cursor/rules.md`)

- Never modify files under `packet/`.
- Never modify `slices/<id>/SPEC.md`, `slices/<id>/verify.sh`, or `slices/<id>/tests/` from a subagent.
- Subagents must **not** modify `agent-control/` or append to `orchestration-runs/` — read-only. Only the **build orchestrator**, **`session-steward`**, review skills (`review-via-graph` / `review-runtime` / `e2e-acceptance`), and **`babysit-builders`** write those — and only for status flips plus append-only `human-queue.md` / `rework-ledger.md`.
- Subagent edits must stay within their slice's `paths_in_scope`.
- The **Tier-1 orchestrator** is the only writer of `agent-control/slice-status.md` during the loop. Tier-2 managers and Tier-3 workers never touch it.
- Every dispatch writes a `scratch/run-results/<slice-id>.json` and updates `scratch/last-run.md`.
- The Tier-1 orchestrator re-runs `slices/<id>/verify.sh` itself before flipping any row to `done` — worker self-reports are never trusted.

## What lives outside `scratch/`

- `plan/` is durable. ADRs are append-only.
- `slices/` is durable. The history of slice specs is the history of the build.
- **`agent-control/`** and **`orchestration-runs/`** are durable **project memory** for orchestration — version control recommended (small markdown only).
- `scratch/` is throwaway. Add to `.gitignore` if you don't want it in version control. (`setup-adam` does this by default.)

---
name: context-primer
description: Compact the current high-level orchestrator session into a primer doc so the next agent (or you, after a refresh) can resume cleanly. Prefer keeping **one canonical** `agent-control/next-orchestrator-brief.md` in sync. Use when token usage is approaching 50-60%, when the user asks to hand off, or before a long pause.
---

# context-primer

The token-budget escape hatch. When the orchestrator is getting heavy, dump everything the next agent needs to resume the build into a single primer file. The next session reads only the primer, not your full transcript.

**Canonical handoff for Adam:** if `agent-control/next-orchestrator-brief.md` exists, treat it as the **source of truth** for “what to do next.” This skill still writes `scratch/handoff/primer-*.md` as an **audit trail** — that primer must **not** contradict the brief.

After writing the primer, update **`agent-control/next-orchestrator-brief.md`** (or add a prominent pointer at the top of the primer: "Sync this content into `agent-control/next-orchestrator-brief.md` via copy or run [`session-steward`](../session-steward/SKILL.md)").

## When to run

- Token usage at ~50–60% of capacity.
- About to hand off to a different model or person.
- About to wrap for the day on a multi-day build.
- After `e2e-acceptance` — capture the final state for posterity.

## When to compact (decision table)

The 50–60% threshold tells you *when you may*; this table tells you *whether you should*. Compact at logical phase boundaries, not mid-task.

| Phase transition | Compact? | Why |
|---|---|---|
| Research/intake → plan | Yes | Research context is bulky; the plan is the distilled output. |
| Plan → build (first dispatch) | Yes | The plan lives in `plan/` and `slice-status.md`; free context for dispatch and review. |
| Mid-implementation review of one slice | No | You lose file paths, branch names, and partial dispatch state. Finish the wave first. |
| After a failed approach / abandoned dispatch | Yes | Clear the dead-end reasoning before trying a new path. |
| Build → e2e-acceptance | Maybe | Keep if the acceptance walk references slices you just reviewed; compact if switching focus. |
| Between bounded orchestrator cycles | Yes | Hand the next cycle a clean brief via `session-steward`. |

## What survives a compaction

Compact with confidence by knowing what persists versus what is lost. Anything in the "Lost" column must be written to disk *before* you compact.

| Persists | Lost |
|---|---|
| Foundation rules (`foundation/cursor/rules.md`, project rules) | Intermediate reasoning and analysis |
| `agent-control/` files (slice-status, next-orchestrator-brief, active-sprint) | File contents you previously read |
| `orchestration-runs/`, `scratch/run-results/`, `scratch/handoff/` | Multi-step conversation history |
| Git state (commits, branches, worktrees) | Tool-call history and counts |
| Files on disk (packet, plan, slices, tests) | Preferences stated only verbally in chat |

## Write before you compact (checklist)

Run this checklist before any compaction so nothing in the "Lost" column matters:

- [ ] `agent-control/next-orchestrator-brief.md` reflects the true current state and the single next concrete step.
- [ ] `agent-control/slice-status.md` rows match reality (in-flight, blocked, done).
- [ ] Any in-flight dispatch has a `scratch/run-results/<id>.json` (branch, verifier result, verdict).
- [ ] Deferred ambiguities are in `scratch/intake-notes.md`, not only in chat.
- [ ] Durable decisions are captured as ADRs (`plan/adr/`) or `orchestration-runs/` entries, not verbal-only.
- [ ] This primer (`scratch/handoff/primer-*.md`) is written and does not contradict the brief.

## Output

`scratch/handoff/primer-<YYYYMMDD-HHmm>.md` (timestamped so multiple primers don't clobber). Contents:

```markdown
# Adam Primer — <project name>

- Generated: <ISO timestamp>
- Repo: <path>
- Current branch: <branch>
- Token budget at primer time: <%>

## What we're building (1 paragraph)

Drawn from packet/PACKET.md `one_liner` + `goals`.

## Where we are

- Phase: intake | plan | build | review | done
- Slices done: [<id>, ...]
- Slices in flight: [<id> on branch <branch>, ...]
- Slices not yet started: [<id>, ...]

## Critical decisions

The 3–5 ADRs in plan/adr/ that the next agent must internalize. One-line summaries with paths.

## Open ambiguities

Anything in scratch/intake-notes.md that is `deferred` rather than `resolved`.

## Active blockers

From slices/*/SPEC.md `## Result` blocks where status is BLOCKED.

## Conventions to honor

- Strict TDD ownership: high-level agent writes tests, subagents only write impl.
- Subagent runtime defaults from `adam.json`
- Naming/path conventions from plan/CONTEXT.md (one-line summary)

## Next concrete step

The single command-or-skill the next agent should run first. Be specific. E.g. "Run dispatch-parallel against the wave [slice-3, slice-4]; both are ready to dispatch."

**Must match** `agent-control/next-orchestrator-brief.md` after sync (if that file is used in this repo).

## Files the next agent should read in order

1. `agent-control/next-orchestrator-brief.md` *(if present — **canonical** for Adam factory meta flow)*
2. packet/PACKET.md
3. agent-control/active-sprint.md
4. plan/plan.md
5. plan/CONTEXT.md
6. slices/README.md
7. The slice spec(s) for the next concrete step

## Files the next agent should NOT read up front

The full plan/adr/ tree (read only what's referenced).
The full tests/ tree (only when working on a slice).
This primer's transcript.

## Quirks worth knowing

- (free-form, ~3 bullets max)
```

## Workflow

1. Read `scratch/intake-notes.md`, `plan/plan.md`, `plan/adr/`, `slices/README.md`, and every `slices/<id>/SPEC.md`.
   (You read these from your existing context. Don't re-read source files.)
2. Fill the template above.
3. Save to `scratch/handoff/primer-<timestamp>.md`.
4. **Sync** the **Next concrete step** and **Where we are** sections into `agent-control/next-orchestrator-brief.md` if the project uses `agent-control/` (or run [`session-steward`](../session-steward/SKILL.md) after to compress the run).
5. **Required chat closing** — do not end with only a file path. In the same message include:

1. Heading `## Kick off next chat`
2. **Open this repo in Cursor:** `<absolute/repo/path>`
3. Instruction to start a new Agent chat there and paste the block below
4. A fenced `text` code block with a paste-ready kickoff, default shape:

```
Continue Adam factory run.

Repo: <absolute/repo/path>
Read first: agent-control/next-orchestrator-brief.md
Then (audit trail): scratch/handoff/primer-<timestamp>.md
Also read: agent-control/standing-operator-rules.md (seed from Adam foundation if missing)

Next concrete step: <exact step from the brief / primer>

Standing rules (non-negotiable):
- Push feature branches to origin before done; never leave WIP local-only.
- Gate origin/main with ship-when-audited (third-party critic + Bugbot); escalate only arch-impact.
- After intake grill: dual research pods (+ and anti) before plan ADRs.
- No mid-run operator gates; taste/live only at end via human-queue.
- Run all CLI yourself; monitor background jobs (Await/notify) — no silent stalls.
- Anti-theater: real producer/consumer for PASS; no greenwashed scorecards.
- Rework ledger on every block/retry; recurring class → skill/HANDOFF patch.
- UI slices: frontend-taste + theme-from-packet.

Do not re-read the prior chat transcript.
```

5. Paths for primer + canonical brief on disk

If `agent-control/` is missing, point at the primer instead of the brief, but still paste the full kickoff block and absolute repo path.

## Quality bar

A good primer is **under 200 lines**. If yours is longer, you're including too much narrative — link to the source files instead. The next agent's job is to read those files; your job is to point at them.

## Anti-patterns

- Quoting plan.md verbatim. Link to it.
- Quoting full ADRs. Summarize each in one line; link.
- Including conversational history. Pointless — the next agent has no use for your prior thinking, only for current state.
- Contradicting **`agent-control/next-orchestrator-brief.md`** with a different “next step.” Merge into one canonical brief.
- **File-only handoff** — writing the primer and saying “path is X” without pasting the kickoff prompt and absolute repo in chat.

## Output

A primer file exists. The chat includes the absolute repo path and a paste-ready kickoff prompt for a fresh Agent session.

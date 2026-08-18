---
name: repo-truth
description: Read-only audit of git vs project docs — main HEAD, floating branches, stale plan rows, operator punch list. Use for repo-truth, project sync, what landed on main, floating branches, or punch list.
origin: adam
disable-model-invocation: true
---

# repo-truth

Sync **docs vs git reality**. Read-only until user asks for doc edits.

## Scope

Default: **current product repo**. User may name additional repos.

## Read first

- `plan/plan.md`, `plan/CONTEXT.md`
- `agent-control/slice-status.md`, `agent-control/current-state.md`
- `agent-control/next-orchestrator-brief.md`
- `slices/README.md`

## Procedure

1. `git fetch origin` (read-only).
2. Record `origin/main` SHA + one-line note.
3. List unmerged branches (`adam/*`, feature branches).
4. Diff doc claims vs git (merged slices still marked open? brief stale?).
5. Punch list: **operator-only** vs **dispatchable build work**.

## Output shape

```markdown
# Repo-truth audit — YYYY-MM-DD

## Main
| Branch | SHA | Notes |

## Stale doc rows
| Item | Docs said | Git truth |

## Floating branches
| Branch | Action |

## Operator punch list
1. ...
```

Optional: offer `/canvas-project` for visual status.

## Rules

- Facts from git only; verify before trusting doc dates.
- End with: "Update plan / agent-control?" — surgical edits only on approval.

---
name: adam-foundation-sync
description: Copy Adam foundation rules and folder contract into a target project, and verify global MCP servers. Use during setup-adam, after foundation updates, or when adopting Adam in an existing repo.
origin: adam
---

# adam-foundation-sync

## Inputs

- Target repo path (default: git root cwd)
- `~/adam/foundation/` source of truth
- `~/.cursor/mcp.json`

## What gets copied

| Source | Destination | Overwrite? |
|--------|-------------|------------|
| `~/adam/foundation/cursor/rules.md` | `<repo>/.cursor/rules/adam.md` | only with user `--force` |
| `~/adam/foundation/repo/folder-contract.md` | `<repo>/docs/adam-folder-contract.md` | only with `--force` |
| `~/adam/schemas/run-result.schema.json` | `<repo>/.cursor/adam.run-result.schema.json` | yes |

## Agent-control seed (missing files only)

Copy each `~/adam/foundation/repo/agent-control/*` → `<repo>/agent-control/` if absent.

Copy `~/adam/foundation/repo/orchestration-runs/README.md` if absent.

## MCP check

Read `~/.cursor/mcp.json`. Recommend:

- `code-review-graph`
- `log-reader-mcp`
- `playwright` and/or `cursor-ide-browser`

If missing, show install hints from `~/adam/foundation/cursor/mcp.example.json`. **Ask before editing global MCP config.**

## Workflow

1. Confirm git repo path.
2. Show diff of files that would change.
3. User confirms → write files.
4. Update `.cursor/adam.json` `foundation_synced_at` timestamp (create minimal config if missing).
5. Report synced files + MCP status + next step.

## Anti-patterns

- Overwriting customized rules without diff + approval
- Deleting destination files

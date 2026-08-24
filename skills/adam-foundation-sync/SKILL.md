---
name: adam-foundation-sync
description: Copy Adam foundation rules and folder contract into a target project, and verify global MCP servers. Use during setup-adam, after foundation updates, or when adopting Adam in an existing repo.
origin: adam
---

# adam-foundation-sync

## Inputs

- Target repo path (default: git root cwd)
- `~/adam/foundation/` source of truth
- Host MCP config (Cursor `~/.cursor/mcp.json`, Codex `~/.codex/config.toml`)

## What gets copied

| Source | Destination | Overwrite? |
|--------|-------------|------------|
| `~/adam/foundation/cursor/rules.md` | `<repo>/docs/adam-rules.md` | only with user `--force` |
| same | `<repo>/.cursor/rules/adam.md` | only with `--force` |
| `~/adam/foundation/codex/AGENTS.section.md` | append to `<repo>/AGENTS.md` if that heading is absent | never overwrite existing Adam section |
| `~/adam/foundation/claude/CLAUDE.md` | `<repo>/CLAUDE.md` | only if missing, or `--force` |
| `~/adam/foundation/repo/folder-contract.md` | `<repo>/docs/adam-folder-contract.md` | only with `--force` |
| `~/adam/schemas/run-result.schema.json` | `<repo>/schemas/run-result.schema.json` | yes |
| same | `<repo>/.cursor/adam.run-result.schema.json` | yes (Cursor mirror) |
| same | `<repo>/.agents/adam.run-result.schema.json` | yes (Codex mirror) |

If `adam.json` is missing but `.cursor/adam.json` exists, copy `.cursor/adam.json` → `adam.json`. Then mirror `adam.json` to `.cursor/adam.json`, `.agents/adam.json`, and `.claude/adam.json` when those mirrors are missing.

## Agent-control seed (missing files only)

Copy each `~/adam/foundation/repo/agent-control/*` → `<repo>/agent-control/` if absent.

Copy `~/adam/foundation/repo/orchestration-runs/README.md` if absent.

## MCP check

Recommend `code-review-graph`, `log-reader-mcp`, `playwright` (and/or the host browser MCP).

- Cursor: read `~/.cursor/mcp.json`; hints in `~/adam/foundation/cursor/mcp.example.json`
- Codex: read `~/.codex/config.toml`; hints in `~/adam/foundation/codex/config.toml.example`

**Ask before editing global MCP config.**

## Workflow

1. Confirm git repo path.
2. Show diff of files that would change.
3. User confirms → write files.
4. Update `adam.json` `foundation_synced_at` timestamp (create from `~/adam/foundation/adam.json` if missing). Refresh host mirrors when they still match the previous template.
5. Report synced files + MCP status + next step.

## Anti-patterns

- Overwriting customized rules without diff + approval
- Deleting destination files
- Flattening `skills/*/SKILL.md` into one directory
- Renaming `.cursor/` trees on Codex/Claude instead of writing the host mirrors above

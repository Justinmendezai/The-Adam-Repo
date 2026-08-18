# Bootstrap — first project with Adam

Cursor is the documented path. Same skills are meant to bolt onto any coding agent that can load them.

What’s in the box (context, skills, rules, loop gates, tools): [README](../README.md).

## Prerequisites

- A coding agent ([Cursor](https://cursor.com) is written up here)
- Git repo for your product (new or existing)
- Optional MCPs for review: see [`foundation/cursor/mcp.example.json`](../foundation/cursor/mcp.example.json)

## 1. Install Adam

```bash
git clone https://github.com/Justinmendezai/The-Adam-Repo.git ~/adam

mkdir -p ~/.cursor/skills
for d in ~/adam/skills/*/; do
  name=$(basename "$d")
  ln -sf "$d" "$HOME/.cursor/skills/$name"
done
```

Re-run the symlink loop after `git pull` when new skills land (includes operator commands: `go`, `ship`, `handoff-prompt`, `repo-truth`, etc.).

**Content creators:** upload [`notebooklm-adam-source.md`](notebooklm-adam-source.md) to NotebookLM for visuals and atomized scripts (L0–L5 ladder).

## 2. Calibrate (once per operator, or per major new venture)

In Cursor, open **`~/adam`** or your product repo and invoke the **`calibrate`** skill.

Adam interviews you and writes:

```
adam/context/user-profile.md
adam/context/technical-level.md
adam/context/preferences.md
adam/context/founder.md
adam/context/project.md
```

Copy or symlink `adam/context/` into your product repo if you keep Adam in its own folder.

## 3. Set up the product repo

In your **product** repo:

```
Run setup-adam
```

Creates `packet/`, `plan/`, `slices/`, `agent-control/`, `scratch/`, `.cursor/adam.json`, and syncs foundation rules.

## 4. Write the packet

Copy [`packet/template/PACKET.md`](../packet/template/PACKET.md) → `packet/PACKET.md`. Fill goals, success criteria, constraints.

## 5. Run the loop

| Step | Skill / action |
|------|----------------|
| Intake + grilling | `packet-intake` or `grill-with-docs` |
| Plan | `research-and-plan` |
| Optional council | Follow `council/runbook.md` |
| Slice | `slice-to-tasks` |
| Tests | `tests-first` |
| Build | `orchestrate-build` |
| Session close | `context-primer` or `session-steward` |

## 6. Never-coded founders

Use communication preference **"Teach me"** during calibration. Adam should:

- Explain each step in plain language before running it
- Avoid jargon without defining it
- Prefer small slices and visible checkpoints

You still use your coding agent. Adam organizes how it works.

## 7. Context window handoff

Cursor may not expose a 65% context threshold. **Simulate:** when the chat feels heavy, run **`context-primer`** and start a fresh chat with `agent-control/next-orchestrator-brief.md`.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Skills not found | Check symlinks in `~/.cursor/skills/` |
| MCP review fails | Add servers from `mcp.example.json` to `~/.cursor/mcp.json` |
| Orchestrator bloated | Default `topology_depth: 2` in `.cursor/adam.json` |

See also [`reasonable-limit.md`](reasonable-limit.md).

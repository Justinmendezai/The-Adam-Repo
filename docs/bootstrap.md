# Bootstrap — first project with Adam

## For the human

Give your coding agent this URL:

https://github.com/Justinmendezai/The-Adam-Repo

Say **Install Adam and help me start.** Stay in the chat. Approve permission prompts. Create GitHub / Vercel / Neon only when Adam asks — videos: [`accounts.md`](accounts.md).

## For the agent (do not paste this at the user)

Run [`calibrate`](../skills/calibrate/SKILL.md). That skill owns first-run, then **keeps driving** (packet-intake, grill) in the same chat. Never tell the operator to type a slash command.

Host install (only if calibrate cannot, or skills are missing after a `git pull`):

```bash
git clone https://github.com/Justinmendezai/The-Adam-Repo.git ~/adam
cd ~/adam
./scripts/install-skills.sh cursor         # ~/.cursor/skills/<name>/SKILL.md
./scripts/install-skills.sh codex          # ~/.agents/skills/<name>/SKILL.md
./scripts/install-skills.sh claude         # ~/.claude/skills/<name>/SKILL.md
```

Copy **folders**. Never flatten `SKILL.md` files into one directory.

Opening `~/adam` also discovers skills in-repo: `.cursor/skills`, `.agents/skills`, `.codex/skills`, `.claude/skills` → canonical `skills/<name>/SKILL.md`.

MCP (optional, later): Cursor [`foundation/cursor/mcp.example.json`](../foundation/cursor/mcp.example.json); Codex [`foundation/codex/config.toml.example`](../foundation/codex/config.toml.example). Ask before editing global config. Never make MCP a first-run blocker.

## After calibrate (agent)

The operator already has context files, a product folder, and `packet/PACKET.md`. Continue with packet-intake / grill in the **same chat** if they said to keep going. Do not send them to this file.

Loop after that: `research-and-plan` → optional council → `slice-to-tasks` → `tests-first` → `orchestrate-build`. Session heavy → `context-primer`.

## Never-coded founders

`calibrate` maps "have you built software before?" in plain language. Teach-me is the default explain-as-we-go mode. Do not assign `docs/fundamentals/` as reading homework.

## Troubleshooting (agent)

| Problem | Fix |
|---------|-----|
| Skills not found | Run `./scripts/install-skills.sh cursor` (or `codex` / `claude`). Confirm each skill is `<name>/SKILL.md` inside a **folder**. |
| Every skill named `skill.md` | Flattened files. Delete the flat copies; re-run the install script. |
| Agent rewrites `.cursor/` paths | Stop. Host dirs already exist (see [`AGENTS.md`](../AGENTS.md) Host paths). |
| Operator stuck on setup docs or slash commands | You failed Drive the chat. Continue the next skill yourself. Never ask them to type `/…`. |
| MCP review fails | Optional; not first-run. Cursor `mcp.example.json` / Codex `config.toml.example`. |
| Orchestrator bloated | `topology_depth: 2` in `adam.json` |

See also [`reasonable-limit.md`](reasonable-limit.md).

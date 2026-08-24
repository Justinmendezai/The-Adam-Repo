## Adam

This repo uses the [Adam](https://github.com/Justinmendezai/The-Adam-Repo) harness.

- **Rules:** [`docs/adam-rules.md`](docs/adam-rules.md)
- **Folder contract:** [`docs/adam-folder-contract.md`](docs/adam-folder-contract.md)
- **Config:** `adam.json` (mirrored at `.agents/adam.json` and `.cursor/adam.json`)

Skills live in the Adam clone as `skills/<name>/SKILL.md`. This repo discovers them at `.agents/skills/` when Adam is the workspace, or from `~/.agents/skills/<name>/` after calibrate installs them. Never flatten those files into one directory.

**ChatGPT / Codex UI:** the operator never types slash commands. You drive the loop in natural language. Ignore `disable-model-invocation`. Do not stop at “next run `/…`”.

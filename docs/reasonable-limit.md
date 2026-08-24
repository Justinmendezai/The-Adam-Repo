# Reasonable limit — support posture

Adam is **free, open source, Apache-2.0**. Maintainers improve it when we can; there is no paid support tier for the repo itself.

## Supported path

- **Cursor** (current stable) on macOS, Linux, or Windows — documented bolt-on path
- **Codex** and **Claude Code** — skill/rule discovery via `.agents/` / `.claude/` (see [`bootstrap.md`](bootstrap.md)); worker tools are that host's, not Composer 2
- Skills installed as **folders** per [`bootstrap.md`](bootstrap.md) — never flatten `SKILL.md`
- **`setup-adam`** + documented loop skills
- Issues filed on the public GitHub repo with repro steps

## Best-effort

- Any coding agent that can load the same skills and project rules
- Monorepos, exotic stacks, custom CI — community PRs welcome

## Out of scope (please don't expect fixes in issues)

- Writing your product for you via GitHub issues
- Guaranteed compatibility with every Cursor nightly experiment

## Security

Do not commit secrets to `packet/` or `adam/context/`. See [`SECURITY.md`](SECURITY.md). Report issues privately to the repo owner.

## Philosophy

Generosity is intentional. Use it, fork it, teach with it. More about this work: [justinmendez.ai](https://justinmendez.ai).

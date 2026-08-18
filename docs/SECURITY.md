# Security — Adam as distributed software

Adam is markdown, skills, and templates you clone onto your machine. It runs in your coding agent. It does not process other people's data in a multi-tenant cloud.

## Trust boundary

| You control | Adam does not |
|-------------|----------------|
| Your product repo, secrets, and cloud accounts | Host a shared runtime for strangers |
| Which skills and MCPs you enable | Phone home or collect telemetry |
| What agents may write or push | Bypass your git remotes or IDE permissions |

Cloning this repo is equivalent to installing a set of agent instructions. Review skills before enabling them, the same way you would review a Makefile or CI workflow.

## Secrets

- Never commit `.env`, credentials, private keys, or tokens.
- Calibration files (`adam/context/`) and packets can accumulate personal notes — keep them in **your product repo**, not in a public fork of Adam.
- `foundation/cursor/mcp.example.json` uses placeholders only.

## Agent blast radius

Skills tell agents to read, edit, and run commands. Bound that:

- Use `setup-adam` in a **product** repo, not by dumping secrets into this clone.
- Keep `packet/` human-owned; workers must not expand scope silently.
- Prefer deterministic gates (schema, tests, linters) over “the model said it was fine.”

## Reporting

Email the GitHub org owner or open a **private** security advisory on this repository. Do not file public issues that include secrets.

---
name: security-audit
description: Read-only security inventory of a repo or multi-repo ecosystem — auth surfaces, secrets, webhooks, dependencies, CI gaps — outputting scratch/security-audit/*.json and *.md for planning agents. Use before security refactor, tests-first security slices, or security-acceptance.
---

# security-audit

Produces **durable audit artifacts** other agents consume for refactor planning and security test design. **No product code changes** unless the human explicitly asks for remediation in the same session.

## When to use

- Before a **security refactor** sprint (ecosystem or single service).
- After major auth/routing changes — refresh the audit.
- When `packet/PACKET.md` references `security.audit_ref` and the file is stale or missing.
- Human asks for “security audit”, “threat inventory”, or “what’s exposed”.

Pair with [`security-acceptance`](./security-acceptance/SKILL.md) after fixes land.

## Outputs (required)

Write under **`scratch/security-audit/`** at the **project root** being audited (for ecosystem audits, prefer `~/adam/scratch/<name>/` or a dedicated meta repo):

| File | Purpose |
|------|---------|
| `audit-<YYYYMMDD>.json` | Machine-readable; validate against [`schemas/security-audit.schema.json`](../../schemas/security-audit.schema.json) |
| `audit-<YYYYMMDD>.md` | Human-readable inventory + top findings per repo |
| `planning-brief.md` | **For downstream agents:** P0–P2 priorities, suggested vertical slices, suggested test types — no implementation |

Update **`agent-control/security-status.md`** when the target repo has `agent-control/` (summary table + link to audit files). Subagents: **read-only** on `agent-control/`.

## Workflow

### 1. Define scope

- **Ecosystem:** list absolute paths and repo ids (e.g. `api-service`, `web-app`).
- **Single repo:** `tech_context.repo_path` from packet or user path.
- Read `packet/PACKET.md` `security` block if present (`in_scope_services`, `threat_model_ref`, `audit_ref`).

### 2. Per-repo inventory (read-only)

For each repo, document:

1. **Stack** — language, framework, how it runs, bind address.
2. **Auth model** — route classes: public, session, Bearer, HMAC, webhook signatures; note “fail open if secret empty” patterns.
3. **Secrets** — `.env.example` fields; grep for `api_key`, `secret`, `password`, `token`, `bearer`, `sk-`, `AKIA` in source (report paths, never paste live values).
4. **HTTP surface** — API routes, CORS, uploads, admin/ops routes.
5. **Data stores** — DB, object storage, external APIs.
6. **Docker/infra** — compose ports, default creds.
7. **Existing security tests** — auth tests, HMAC tests, bandit/semgrep/npm audit scripts.
8. **CI** — `.github/workflows` security steps.

### 3. Classify findings

Assign each issue:

- **Severity:** `critical` | `high` | `medium` | `low` | `info`
- **Category:** `authz`, `authn`, `secrets`, `webhook`, `supply_chain`, `data_exposure`, `rate_limit`, `headers`, `infra`, `multi_tenant`, `other`
- **Stable id:** `<REPO>-NNN` (e.g. `WEB-APP-001`)
- **`test_hint`:** e.g. “pytest: POST without HMAC returns 401”, “vitest: admin route requires Clerk session”

### 4. Dependency audit (when tools available)

| Stack | Command |
|-------|---------|
| Node | `npm audit --audit-level=moderate` from repo root |
| Python | `pip-audit` or `uv pip audit` against lock/requirements |

Record in JSON `dependency_audit[]` with `status: not_run` if tooling missing — do not block the audit.

### 5. Cross-cutting themes + planning priorities

Synthesize ecosystem patterns (shared webhook secret, multiple services writing one database, no CI scanning). Fill `planning_priorities[]` with **P0–P2** items: title, repos, `suggested_slices[]`, `suggested_tests[]`.

### 6. Write planning-brief.md

Template sections:

```markdown
# Security planning brief — <scope>

## Start here
- Audit JSON: scratch/security-audit/audit-<date>.json
- Packet security block: (path or “none”)

## P0 (ship blockers)
- ...

## Suggested slices (vertical)
1. ...

## Suggested security tests (tests-first)
- ...

## Out of scope this round
- ...
```

### 7. Emit run-result (optional)

If run from a build orchestrator cycle, write `scratch/run-results/security-audit-<YYYYMMDD>.json`:

```json
{
  "kind": "review",
  "id": "security-audit",
  "timestamp": "<iso>",
  "status": "success",
  "summary": "Ecosystem audit: N critical, M high",
  "security_audit_path": "scratch/security-audit/audit-<date>.json"
}
```

## Explicit non-goals

- No fixing vulnerabilities in this skill (use TDD / dispatch after plan approval).
- No committing secrets or copying `.env` contents into artifacts.
- No force-pushing or changing git config.

## Token discipline

- Fan out **one `explore` subagent per repo** for large ecosystems; merge into one JSON.
- Grep for patterns; do not read every file line-by-line.

## Related

- Packet `security` + `verification.layers` security ids — [`packet/schema.json`](../../packet/schema.json)
- Gate after fixes — [`security-acceptance`](./security-acceptance/SKILL.md)
- Integration gate — [`e2e-acceptance`](../e2e-acceptance/SKILL.md) (calls security-acceptance when packet requires it)

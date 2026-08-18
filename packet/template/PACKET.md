---
name: my-project
one_liner: One sentence describing what we're building.
owner: your-name
deadline: YYYY-MM-DD or "none"

goals:
  - First thing done looks like
  - Second thing done looks like

out_of_scope:
  - Explicitly not building this round
  - Or this

success_criteria:
  - id: SC-1
    description: A measurable, testable criterion. The orchestrator will write a failing test for this.
    measurable: true
  - id: SC-2
    description: Another measurable criterion.
    measurable: true

constraints:
  stack:
    - e.g. Next.js 15 App Router
    - e.g. Postgres 16 + Drizzle
  deployment: e.g. Vercel
  performance: e.g. LCP < 2.5s, p95 API latency < 200ms
  deadline: same as top-level deadline or scoped

tech_context:
  repo_path: /absolute/path/to/the/repo
  primary_language: typescript
  key_libs:
    - react
    - drizzle
    - tailwind
  conventions_doc: docs/CONVENTIONS.md  # optional, relative to repo

open_questions:
  - Things you already know are ambiguous
  - The orchestrator will surface more during intake

refs:
  - path: refs/spec-from-stakeholder.pdf
    note: Original spec from the stakeholder
  - path: refs/competitor-screenshot.png
    note: Reference visual

# Optional: committed Playwright E2E + hybrid acceptance (orchestrator runs CLI, then browser MCP).
# Omit for non-web or API-only builds.
e2e:
  spec_dir: e2e
  commands:
    dev: pnpm dev
    test: pnpm exec playwright test
  base_url_env: PLAYWRIGHT_BASE_URL
  default_base_url: http://127.0.0.1:3000
  journeys:
    - success_criterion_id: SC-1
      summary: Core happy path a user can complete
      spec_paths:
        - e2e/happy-path.spec.ts
      operator_only: false

# Optional: multi-layer verification (full-stack). Playwright/`e2e` = UI only; put API, Docker stack, contracts, agentic QA here.
verification:
  layers:
    - id: ui_e2e
      summary: User flows in browser (Playwright / MCP)
      test_command: pnpm exec playwright test
      tools: [playwright]
    - id: api_e2e
      summary: HTTP API flows — auth, validation, DB, errors (pytest + httpx / FastAPI TestClient; no browser)
      test_command: pytest tests/api -v
      tools: [pytest, httpx]
    - id: integration
      summary: Service + Postgres/Redis/workers/mocks (often Docker Compose)
      test_command: docker compose -f docker-compose.test.yml up -d && pytest tests/integration -v
      tools: [docker, pytest]
    - id: contract
      summary: OpenAPI / Pydantic shape checks across service boundaries
      test_command: python scripts/check_openapi.py
      tools: [pydantic]
    - id: agentic_qa
      summary: Orchestrator-led QA — exercise APIs, read logs, add failing tests (see docs_or_prompt_ref)
      operator_only: false
      docs_or_prompt_ref: docs/agentic-qa-prompt.md
      tools: [pytest, ruff, mypy, curl, docker, psql, redis-cli]
    - id: dependency_audit
      summary: Supply-chain — npm audit or pip-audit; fail on unmitigated high/critical
      test_command: npm audit --audit-level=high
      tools: [npm, pip-audit]
    - id: authz_review
      summary: Route/auth matrix vs packet; orchestrator-led, file pytest/vitest regressions per finding
      docs_or_prompt_ref: scratch/security-audit/planning-brief.md
      tools: [pytest, vitest, curl]

# Optional: security program metadata (automated checks use verification.layers above)
security:
  threat_model_ref: docs/threat-model.md
  audit_ref: scratch/security-audit/audit-YYYYMMDD.json
  acceptance_required: true
  block_ship_on: [critical, high]
---

# {{ name }} — Project Packet

## Background

A few paragraphs of context. Why are we building this? What was the trigger? Who is the user?

Keep it tight. If it's longer than three paragraphs, move some to `refs/`.

## Detailed goals

Expand each bullet from the front-matter `goals` list with one paragraph of detail. Be concrete about what success looks like for the user, not for the engineer.

## Detailed success criteria

Expand each `success_criteria` entry. For each, note:

- The user-visible behavior
- The thing you'd point at to convince yourself it's working
- Edge cases that must hold

This is where the orchestrator's `tests-first` skill mines failing-test material.

If `e2e` is present in the front matter, align each critical journey with a `success_criterion_id` under `e2e.journeys` and list the Playwright file(s) that prove it. Mark third-party or inbox flows as `operator_only: true` so agents never fake a pass.

If `verification.layers` is present: treat **Playwright + browser MCP** as **UI depth only**. For FastAPI and other backends, rely on **pytest** (e.g. `TestClient`, [dependency overrides](https://fastapi.tiangolo.com/advanced/testing-dependencies/)), **API/scenario tests** (multi-step flows: create user → profile → job → worker → DB assertions), **integration** runs against Docker/local stack, **contract** checks on OpenAPI/Pydantic, and **agentic_qa** for orchestrator-led passes that convert findings into new tests — not on Playwright clicking the UI.

## Known unknowns

Things you know you don't know. The orchestrator will run a grilling pass during `packet-intake` to surface more.

## References

For each entry in `refs`, drop a sentence here pointing the orchestrator at it.

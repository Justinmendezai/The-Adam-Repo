---
name: e2e-acceptance
description: Final end-to-end acceptance pass after all slices are merged: full tests-first suite, Playwright CLI when the packet defines `e2e`, extra **`verification.layers` commands** (API/integration/contract), code-review-graph integrity, and browser MCP walks for UI success criteria — without using Playwright for backend depth. Use right before declaring the build done, or before a release.
---

# e2e-acceptance

The build's final gate. Composes [`review-via-graph`](../review-via-graph/SKILL.md) and [`review-runtime`](../review-runtime/SKILL.md) patterns, but at the *integration* level — the merged `main`, not a single slice's branch.

- **UI / browser:** When `packet/PACKET.md` includes `e2e`, runs the **Playwright CLI** before browser MCP walks. **Playwright MCP is for UI depth only** — it does not replace FastAPI/pytest/API/scenario coverage.
- **Backend / services:** When the packet includes `verification.layers`, run **api_e2e**, **integration**, and **contract** commands as listed (pytest, Docker stack, OpenAPI checks). **`agentic_qa`** is an orchestrator-led pass using the tools in the packet (pytest, curl, docker, DB CLIs, log readers) — do **not** open a browser unless a scenario truly requires it; convert confirmed bugs into **pytest** tests.

## When to use

- All slices have merged to `main` (or the project's integration branch).
- All per-slice reviews are `passing`.
- Right before you declare the project done or hand off to the user.

Not a substitute for per-slice review. This catches integration bugs, not slice-local ones.

## Reviewer contract

Every finding raised in this pass (graph review in step 3, `agentic_qa` in 2c, success-criteria walks in step 4) is held to the same contract as [`review-via-graph`](../review-via-graph/SKILL.md). Restated for the integration level:

- **Pre-report gate (all four "yes"):** cite the exact `file:line`; name the concrete failure mode (input, state, bad outcome); check callers/importers/tests; defensible severity. A `critical` finding must also explain why existing guards (types, validation, the suite) do not catch it.
- **Skip the noise:** framework-handled error paths, validation on internal callers that are already validated, "function too long" for switches/config/test tables, and stylistic preferences that do not violate `plan/CONTEXT.md`. Pre-existing issues outside this build go to `scratch/review-debt.md`, not the acceptance report.
- **Zero findings is valid.** A clean integration gets `approve`. Do not manufacture findings to look rigorous.
- **Verdict vocabulary** (the machine-readable gate the run-result carries): `approve` (no `critical`/`warning`), `warning` (warnings only), `block` (one or more `critical`). The report's **Recommendation** line maps directly: `approve` → `Ship`, `warning` → `Ship` or `Hold` at operator discretion, `block` → `Hold for fixes` or `Escalate`.

## Workflow

### 1. Confirm the integration branch is clean

```bash
git status
git fetch
git log --oneline main..origin/main
```

No uncommitted changes; in sync with origin (if remote exists).

### 2. Run the full automated test suites

#### 2a. Unit and integration tests

The whole `tests/` tree, not just one slice's. Confirm green. If anything is red, find which slice introduced the regression — usually the most recently merged one — and dispatch a follow-up.

#### 2b. Playwright E2E (when `packet/PACKET.md` defines `e2e.commands.test`)

From `tech_context.repo_path` (the project root):

1. Start the dev server yourself if Playwright config does not (`webServer` block). Background shell + `Await` on ready line — same pattern as [`review-runtime`](../review-runtime/SKILL.md). Then ensure the app is reachable using `e2e.base_url_env` and/or `e2e.default_base_url`.
2. Run `e2e.commands.test` exactly as written in the packet. Record the command string on the acceptance report and in `scratch/run-results/e2e-<YYYYMMDD>.json` as `e2e_command`.
3. Roll pass/fail/skip counts into the `tests` object. If the project emits an HTML report or `test-results/` dir, set `playwright_report_path` on the run-result.

If this step fails, the build does not pass `e2e-acceptance` — fix or escalate before spending tokens on MCP walks.

Skip 2b entirely when the packet has no `e2e` block (API-only or test layout without Playwright).

#### 2c. Packet `verification.layers` (full-stack)

When `packet/PACKET.md` defines `verification.layers`:

1. Keep a set of **shell command strings already executed** in 2a and 2b (unit runner, Playwright, etc.).
2. For each layer **in order**:
   - If `operator_only` is true → do **not** run automated; list under **Outstanding manual checks** with `docs_or_prompt_ref` or a concrete command for the operator.
   - If `id` is **`agentic_qa`** → perform an orchestrator-led QA pass: read `docs_or_prompt_ref` if present; exercise **HTTP APIs** (curl/httpie, pytest), **inspect logs**, run **lint/typecheck** (`ruff`, `mypy`) if listed under `tools`; cover auth, invalid payloads, ownership, idempotency, webhooks, DB constraint failures, and downstream timeouts/mocks per the project's critical paths. **Do not use the browser** unless a check is UI-only. Record findings in the acceptance report; add **pytest** regressions for each confirmed defect. If the layer defines `test_command`, run it **once** and fold the result into the report.
   - Else if `test_command` is non-empty and **not** already in the executed set → run it from `tech_context.repo_path`, append to executed set, record pass/fail. If it fails, gate fails like 2b.
   - If `id` is **`ui_e2e`** and the command matches what you already ran in 2b, skip the duplicate.

If the packet has no `verification` block, skip 2c.

#### 2d. Security acceptance (when `packet/PACKET.md` has `security.acceptance_required: true`)

Run [`security-acceptance`](../security-acceptance/SKILL.md) **before** declaring e2e-acceptance complete. If it fails, the overall gate fails.

If `security` is absent or `acceptance_required` is false, skip 2d.

### 3. Graph-level integrity

Use `code-review-graph` MCP across the full diff `main..<starting-point>`. Look for:
- Orphan exports introduced anywhere.
- Cycles introduced anywhere.
- Public type shape changes (potential consumer breaks if this is a library).
- Layering violations against the architecture in `plan/plan.md`.

### 4. Walk every PACKET.md success criterion

Open `packet/PACKET.md` (or, for issue-tracker-backed projects, the closed-issue list for this build) and walk `success_criteria` one by one. Split the walk into two passes — the orchestrator can always do the first, the operator owns the second.

#### 4a. Browser MCP + evidence (always for automatable SCs)

Resolve the **browser MCP** the same way as [`review-runtime`](../review-runtime/SKILL.md) (**Browser MCP** section): read `.cursor/adam.json`, honor `browser_mcp` if set, else prefer `playwright` / ids containing `playwright`, else `cursor-ide-browser`.

For each success criterion:

- **Mapping:** If `e2e.journeys` exists, find the journey with matching `success_criterion_id`. Note `spec_paths` and `operator_only`.
- **Operator-only:** If `operator_only` is true (or the SC clearly needs live accounts per 4b), do **not** mark it passed from automation. List it under `Outstanding manual checks` with a concrete click-path or command.
- **Tests:** List the unit/integration test files that prove the SC (from earlier steps). Confirm they stayed green in step 2a.
- **Playwright:** When `spec_paths` are set, name those files in the acceptance report and confirm they passed in step 2b.
- **MCP walk:** For user-visible behavior that can run against the local dev server (public pages, redirects, empty-states, error responses, auth gates), walk it with the **browser MCP**. Save screenshots under `scratch/e2e-mcp/<YYYYMMDD>/` and reference them in the report as evidence per SC id (`SC-1: passed`, evidence: `scratch/e2e-mcp/...png`, Playwright: `e2e/foo.spec.ts`). **Do not substitute MCP UI walks for API/scenario coverage** — backend truth lives in pytest/tests from `verification.layers` and `tests/`.

#### 4b. Operator-owned end-to-end (list, do not attempt)

Things that require the operator's own accounts or live infrastructure (Stripe webhook forwarding via `stripe listen`, GA4 DebugView spot-checks, Resend or SendGrid deliverability into a real inbox, AWS credentials, paid third-party APIs, seeded production-like data, etc.):

- Do **not** attempt these. Faking credentials or skipping them silently produces a misleading "passed" verdict.
- List each one in the acceptance report under an explicit `Outstanding manual checks` section, with the exact command or click-path the operator should run.
- Mark the SC as `pending operator verification`, not `passed`.

The **Recommendation** line in the report must reflect this distinction: an overall `Ship` is allowed if every automated SC passed and the only outstanding work is operator-owned verification that the operator has accepted as their responsibility (typically per their handoff prompt).

### 5. Performance, if applicable

If `PACKET.md` `constraints.performance` is set, run a representative profile (`browser_profile_start` / `browser_profile_stop` when available on your browser MCP, or use `chrome-devtools` if it is the only tool with profiling) against the merged build. Compare against the budget.

### 6. Write the acceptance report

`scratch/e2e-acceptance.md`:

```markdown
# E2E Acceptance — <project name>

- Date: YYYY-MM-DD
- Integration branch: main @ <sha>

## Test suite
- Unit/integration: N tests, M files, all passing.
- Playwright CLI: `<e2e.commands.test or "n/a">` — passed | failed (counts: …) | skipped (no `e2e` in packet)

## Verification layers (from packet)
- ui_e2e: <command> — passed | failed | skipped | n/a
- api_e2e: …
- integration: …
- contract: …
- agentic_qa: <summary of pass / issues filed as tests>

## Playwright / packet mapping
- SC-1 → spec: `e2e/...` → CLI: passed | failed | n/a
- SC-2 → ...

## Graph review
- Findings: ...

## Success criteria
- SC-1: <description> — passed | failed | pending operator verification | escalate
  - Evidence: <screenshot paths under scratch/e2e-mcp/…>, <test files>, <Playwright spec_paths>
- SC-2: ...

## Performance
- LCP: x ms (budget: y) — passing
- ...

## Outstanding manual checks (operator-owned)
- <SC id>: <exact command or click-path the operator must run, and what "passed" looks like>
- ...

## Outstanding debt
- (from scratch/review-debt.md)

## Recommendation
- Ship | Hold for fixes | Escalate
```

### 7. Write the structured run-result

In addition to the human-readable report, write `scratch/run-results/e2e-<YYYYMMDD>.json` matching [`schemas/run-result.schema.json`](../../schemas/run-result.schema.json):

- `kind: "e2e"`
- `id: <project name>`
- `status: "success" | "fail" | "partial" | "escalate"`
- `tests` block with roll-up pass/fail/skip counts from steps 2a, 2b, and 2c where applicable
- `e2e_command` when step 2b ran; `playwright_report_path` when a report path is known
- `verification_layers` summarizing each layer from step 2c (`id`, `command`, `status`: passed | failed | skipped | manual)
- `review_findings` rolled up from the per-slice reviews and the integration-level graph review, each filtered through the reviewer contract
- `verdict` — `approve` | `warning` | `block`, derived from the surviving findings (see Reviewer contract). This is the gate the orchestrator reads; it must agree with the report's Recommendation line.
- `summary` matching the report's recommendation line

### 8. Hand off

Write `scratch/taste-review.md` with screenshots and any `operator_only` items. Also fold in open rows from `agent-control/human-queue.md` (kind `taste`, `judgment`, `live-integration`). **If `verdict: block` (or Recommendation = Hold for fixes):** append one row to `agent-control/rework-ledger.md` (`stage=e2e`, one `class` from that file's taxonomy) before any fix dispatch — create from `~/adam/foundation/repo/agent-control/rework-ledger.md` if missing. If automated SCs passed and `verdict: approve`, treat the build as shipped — run [`context-primer`](../context-primer/SKILL.md) and [`session-steward`](../session-steward/SKILL.md). Do not block on operator reading the full report before closing the run.

## Output

`scratch/e2e-acceptance.md` (human-readable) and `scratch/run-results/e2e-<date>.json` (structured) exist with a clear ship/hold/escalate verdict. The user has the report.

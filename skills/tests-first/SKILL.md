---
name: tests-first
description: Write the failing test suite for every slice before any Composer 2 subagent touches code. The high-level agent owns the tests; subagents only make them green. Use after slice-to-tasks completes, or when asked to "write the failing tests" or "set up the red suite".
---

# tests-first

Strict TDD ownership. The high-level agent writes every test. Composer 2 subagents only write implementation that turns the tests green. Subagents must not modify test files.

This is the lever that lets the orchestrator review without reading every diff: if the tests pass and the test files weren't touched, the slice is meeting its contract by construction.

## When to use

- After `slice-to-tasks` produces `slices/<id>/SPEC.md` files.
- Or when adding a new slice mid-flight to an in-progress build.

## Workflow

### 1. Discover the test framework

Read `plan/CONTEXT.md` and the project's existing test setup. If you can't tell, dispatch a one-shot `explore` subagent: "What test framework, where do tests live, what's the run command?"

### 2. Per slice, write the failing tests

For each `slices/<id>/SPEC.md`:

- Read `acceptance` and `paths_in_scope`.
- Write tests under `tests/<id>/` (or wherever the project convention places them — match it).
- Cover each AC. One AC may map to one or several tests.
- Include test fixtures, sample data, and types as needed.
- Tests must compile (or parse) but fail with a meaningful message — not crash on missing imports.

If a function/module the test calls doesn't exist yet, write a stub in `paths_in_scope` that throws `new Error("not implemented")`. The stub plus the test together produce a clean red.

### 2b. Playwright E2E (when `packet/PACKET.md` defines `e2e`)

If the packet includes an `e2e` block with `spec_dir` and `commands.test`:

- For **web** slices with user-visible ACs, add Playwright specs under `e2e.spec_dir` (typically `e2e/`) that assert the same outcomes as the ACs at the browser level — in addition to, not instead of, `tests/<id>/` unit/integration coverage.
- Prefer one spec file per slice or per journey; align paths with `e2e.journeys[].spec_paths` when the packet lists them.
- Subagents must still **not** modify these files; if needed, list them under `paths_out_of_scope` in `slices/<id>/SPEC.md` beside the unit test paths.

Skip this subsection for API-only or non-browser builds (omit `e2e` in the packet for those).

### 2c. API, integration, and scenario tests (when `packet/PACKET.md` defines `verification` or backend slices)

**Do not use Playwright for FastAPI/service depth** — the browser only *indirectly* hits HTTP from the UI.

- **`api_e2e`:** Failing tests with **pytest** + **httpx** or FastAPI **`TestClient`**; cover real endpoint flows, auth, validation, DB writes/rollbacks, error bodies, and ownership rules. Prefer **[dependency overrides](https://fastapi.tiangolo.com/advanced/testing-dependencies/)** for swaps of auth, billing, queues, and third parties.
- **`integration`:** Longer **scenario tests** against **Docker Compose** or a local dev stack (API + Postgres + Redis + workers + job-queue mocks, etc.): multi-step flows (e.g. create user → profile → enqueue job → worker → DB row → publish).
- **`contract`:** Pydantic / OpenAPI shape checks so consumers still see the expected response schemas.

List the repo paths of new tests in `slices/<id>/SPEC.md` so subagents stay out of test files. Align **commands** with `verification.layers[].test_command` when the packet sets them.

### 3. Verify it actually runs red

Run the test command. Confirm:
- Tests are picked up.
- They fail (not error out from missing imports).
- Failure messages reference the AC they prove.

If the packet defines `e2e.commands.test`, run that command as well (with `e2e.base_url_env` / `e2e.default_base_url` and a running app per the project's Playwright config). New Playwright specs must fail for the right reason, not from misconfiguration.

For **`verification.layers`** with `test_command` (api_e2e, integration, contract), run those commands too if they are distinct from the unit test runner — new tests must fail for the right reason.

If you can't run the tests yourself in the current shell, dispatch a `shell` subagent to run them — **never** ask the operator to paste output unless the test requires credentials you cannot access.

### 4. Mark the slice ready for dispatch

Edit `slices/README.md` to flip the slice's status from `tests pending` to `ready to dispatch`.

## Test quality bar

- **One reason to fail per test.** When a test fails, the reason should be obvious from the assertion.
- **No mocking the thing under test.** Mock external deps if needed. Never mock the function the test is supposed to prove.
- **Behavior, not implementation.** Test the user-visible outcome, not the internal call shape.
- **Edge cases get their own tests.** Don't bury edge cases in a kitchen-sink test.
- **Naming**: `it("returns the canonical slug when given mixed case")` beats `it("works")`.

## Anti-patterns

- Writing tests that pass before any implementation. The first run must be red.
- Tests that depend on shared mutable state across runs.
- Tests that the subagent could trivially satisfy by changing the test rather than the implementation. Add `paths_out_of_scope` covering the test files in the slice spec to defend against this.
- Vague assertions (`expect(result).toBeTruthy()`). Be specific.

## Subagent contract reminder

When `dispatch-builder` runs, the subagent's prompt **explicitly forbids modifying test files**. The completion signal `<adam>COMPLETE</adam>` requires the test suite to be green AND the test files unchanged.

## Output

`tests/<id>/` is populated and red for every slice. When the packet defines `e2e`, `e2e.spec_dir` holds red Playwright specs aligned with `e2e.journeys`. When the packet defines `verification`, pytest/API/integration/contract tests exist under the paths declared in each slice SPEC (and fail red until implementation lands). `slices/README.md` shows each slice as `ready to dispatch`.

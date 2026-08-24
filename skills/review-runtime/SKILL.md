---
name: review-runtime
description: Runtime acceptance check for a slice using the project browser MCP (Playwright MCP or cursor-ide-browser) and logger MCPs. Spin up the dev server, optionally run slice-scoped Playwright CLI tests from the packet, drive the UI, capture logs, validate ACs against actual behavior. Use after review-via-graph passes, or for any slice with user-facing behavior.
---

# review-runtime

Tests prove the contract. Runtime review proves the experience. The orchestrator drives the app via the **browser MCP** configured for the project (see **Browser MCP** below) and inspects logs via the logger MCPs, checking that the slice's user-visible ACs hold against the real running thing.

## When to use

- After [`review-via-graph`](../review-via-graph/SKILL.md) passes.
- For any slice with a user-facing behavior in its ACs.
- Skip for purely internal slices (lib refactor, infra) — `review-via-graph` is enough there.

## Inputs

- A slice on its branch (`adam/<slice-id>`).
- The project's dev server start command (in `plan/CONTEXT.md`, or `packet/PACKET.md` `e2e.commands.dev` when present).
- A list of user-visible ACs from `slices/<id>/SPEC.md`.

## Browser MCP

Read `adam.json` in the project repo.

1. If `browser_mcp` is set (for example `"playwright"` or `"cursor-ide-browser"`), use that server's tools for `browser_navigate`, `browser_snapshot`, `browser_click`, etc.
2. Otherwise, pick the first entry in `review_mcps` that names a browser driver: prefer `playwright` or any id containing `playwright` (some workspaces use `user-playwright`), else `cursor-ide-browser`.

Use the same server for the whole review. Log which server key was used in `review_findings` / `notes` with `source` set to `playwright` or `cursor-ide-browser` as appropriate.

## Workflow

### 1. Bring up the app on the slice's branch

Either:
- Switch to the branch in the main worktree (only if the orchestrator's own work is committed), OR
- Use the slice's `best-of-n-runner` worktree directly (preferred — it's already there).

Start the dev server in a background shell, then `Await` a ready line before driving the UI:

```
Shell(command="<dev command>", block_until_ms=0, description="Start dev server for review")
Await(task_id=<id>, pattern="Local:|listening|Ready in", block_until_ms=120000)
```

Capture the URL from the ready line. If `Await` times out, read terminal output, fix, retry — do not ask the operator to start the server.

### 2. Slice-scoped Playwright CLI (optional, when the packet defines `e2e`)

If `packet/PACKET.md` has `e2e.commands.test` **and** `slices/<id>/SPEC.md` lists Playwright files under **Playwright E2E**, run only those paths — for example `pnpm exec playwright test e2e/foo.spec.ts` — not the whole suite. This is optional smoke before the MCP walk; skip if no paths are listed (the full suite is `e2e-acceptance`'s job).

If the command fails, stop and send the slice back for fixes rather than masking with UI clicks.

### 3. Drive the app

Use the **browser MCP** tools (snapshot → action → snapshot). For each user-visible AC:

- Navigate to the relevant page.
- Take a snapshot. Verify the rendered state matches the AC.
- If the AC involves an action (form submit, button click), perform it.
- Take a follow-up snapshot. Verify the post-action state.

Take a screenshot at each verification step for the audit trail. Save to `scratch/runtime-review/<slice-id>/`.

### 4. Inspect logs

After driving, fetch the dev server logs (from the relevant logger MCP) for the time window of the run. Check:
- No `error`-level messages emitted during normal flows.
- Expected `info` messages did fire (auth, persistence, etc.).
- No deprecation warnings introduced by this slice.

### 5. Performance sanity (optional, for slices with perf budgets in PACKET.md `constraints.performance`)

Run `browser_profile_start` → drive a representative interaction → `browser_profile_stop`. Read the summary. Compare against the budget. If exceeded, log under `## Review notes` in `SPEC.md` and escalate.

### 6. Decide

- All ACs visually verified, no error logs, perf within budget → mark slice `result.review` as `passing`. Ready to merge.
- Any AC fails visually → describe the failure in `SPEC.md` `## Review notes`, append one row to `agent-control/rework-ledger.md` (`stage=runtime-review`, one `class` from that file's taxonomy, `system_fix=none` unless patched this turn), then dispatch a focused follow-up via `dispatch-builder`.
- Any error in logs → triage. If it's caused by this slice, append a rework-ledger row (same stage) then fix it. If it's pre-existing, log to `scratch/review-debt.md`.

### 7. Append to run-result

Append `review_findings` (with `source: "log-reader-mcp"`, `"chrome-devtools"`, **`"playwright"`**, or **`"cursor-ide-browser"`**) to `scratch/run-results/<slice-id>.json` or a sibling `kind: "review"` file. Reference any saved screenshots or profile dumps under `scratch/review-evidence/<slice-id>/` in the `notes` array.

## Anti-patterns

- Long click loops without snapshots between actions. Each action invalidates the prior snapshot's refs — re-snapshot.
- Hand-driving in real Chrome. Use the MCP — it produces structured output you can reason over without screenshots in your context.
- Running the **full** Playwright suite here. Use only slice-listed spec paths for a quick smoke, or defer the full `e2e.commands.test` run to `e2e-acceptance`.

## Output

`SPEC.md` `## Review notes` block updated. Screenshots saved under `scratch/runtime-review/<slice-id>/`. Slice marked `passing` or sent back for a fix.

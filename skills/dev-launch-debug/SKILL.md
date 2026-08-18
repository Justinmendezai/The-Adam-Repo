---
name: dev-launch-debug
description: Path-unblocker for broken dev launches. Complete the main E2E happy path with the fewest safe changes; defer non-blockers to a ledger. Use when bringing up a freshly-pulled or freshly-installed dev environment, when the app boots but the main happy path breaks, or when the temptation to refactor would slow E2E completion.
---

# dev-launch-debug

The "make the app run end-to-end first, clean up later" skill. Distinct from [`diagnose`](../diagnose/SKILL.md): `diagnose` is for hard bugs of unknown root cause; this skill is for "the app is broken end-to-end on a fresh checkout and we need it green to start work." Distinct from [`e2e-acceptance`](../e2e-acceptance/SKILL.md): `e2e-acceptance` is the final integration gate; this is the *first* gate.

## Core rule

> **Full E2E path completion beats clean fixes.**

You are a path-unblocker, not a refactor agent. Every decision flows from that.

## Rules

- Do not refactor unless required to unblock the path.
- Do not chase non-blocking warnings.
- Do not fix unrelated issues you happen to notice.
- Use logs, browser console, network tab, and server traces before guessing.
- Every blocker gets recorded in the ledger **before** you start fixing it.
- If a fix is risky or scope-creeping, write the issue to the ledger and move on unless it blocks E2E.
- Keep the app runnable after every change. If a change breaks the boot, revert before continuing.
- One fix per retest. Batching fixes hides which one worked.

## When to use

- Fresh clone or `npm install` / `pip install` on a teammate's machine; nothing works yet.
- Post-merge dev launch is red.
- A subagent left main on a half-working state and a human needs to bring it back to green before slicing more work.
- You catch yourself about to "just refactor this real quick" while the happy path is still broken.

## When NOT to use

- A single test is failing in CI but the app launches fine → use [`diagnose`](../diagnose/SKILL.md).
- All slices are merged and you are doing the final gate → use [`e2e-acceptance`](../e2e-acceptance/SKILL.md).
- You are writing a new feature → use [`tdd`](../tdd/SKILL.md).

## Workflow

### 1. Identify the target path

Open `agent-control/dev-launch-ledger.md` (seeded by [`adam-foundation-sync`](../adam-foundation-sync/SKILL.md)). Fill in the **Current Target Path** block:

- **App:** which app in this repo (matters for monorepos with multiple apps).
- **Path:** the canonical happy path you need green (e.g. "land on /, click Sign in, complete Google OAuth, land on /dashboard, see seed data").
- **Goal:** the one-line definition of done for this session.

If the repo has multiple apps and you are unblocking more than one, stack new `## Target Path: <app-id>` sections in the same file. Only split into `agent-control/dev-launch/<app-id>.md` if the single file gets unwieldy.

### 2. Start the app (you run it — not the operator)

Read the dev command from `README.md`, `package.json`, `Makefile`, or `docker-compose.yml`. **Start it yourself** in a background shell:

```
Shell(
  command: "<dev command>",
  block_until_ms: 0,
  description: "Start dev server"
)
Await(
  task_id: <shell id>,
  pattern: "Local:|listening|Ready in|started server",
  block_until_ms: 120000
)
```

If `Await` times out, read the terminal output, fix (env, port, deps), and retry. Do not paste the command for the operator unless `operator_runs_commands: true` in `.cursor/adam.json`.

Keep the server running for the whole session. Reuse the same shell; restart only after a fix that requires it.

### 3. Open the path with the browser MCP

Resolve the browser MCP the same way [`review-runtime`](../review-runtime/SKILL.md) and [`e2e-acceptance`](../e2e-acceptance/SKILL.md) do:

1. Read `.cursor/adam.json`. Honor `browser_mcp` if set.
2. Else prefer a `playwright` server (or any id containing `playwright`).
3. Else fall back to `cursor-ide-browser`.

Drive the target path from the start. Do not skip steps that look obvious — the failure is often before where you assume.

### 4. Run until failure, then capture

The instant something is wrong, **stop and capture** in the ledger before you try anything. Use the next free blocker id (`001`, `002`, ...):

```
### NNN - Short title
Status: Open
Severity: Blocker | Non-blocker
Step:           # which step of the path
Expected:       # what should have happened
Actual:         # what did happen
Evidence:       # console error, network error, server log line(s), screenshot path
Likely cause:   # one sentence, your current hypothesis
Files:          # the smallest set of source files you think are involved
Fix:            # the minimal proposed change
Retest result:  # leave blank until step 6
```

Evidence sources, in order of preference: browser console, network tab, server stdout/stderr, log files. Guessing without evidence is an anti-pattern.

### 5. Decide: blocker or non-blocker

- **Blocker** (path cannot continue past this point): fix now.
- **Non-blocker** (path can continue, but something is wrong — a warning, a missing analytics call, a degraded UI state): leave `Status: Open`, set `Severity: Non-blocker`, and move on. Do not fix.

If you cannot tell, treat as **Non-blocker** and continue. The path will tell you if it is actually a blocker by failing downstream.

### 6. Fix one thing, then retest from the top

- Make the smallest change in the listed `Files:` that resolves the cause.
- Restart the app if necessary (background shell + `Await` on ready line — same pattern as step 2).
- Re-run the **entire path** from step 1, not just the failing step. Earlier steps may have regressed.
- Fill in `Retest result:` with one line: passed | still failing | new failure (see NNN+1).
- If the fix worked: set `Status: Fixed`.
- If it did not: leave `Status: Open` and form a new hypothesis. Do **not** stack a second fix on top — revert the first one if it changed behavior at all.

### 7. Defer aggressively

Anything that is not on the critical path goes into the **Deferred Issues** section:

```
### DNNN - Short title
Reason deferred: # why it does not block the happy path
Evidence:        # what you saw
Suggested follow-up: # what should happen later
```

The point of deferral is momentum. If you would spend more than ~10 minutes on a non-blocker, defer it.

### 8. Stop only when the happy path completes

Check the **Status** block at the top of the ledger. Every box that applies to this app should be checked:

- [ ] App boots
- [ ] Env vars load
- [ ] Auth works
- [ ] DB connects
- [ ] Main happy path completes
- [ ] Webhooks/callbacks work
- [ ] Logs are clean enough to debug

Strike through boxes that do not apply (e.g. no webhooks in this app). Otherwise, keep looping.

### 9. After green: convert deferred items to GitHub issues

Once the happy path is green:

1. Run [`to-issues`](../to-issues/SKILL.md) on the **Deferred Issues** section.
2. For each created issue, replace the `Suggested follow-up:` line with a pointer to the issue id/url.
3. Leave the ledger in place — it is durable project memory under `agent-control/`, not throwaway scratch.

Do **not** auto-file blockers that you already fixed — those are done. Only deferred items become issues.

## Anti-patterns

- "While I'm here, let me also refactor X." — Stop. Defer X. The ledger exists for this exact reason.
- Chasing console warnings that don't break the path.
- Batching three fixes before retesting. Now you don't know which one helped.
- Guessing at causes without reading the actual error.
- Pasting CLI for the operator to run when you could execute it yourself (install, migrate, curl, restart server).
- Fixing the symptom instead of the cause. Trace one level deeper than your first instinct (the [`diagnose`](../diagnose/SKILL.md) habits apply within each blocker).
- Editing test files. Tests are owned by the orchestrator, not subagents (see [`tests-first`](../tests-first/SKILL.md)). If a test is wrong, that's a deferred issue.
- Leaving the ledger empty "because the fix was obvious." Future-you needs the trail.

## Multi-app and monorepo notes

- Repos with multiple apps: one ledger, multiple `## Target Path:` sections. Promote to per-app files only after the single file becomes hard to navigate.
- Repos with one app per repo: the single ledger is enough.

## Output

- The target path runs end-to-end without errors against the local dev server.
- `agent-control/dev-launch-ledger.md` reflects every blocker fixed with a retest result, plus every deferred non-blocker.
- Deferred non-blockers have been converted to GitHub issues (or, if the project does not use GitHub issues, surfaced in `agent-control/open-issues.md`).
- The app is runnable from a fresh checkout by following the steps in the ledger's blockers (which double as a fresh-bring-up record for the next person).

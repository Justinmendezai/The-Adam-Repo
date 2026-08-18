---
name: packet-intake
description: Validate a adam project packet, run a required upfront grilling pass with the operator, and produce intake notes. The grilling session is the front-loaded gate that makes the rest of the build autonomous. Use at the start of any adam run, when a user hands over a packet folder or PACKET.md, or when asked to "ingest the packet".
---

# packet-intake

The orchestrator's first move on every project. Validate the packet, **grill the operator until decisions are resolved**, write what you learned, then hand off to `research-and-plan`.

This is the **one required upfront session** with the operator. It front-loads judgment so the team can build without you for the rest of the run. **Do not grill mid-build** — no ambiguities during slice dispatch; those should have been resolved here.

Skip grilling only when `packet.orchestration.require_intake_grilling: false` or `.cursor/adam.json` has `"require_intake_grilling": false` (emergency/hotfix paths only).

## Inputs

- Path to a packet folder (default: `packet/` in the project repo) or a `PACKET.md`.
- The packet schema at `~/adam/packet/schema.json`.

## Steps

1. **Read PACKET.md frontmatter and validate against `schema.json`.**
   - Missing required keys → list them and stop until the operator provides them or explicitly defers in `open_questions`.
   - Empty `success_criteria` → blocking. We need testable outcomes.

2. **Walk `refs/`, `data/`, `schemas/`, `examples/` if present.**
   List every file. Note its path. Do not read large files yourself — log them for `research-and-plan` to dispatch a subagent against.

3. **Sanity check `tech_context.repo_path`.**
   - Does the path exist? Is it a git repo? On what branch?
   - Log dirty repo or feature-branch state in intake notes. Surface to operator during grilling if it affects scope.

4. **Surface ambiguities.** Read each goal and success criterion:
   - Could two engineers read this differently?
   - Is the user-visible behavior concrete?
   - Could you write a failing test for it today?

   For each ambiguity, draft a question. Do not invent answers — that's what grilling resolves.

5. **Required grilling pass.** Run [`grill-with-docs`](../grill-with-docs/SKILL.md) on the union of:
   - The packet's `open_questions`
   - Your discovered ambiguities

   Cap at ~10 questions per pass. If more remain, run a second pass until stop conditions in [`grill-me`](../grill-me/SKILL.md) are met or the operator says "good enough / ship it."

   Grilling output lands in `plan/CONTEXT.md` and `plan/adr/` (or `scratch/intake-notes.md` until research-and-plan folds it). **Do not proceed to `research-and-plan` with unresolved branching decisions.**

6. **Write `scratch/intake-notes.md`.** Sections:
   - Packet validation result
   - Discovered files in `refs/` etc.
   - Repo state
   - Ambiguities and answers (**verbatim**, with timestamps — from grilling)
   - Items deferred to `research-and-plan` (should be empty or explicitly accepted risks only)

7. **Hand off.** Proceed to `research-and-plan`. No second go/no-go on the plan unless `require_plan_approval` is set — grilling already happened.

## Anti-patterns

- Reading every file in `refs/` yourself. Log paths; let subagents do it.
- Skipping grilling to "move faster" — that pushes judgment into mid-build gates and defeats the autonomous loop.
- Grilling during slice dispatch or babysit (mid-run). Intake only.
- Answering ambiguities for the operator instead of asking.
- Starting to plan before intake + grilling is complete.
- **Editing anything under `packet/`. Hard rule.** Capture answers in `scratch/intake-notes.md`. See [`foundation/cursor/rules.md`](../../foundation/cursor/rules.md) "Packet rules".

## Run output

Write `scratch/run-results/intake.json` matching [`run-result.schema.json`](../../schemas/run-result.schema.json) with `kind: "intake"`, `id: <project-name>`, `status: "success" | "blocked"`, and a summary of validation result + questions resolved count.

## Output

`scratch/intake-notes.md` exists, schema validation passes, ambiguities resolved via grilling (or explicitly deferred with operator acceptance), repo state confirmed. Ready for `research-and-plan`.

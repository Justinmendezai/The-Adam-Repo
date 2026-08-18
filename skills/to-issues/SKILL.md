---
name: to-issues
description: Break a plan, spec, or PRD into independently grabbable issues using vertical slices. Issues are written either as GitHub issues, Linear tickets, or local files depending on project convention. Use after to-prd or research-and-plan, when scope is settled.
---

# to-issues

Adapted from [Matt Pocock's to-issues](https://github.com/mattpocock/skills). Cut a plan into work that another engineer (or another subagent) can pick up without asking you anything.

In a adam flow, you'd typically use [`slice-to-tasks`](../slice-to-tasks/SKILL.md) instead — it produces structured slice briefs for Composer 2 dispatch. Use `to-issues` when the work needs to flow through a real issue tracker (GitHub/Linear) or when humans are picking it up.

## Issue tracker selection

Check the project's convention:
- GitHub: `gh issue create`. Repo must be on GitHub.
- Linear: Linear MCP. Team and project ids needed.
- Local files: write to `docs/issues/<slug>.md`.

If unclear, ask the user which one.

## Vertical slicing rules

Same as [`slice-to-tasks`](../slice-to-tasks/SKILL.md):

- Each issue delivers one user-visible behavior or one well-bounded piece of infra.
- Each issue has explicit acceptance criteria, in-scope paths, out-of-scope paths.
- Issues declare their dependencies on each other.

## Issue template

```markdown
## Summary
One paragraph. What this delivers.

## Acceptance criteria
- AC-1: ...
- AC-2: ...

## Paths in scope
- ...

## Paths out of scope
- ...

## Depends on
- #<issue> or <none>

## Notes
Optional. Pointers to similar code, gotchas. Terse.
```

## Workflow

1. Read the source (PRD, plan, packet).
2. Draft issues in your head. Aim for 3–10. More is a sign of horizontal slicing.
3. Create the issues in the chosen tracker with the template below. **Default:** do not wait for operator approval on the list. Only pause for approval when `require_plan_approval: true`.
4. Record the issue numbers in the source doc (e.g. add a "Tracked in" section to the PRD).

## Anti-patterns

- Issues with vague acceptance ("make it work").
- Issues that span the entire codebase ("add caching everywhere").
- Issues with implicit deps. Always state `depends on`.
- Bulk-creating issues without a quick summary in `scratch/last-run.md` (operator can review at handoff, not mid-run).

## Output

Issues exist in the tracker. The source doc references them. Summary logged to `scratch/last-run.md`.

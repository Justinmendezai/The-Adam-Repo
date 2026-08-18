---
name: canvas-project
description: Render project status in a Cursor Canvas — sprint, slices, blockers, main vs branch state. Use for canvas project, visual status, or project diagram.
origin: adam
disable-model-invocation: true
---

# canvas-project

Visual status artifact for the product repo. Use Cursor **Canvas** (`.canvas.tsx`) when available.

## Inputs

- `plan/plan.md`
- `agent-control/slice-status.md`, `agent-control/active-sprint.md`
- Fresh `/repo-truth` optional

## Canvas content

1. **North star** — one line from packet goal
2. **Blockers** — operator queue + failing verifiers
3. **Slice lanes** — done / in progress / ready / blocked
4. **Git strip** — main SHA, active `adam/*` branches
5. **Next 5 actions**

Prefer cards or mermaid inside canvas — not a markdown wall.

## Workflow

1. Create `scratch/project-status.canvas.tsx` (or update existing).
2. Note audit date if repo-truth not run this session.
3. Tell user to open canvas beside chat.

## Not for

- Full council synthesis — link `council/runs/<id>/final-output.md`.
- Code-level architecture — use `/zoom-out` in implementation repos.

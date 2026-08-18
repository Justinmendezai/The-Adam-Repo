# Engineering Council (lite)

Markdown files for **pressure-testing a plan before you build**. Several reasoning-constrained perspectives independently read the same input; an orchestrator synthesizes consensus, divergence, risks, and opportunities.

## What's here

```
council/
  README.md           # this file
  runbook.md          # deterministic procedure
  perspectives/       # one prompt per reasoning constraint
  runs/               # one folder per pass (INPUT + perspectives + synthesis)
```

## Design rules

1. **Scaffolding is deterministic** — fixed output sections, mechanical synthesis aggregation.
2. **One pass, then stop** — no recursion, no re-litigation. New question → new run id.

## When to use

- New product or major feature after `research-and-plan` produced a draft plan
- Before `slice-to-tasks` when stakes are high or assumptions feel soft
- Optional — skip for small, well-understood slices

## How to run

See [`runbook.md`](runbook.md). Fan out one read-only subagent per perspective (different model families when possible), write raw outputs to `runs/<id>/perspectives/`, then `runs/<id>/synthesis.md`.

## Example

[`runs/00-demo-saas-checklist/`](runs/00-demo-saas-checklist/) — sample pass over a fictional todo-SaaS plan (teaching artifact only).

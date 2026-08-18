---
name: council
description: Run an engineering council pass — INPUT, seven perspectives, synthesis, final-output. Use for council run, run a council, perspectives pass, or council pass on a topic.
origin: adam
disable-model-invocation: true
---

# council

Planning Council per [`council/runbook.md`](../../council/runbook.md) + [`council/README.md`](../../council/README.md).

## When

Before `slice-to-tasks` when stakes are high or assumptions feel soft. Skip for small, well-understood work.

## Setup

1. Run id: `council/runs/<NN>-<slug>/`
2. `INPUT.md` — question, constraints, links to plan docs
3. Fan out **7 perspectives** from `council/perspectives/` (one subagent each; different model families when possible)
4. Raw → `runs/<id>/perspectives/<name>.md`
5. `synthesis.md` — mechanical aggregation per runbook
6. Terminal: `final-output.md`; operator questions → `answers.md`

## Default perspectives

`first-principles`, `executor`, `reliability-critic`, `cost-critic`, `expansionist`, `contrarian`, `outsider`

## Rules

- Deterministic scaffolding; LLM only inside perspective seats.
- **One pass** — no recursion.
- One voice (Adam) to operator unless they ask for raw seats.

## After

- Update `plan/plan.md` or `packet/PACKET.md` from terminal output.
- [`handoff-prompt`](../handoff-prompt/SKILL.md) if build follows.

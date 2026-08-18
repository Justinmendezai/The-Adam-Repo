# Human queue — batched final review

**Operator touchpoint list.** Items land here during autonomous runs instead of blocking mid-build. The operator works this file in **one session** at the end (UI/UX, taste, live creds, judgment calls).

The orchestrator and [`babysit-builders`](../../../skills/babysit-builders/SKILL.md) append rows; only the operator clears them.

## Status key

| status | meaning |
|---|---|
| `open` | needs operator action or judgment |
| `done` | operator completed; verifier re-run green if applicable |
| `deferred` | accepted as post-ship; tracked in `open-issues.md` |

## Queue

| id | slice_or_pod | kind | summary | command_or_path | status | notes |
|---|---|---|---|---|---|---|
| — | — | — | *(empty — items append during the run)* | — | — | — |

### kind values

- `live-integration` — real OAuth, DNS, prod creds (terminal `integration-live` slice)
- `taste` — UI/UX, copy, visual judgment
- `judgment` — SME call (parity sign-off, audit scorecard, etc.)
- `credentials` — paste secret / connect account the agent stubbed

## Rules

- **Do not block the build loop** waiting on rows in this queue. Independent slices keep dispatching.
- [`e2e-acceptance`](../../../skills/e2e-acceptance/SKILL.md) reads open `taste` and `judgment` rows and folds them into `scratch/taste-review.md`.
- [`session-steward`](../../../skills/session-steward/SKILL.md) rolls uncleared items into `next-orchestrator-brief.md` under **Operator queue**.

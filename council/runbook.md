# Council runbook

The deterministic procedure for running one council pass. The orchestrator (the high-level agent) owns this; the perspectives only fill the contract.

## Step 0 — Define the pass

- Pick an `id` (e.g. `01-synthesis-questions`) and create `runs/<id>/`.
- Write `runs/<id>/INPUT.md`: the exact list of docs fed to every perspective, the question the pass is answering, and the run date.
- Every perspective gets the **same** input. No perspective sees another perspective's output. No cross-talk.

## Step 1 — Fan out (one subagent per perspective)

Launch all perspectives in a single parallel batch (one message, N Task calls). Each subagent:

- Runs **read-only** (it only reads repo docs; it does not write files — the orchestrator writes the raw output).
- Is given: (a) its perspective prompt verbatim from `perspectives/<name>.md`, (b) the `INPUT.md` doc list, (c) the output contract below.
- Is assigned a model per the table so diversity is structural, not just prompt-deep.

| Perspective | Model | Reasoning constraint (one line) |
|---|---|---|
| Contrarian | `claude-opus-4-8-thinking-high` | Attack the dominant assumption; find where consensus is lazy. |
| First-Principles | `gpt-5.5-medium` | Rederive from base reality; ignore precedent and prior framing. |
| Expansionist | `claude-4.6-sonnet-medium-thinking` | Widen the surface; find orthogonal options and missing leverage. |
| Outsider | `gpt-5.3-codex` | Naive / cross-domain lens; question jargon and insider assumptions. |
| Executor | `composer-2.5-fast` | Operational realism; can this actually ship / be run / be maintained. |
| Cost critic | `gpt-5.5-medium` | Token / infra / operational cost, ROI, cheap-but-fragile tradeoffs. |
| Reliability critic | `claude-4.6-sonnet-medium-thinking` | Failure modes, brittleness, bottlenecks, scaling traps. |

If a requested model is unavailable, record the substitution in `INPUT.md` rather than silently swapping.

## Step 2 — Output contract (every perspective returns exactly these sections)

```
## Assumptions I see being made
## Where I agree with the obvious read
## Where I disagree / what tension I'm injecting
## Risks / failure modes
## Missing leverage / opportunities
## Open questions
```

Rules for the perspective:
- Stay in character as a **reasoning constraint**, not a persona. No preamble, no hedging about being an AI.
- Be specific and cite the input docs (file + section) when making a claim.
- Brevity over completeness: the most load-bearing 3-7 points per section, not an exhaustive list.
- Run 1 weights `Open questions` heaviest. Run 2 adds a one-line **Verdict + confidence (low/med/high)** at the top of the response.

The orchestrator writes each raw return verbatim to `runs/<id>/perspectives/<name>.md`.

## Step 3 — Synthesize (deterministic aggregation -> `runs/<id>/synthesis.md`)

Apply these rules mechanically over the seven raw outputs:

1. **Consensus** — a point raised by **>= 4 of 7** perspectives. List with the count.
2. **Divergence** — points where perspectives conflict. Name who holds which side. This is the highest-value section; do not smooth it over.
3. **Assumption-delta table** — assumptions the council surfaced vs. assumptions baked into the input docs. Columns: `Assumption | Baked into packet? | Challenged by | Status`.
4. **Risk register** — deduped union of `Risks / failure modes`, ranked by how many perspectives flagged it.
5. **Opportunity surface** — deduped union of `Missing leverage / opportunities`.
6. **Confidence label** — overall low/med/high on how solid the current plan looks given the spread of perspectives.
7. **Terminal output** — depends on the pass:
   - Run 1 (question pass): a deduped, **prioritized question list** for the operator, grouped by theme, each question tagged with which perspective(s) raised it.
   - Run 2 (eval pass): a structured **evaluation** of status / vision / roadmap with the verdict + confidence rollup.

Synthesis is aggregation, not a new opinion. The orchestrator does not add its own analysis here beyond deduping and counting; novel orchestrator judgment, if any, goes in a clearly labeled `Orchestrator note` block.

## Step 4 — Stop

One pass = one fan-out + one synthesis. No re-runs of the same input. If the synthesis exposes a new question worth a fresh pass, that is a *new* run with a new `id` and a new `INPUT.md`.

---
name: diagnose
description: Disciplined diagnosis loop for hard bugs and performance regressions. Reproduce, minimize, hypothesize, instrument, fix, write a regression test. Use when chasing a bug whose root cause isn't obvious, or when a perf regression appears.
---

# diagnose

Adapted from [Matt Pocock's diagnose](https://github.com/mattpocock/skills). Stops the "try random fixes" anti-pattern.

## The loop

```
1. REPRODUCE — get a reliable repro
2. MINIMIZE — strip the repro to the smallest case that still fails
3. HYPOTHESIZE — name a single concrete hypothesis
4. INSTRUMENT — add the cheapest probe that confirms or refutes it
5. CONFIRM — run; read the output; the hypothesis is true or false
6. FIX — change the smallest thing that resolves the cause
7. REGRESS — write a test that would have caught this
```

Each step has a clear pass/fail. If you skip ahead, you're guessing.

## REPRODUCE

You don't have a bug; you have a story about a bug. Convert the story to a script:

- A failing unit test, or
- A `curl` command that returns the wrong output, or
- A click sequence in `cursor-ide-browser` that yields the wrong screen.

If you can't reproduce, you can't diagnose. Time spent hunting a repro is never wasted.

## MINIMIZE

Now strip everything not necessary to the failure:
- Removing a dep — does it still fail?
- Removing a function call — does it still fail?
- Smaller input — does it still fail?

Stop when removing one more thing makes the bug disappear.

## HYPOTHESIZE

Write down **one** sentence: "The bug is caused by X." Not "It might be X or Y or Z." Pick one. The next step will prove or disprove it.

## INSTRUMENT

Add the cheapest probe:
- A `console.log` at the suspected branch.
- A breakpoint in the debugger.
- A query against the DB to check actual stored state.
- A network log via the logger MCP.

The probe should produce a one-line yes/no answer to the hypothesis. If it can't, simplify the hypothesis.

## CONFIRM

Run. Read. Either:
- The hypothesis is true → proceed to FIX.
- The hypothesis is false → form a new hypothesis. Do not skip back to a fix; re-enter HYPOTHESIZE.

## FIX

Smallest possible change. If you're tempted to "also fix" something else nearby, stop. Open a separate slice or note.

## REGRESS

Write the test that would have caught this. Run it. Confirm it goes green with your fix and red without it. Commit.

## Performance variant

Same loop, with profiling tools instead of logs:
- REPRODUCE: a script that reliably triggers the slow path.
- MINIMIZE: strip until you have the slow call alone.
- HYPOTHESIZE: "The hot spot is in function X." Prove with `browser_profile_start`/`browser_profile_stop` for browser, or platform-native tools for backend.
- FIX: smallest change.
- REGRESS: a perf test that fails when the budget is exceeded.

## Anti-patterns

- Trying multiple fixes at once. You won't know which one worked.
- Skipping MINIMIZE because the repro "already works". Tighter repros yield faster hypotheses.
- Fixing the symptom rather than the cause. Trace one level deeper than your first instinct.
- Calling the bug fixed without REGRESS. It will come back.

## Output

A green regression test that would have caught the original bug. A small fix. A short paragraph in the PR description naming the cause.

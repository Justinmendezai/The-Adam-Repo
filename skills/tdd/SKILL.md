---
name: tdd
description: Red-green-refactor TDD loop for direct work. Builds features or fixes bugs one vertical slice at a time. Use when the user asks for TDD, when a change has clear behavior to test, or when fixing a bug that should not regress.
---

# tdd

Adapted from [Matt Pocock's tdd](https://github.com/mattpocock/skills). For *direct* work by the agent. (For orchestrated work, see [`tests-first`](../tests-first/SKILL.md), which inverts the roles — the orchestrator writes tests for subagents to satisfy.)

## The loop

```
RED → write a failing test that captures the next slice of behavior
GREEN → write the minimum impl that makes it pass; nothing more
REFACTOR → clean up, factor, name well, while green stays green
```

One small slice per loop. **Never write more impl than the current red test demands.**

## When to use

- New behavior with a clear user-visible outcome.
- Bug fix that must not regress.
- Refactor where you want a safety net before touching anything.

## Workflow

### 1. Pick the smallest meaningful slice

If you can't think of a one-paragraph user-visible behavior, the slice is wrong. Re-cut.

### 2. RED

Write one test, not three. Make it specific. Run it. Confirm it fails for the *right* reason — not because of a missing import.

### 3. GREEN

Write the minimum code that makes it pass. Hardcode if you must. The next test will force generalization.

### 4. REFACTOR

Once green, look for:
- Duplication you can DRY (without adding wrong abstractions).
- Names that confuse on second reading.
- Long functions that have grown a natural seam.

Run the test after each refactor. If it goes red, you broke a contract. Revert.

### 5. Repeat

Add the next test. Repeat until the slice is done.

## Test quality bar

- One assertion per test where possible.
- Test name reads like a sentence: `it("returns null when given an empty string")`.
- No mocking the system under test.
- No tests that pass-by-accident (test the failure path explicitly).
- No `beforeEach` setup that hides what's actually being tested.

## When NOT to use TDD

- Spike / prototype work where you don't know what the output should look like. Use [`prototype`](../prototype/SKILL.md) instead — write throwaway code, learn, then come back and TDD the real version.
- One-shot scripts.
- Glue code with trivial logic and well-tested deps.

## Anti-patterns

- Writing the test after the impl ("test-after"). The test is a contract; if it can't fail, it's not a contract.
- Testing implementation details instead of behavior. Tests that break on refactor are usually testing the wrong thing.
- Skipping the RED step. The first run must fail.

## Output

A passing test suite for the slice. Code that's no larger than the tests demand. A clean diff.

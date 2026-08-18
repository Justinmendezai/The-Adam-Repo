---
name: prototype
description: Build a throwaway prototype to flesh out a design question. Either a runnable terminal app for state/business-logic questions, or several radically different UI variations toggleable from one route. Use when the right design isn't obvious and TDD is premature.
---

# prototype

Adapted from [Matt Pocock's prototype](https://github.com/mattpocock/skills). When you don't know what to build yet, a sketch is worth more than a spec.

## Two flavors

### Flavor A — Terminal sketch (state, business logic, data shape)

Use when the question is "what does the model look like?" or "how should this state machine behave?":

- Fastest possible runnable code.
- One file usually. `tsx`, `python -c`, `bun run`, whatever's lowest-friction.
- Print the state. Mutate it. Print again.
- No persistence, no auth, no UI polish.
- Throw away when done. Insights go into a PRD or ADR.

### Flavor B — UI variations (visual design, UX flow)

Use when the question is "what should this look like?" or "what flow makes sense?":

- One route in the project (e.g. `/_proto`).
- Render 2–4 variations side-by-side or behind a toggle.
- Use real data shapes if possible, fake data otherwise.
- Each variation gets a name. The user picks one.

## When NOT to prototype

- The behavior is well-understood. Drop straight to [`tdd`](../tdd/SKILL.md).
- The data shape is well-understood. Same.
- The user has already settled on the approach via grilling. Don't second-guess via prototype.

## Workflow

1. Ask the user the design question explicitly. Get their candidate answers.
2. Write each candidate as a runnable sketch.
3. Walk through the sketches together (you describe, user reads).
4. The user picks one or hybridizes.
5. Write down the choice as an ADR.
6. **Throw away the sketches.** They're not the implementation. The implementation comes from `tdd`/`tests-first` against the chosen design.

## Hard rules

- Prototype code never ships. If it does, it becomes legacy fast. Mark `_proto/` or `prototypes/` in `.gitignore` if needed.
- Prototype code is not tested. The cost-benefit doesn't work for throwaway code.
- The takeaway from a prototype is a *decision*, captured as an ADR — not the code itself.

## Output

A throwaway sketch (or set of sketches) and an ADR recording the chosen design. The sketches are git-ignored or in a clearly-marked throwaway folder.

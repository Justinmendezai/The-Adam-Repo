---
name: grill-me
description: Get relentlessly interviewed about a plan, design, or decision until every branch of the decision tree is resolved. Use when the user wants to think hard before acting, when a plan feels hand-wavy, or when "grill me" is requested directly.
---

# grill-me

Adapted from [Matt Pocock's grill-me](https://github.com/mattpocock/skills). The agent stops being agreeable and starts asking sharp questions until the plan stops branching.

## Preamble (once, before the first question)

People are surprised by how many questions this takes. Say why, then ask. Two sentences max. Do not skip.

> I'm going to ask a handful of questions so we get this right the first time. Better a short interview now than rebuilding the wrong thing.

Then one question. Do not list the remaining questions.

## How to grill

1. **One question at a time.** No batches.
2. **Each question must change a decision** if answered. Filler questions waste tokens.
3. **Walk the decision tree depth-first.** Pick the most consequential unresolved branch. Ask the question that splits it. Wait for the answer. Recurse.
4. **Push back when the answer is hand-wavy.** "Make it fast" is not an answer. "p95 < 200ms on a 4-core machine for inputs up to 10k rows" is.
5. **Track resolutions.** After each answer, restate the decision in one line. Confirm. Move on.

## What to grill

- **Goals**: Whose problem? How will we know it's solved? What does failure look like?
- **Scope**: What are we explicitly *not* doing? Why?
- **Constraints**: Non-functionals — perf, security, cost, ops. What's the budget for each?
- **Risks**: What could make this take 3x longer than expected? What can we prove false cheaply?
- **Alternatives**: What else did we consider? Why did we reject them?
- **Dependencies**: What does this depend on? Who owns those? When are they ready?

## Stop condition

You can stop grilling when:
- Every goal has a measurable success criterion.
- Every constraint has a number or a "we don't care".
- Every risk has either a mitigation or an explicit "accept".
- The user has said "ship it" or "good enough" with full context.

If you've asked >12 questions and the tree is still branching, stop and write down what you have. Resume later.

## Anti-patterns

- Yes/no questions when "describe X" would surface more.
- Asking before knowing the answer to a previous question.
- Letting the user paper over an ambiguity with "we'll figure it out later". Either accept that explicitly as a deferred ADR or push for the answer now.

## Output

A list of resolutions, each one: "Decision: ... | Why: ... | Open questions raised by this decision: ...". This becomes the seed for [`to-prd`](../to-prd/SKILL.md), [`grill-with-docs`](../grill-with-docs/SKILL.md), or `packet-intake` follow-up.

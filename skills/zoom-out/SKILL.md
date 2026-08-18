---
name: zoom-out
description: Ask for higher-level context on an unfamiliar section of code instead of diving straight in. Use when the user asks "what is this for?", when about to modify code in a subsystem you don't yet understand, or when the user explicitly says "zoom out".
---

# zoom-out

Adapted from [Matt Pocock's zoom-out](https://github.com/mattpocock/skills). Before you make a change, understand what it's part of.

## When to use

- You're about to modify a function in a module you've never read before.
- The user pastes a snippet and asks "what does this do?" — answer the *system-level* question, not just line-by-line.
- You suspect the change is bigger than the user thinks.

## Workflow

For a target file/function:

1. **Read its module's entry point** (often `index.ts`, `mod.rs`, or the file's containing module). Note what it exports.
2. **Find its callers.** Use the `code-review-graph` MCP if available, or `Grep` for imports of the symbol. List file:line for each caller.
3. **Find its dependencies.** What does it import? Are those internal or third-party?
4. **Place it in the architecture.** Read `plan/CONTEXT.md` (or `docs/`) and locate the file's module in the system diagram.
5. **Identify invariants.** What's the function's contract? What does its docstring say? What do its tests prove?
6. **Now answer.** A good answer has three parts:
   - **Purpose**: what this exists to do, in one sentence.
   - **Context**: where it sits in the system (the module it's part of, the callers it serves).
   - **Constraints**: invariants the change must preserve.

## Output shape

Three short paragraphs, in that order. Then — only then — answer the original question or proceed with the change.

## Anti-patterns

- Reading the function in isolation. You'll miss the contract.
- Listing every caller without reading any of them. The number isn't useful; the *patterns* are.
- "I'll just trace through it" without writing the answer down. The agent's next session won't have your trace.

## Output

A three-paragraph zoom-out, suitable for inclusion in a PR description or a CONTEXT.md update.

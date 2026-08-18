---
name: handoff
description: Compact the current conversation into a handoff document so another agent can continue the work. Use when switching agents mid-task, when the conversation is getting heavy, or when the user explicitly asks for a handoff. Always paste the kickoff prompt in chat and name the target repo.
---

# handoff

Adapted from [Matt Pocock's handoff](https://github.com/mattpocock/skills). General-purpose conversational handoff. For Adam factory builds, prefer [`context-primer`](../context-primer/SKILL.md) which understands the loop's state.

## When to use

- Switching from one agent to another mid-task (e.g. moving to a fresh Cursor chat).
- The current conversation is too long to be efficient and you want to start fresh without losing state.
- Wrapping for the day on an in-progress task.

## Output

A handoff doc on disk **and** a kickoff block in chat. The doc is for the next agent; the chat block is for the operator to copy into a fresh session.

### Handoff doc template

```markdown
# Handoff — <short title>

- From: <agent + user>
- Date: <ISO timestamp>
- Repo: <absolute path>

## What we're doing
One paragraph.

## What we've done
Bulleted, terse:
- Decided X
- Implemented Y (link/path)
- Tested Z

## What's next
The single concrete next step. Be specific about commands or skills to invoke.

## Open questions
Bulleted. Things we deferred.

## Files the next agent should read
1. <path>
2. <path>
3. foundation/repo/agent-control/standing-operator-rules.md  *(Adam factory loops — always)*

## Files the next agent should NOT re-read
The full transcript of this conversation.
Long source files unless the next step requires them.

## Quirks / gotchas
- Up to 3 bullets. Stuff that bit us.
```

## Workflow

1. Skim the conversation. Identify decisions, completed work, open threads.
2. Resolve **absolute repo path** (workspace root / `tech_context.repo_path` / `pwd`). If multi-repo, pick the one the next agent must open first.
3. Fill the template above. Include `Repo:` in the doc header.
4. Save to `handoff-<YYYYMMDD-HHmm>.md` in the working directory (or `scratch/handoff/` for an Adam factory flow).
5. **Required chat closing** — do not end with only a file path. In the same assistant message, output all of:

### Required chat closing (mandatory)

In the same assistant message, include:

1. A heading `## Kick off next chat`
2. **Open this repo in Cursor:** plus the absolute path (alone on a line, in backticks)
3. A one-line instruction: start a new Agent chat in that workspace and paste the block below
4. A fenced `text` code block containing the full paste-ready kickoff prompt (**must include Standing rules** — see shape below)
5. One line with the on-disk handoff file path

Do not end the turn with only “handoff at `<path>`”.

### Kickoff prompt shape (what goes inside the paste block)

Keep it pasteable. The next agent should not need the old transcript. **Always include the Standing rules block** (from [`standing-operator-rules.md`](../../foundation/repo/agent-control/standing-operator-rules.md)) so the operator does not restate transcript themes.

```
Continue from handoff.

Repo: <absolute/repo/path>
Read first: <path-to-handoff-doc>
Then read (in order): <file1>, <file2>, ..., foundation/repo/agent-control/standing-operator-rules.md (or project copy under agent-control/)

Mission: <one paragraph from "What we're doing">
Next concrete step: <exact skill/command from "What's next">

Standing rules (non-negotiable):
- Push feature branches to origin before done; never leave WIP local-only.
- Gate origin/main with ship-when-audited (third-party critic + Bugbot); escalate only arch-impact.
- After intake grill: dual research pods (+ and anti) before plan ADRs.
- No mid-run operator gates; taste/live only at end via human-queue.
- Run all CLI yourself; monitor background jobs (Await/notify) — no silent stalls.
- Anti-theater: real producer/consumer for PASS; no greenwashed scorecards.
- Rework ledger on every block/retry; recurring class → skill/HANDOFF patch.
- UI slices: frontend-taste + theme-from-packet.

Do not re-read the prior chat transcript.
```

If this is an Adam factory project and `agent-control/next-orchestrator-brief.md` exists, prefer:

```
Continue Adam factory run.

Repo: <absolute/repo/path>
Read first: agent-control/next-orchestrator-brief.md
Then: <handoff or primer path>, agent-control/standing-operator-rules.md (if synced)

Next concrete step: <from the brief>

Standing rules (non-negotiable):
- Push feature branches to origin before done; never leave WIP local-only.
- Gate origin/main with ship-when-audited (third-party critic + Bugbot); escalate only arch-impact.
- After intake grill: dual research pods (+ and anti) before plan ADRs.
- No mid-run operator gates; taste/live only at end via human-queue.
- Run all CLI yourself; monitor background jobs (Await/notify) — no silent stalls.
- Anti-theater: real producer/consumer for PASS; no greenwashed scorecards.
- Rework ledger on every block/retry; recurring class → skill/HANDOFF patch.
- UI slices: frontend-taste + theme-from-packet.
```

## Quality bar

A good handoff is **under 150 lines**. If it's longer, you're including narrative that the next agent can re-derive from the source files.

## Anti-patterns

- Quoting code blocks the next agent can read directly.
- Including conversational asides ("we tried X but it didn't work because..."). Keep only what's true at the time of handoff.
- Forgetting the **next concrete step**. That's the most-used field.
- **Saving the file and only saying "handoff at path"** — the operator must get the paste-ready prompt **in chat**, plus which repo to open.
- Naming a relative path as the repo without the absolute path.
- **Kickoff without Standing rules** — omitting the transcript-theme rules so the operator has to restate push/main-gate/dual-research/anti-theater/execute-yourself again.

## Done when

1. Handoff doc exists on disk.
2. Chat message includes **absolute repo path** + **fenced paste-ready kickoff prompt**.

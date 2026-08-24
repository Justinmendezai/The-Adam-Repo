---
name: triage
description: Triage issues through a state machine of triage roles. Move issues from inbox to ready-for-work via a series of narrow per-role passes. Use when an issue tracker has a backlog of fresh issues that need labels, scoping, and decisions.
---

# triage

Adapted from [Matt Pocock's triage](https://github.com/mattpocock/skills). Each issue moves through a series of *roles*, each with a narrow question. The agent embodies one role at a time and answers only that role's question.

## Roles (state machine)

```
INBOX
  → REPRODUCER  (can we reproduce it? if a bug)
  → SCOPER      (what's the smallest fix? what's out of scope?)
  → PRIORITIZER (how important is this relative to what's open?)
  → ASSIGNER    (who picks this up? agent or human?)
  → READY
```

Or for non-bug work:

```
INBOX
  → CLARIFIER   (is the user-visible outcome described concretely?)
  → SCOPER      (smallest delivering this outcome?)
  → PRIORITIZER (relative importance)
  → ASSIGNER
  → READY
```

Each role is a focused pass. Don't try to do all of them at once.

## Per-role questions

### REPRODUCER (bugs only)
- Is there a repro? If not, what's the smallest probable repro?
- Run it (or dispatch a `shell` subagent to). Confirm or refute.
- If unreproducible, label `needs-repro` and pause until more info.

### CLARIFIER (non-bug)
- Is the user-visible outcome described concretely enough that a test could be written for it?
- If no, draft 1–3 questions for the issue author. Don't proceed until answered.

### SCOPER
- What's the smallest, well-bounded change that resolves this?
- What's explicitly out of scope?
- Can it be a single slice in a adam flow, or does it want a PRD?

### PRIORITIZER
- Compare to other open issues (read titles, not bodies).
- Output one of: `now`, `next`, `someday`. Avoid finer granularity unless the team has a labelling convention.

### ASSIGNER
- Could a Composer 2 subagent do this? Check the slice's clarity and scope.
- If yes → label `agent-ready`, ready for `slice-to-tasks` + dispatch.
- If no → assign to a human, with a one-paragraph note explaining what makes it human-only.

## Label vocabulary

Use the project's labels from `adam.json` (or equivalent). If absent, ask the user once and store them.

## Workflow

1. Pull the issue list. For each fresh issue:
2. Determine which track (bug or non-bug).
3. Walk the roles in order. Don't skip ahead.
4. After each role, save state: a label, a comment, a status field — whatever the tracker supports.
5. When `READY`, stop. The next skill (`slice-to-tasks` or human pickup) takes over.

## Anti-patterns

- Trying to do all five roles in one mental pass. You'll miss things.
- Re-reading the full issue body for each role. Read once, work through your notes.
- Adding gratuitous comments. One short comment per role transition.

## Output

Each issue has been advanced to `READY` or paused with a clear blocker. The board is fewer-blocked than when you started.

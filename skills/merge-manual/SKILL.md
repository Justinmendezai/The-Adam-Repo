---
name: merge-manual
description: Merge approved slice branches then output operator manual test checklist. Use for merge then manual, merge branches and test list, or land slices and give me QA steps.
origin: adam
disable-model-invocation: true
---

# merge-manual

**Merge approved work → operator manual verification list.**

## Preconditions

- User named branches or `/repo-truth` identified targets.
- Slice verifiers green on branch (or user accepts merge-with-follow-up).
- Respect `adam.json` → `auto_merge_to_main`.

## Procedure

1. Confirm merge list (branch → main, SHA).
2. Merge or open PR — only with explicit approval.
3. Post-merge: [`repo-truth`](../repo-truth/SKILL.md) snapshot.
4. Emit **Manual test checklist**:

```markdown
## Manual checklist — <wave>
- [ ] Step — expected outcome
```

Include happy path, env vars if migrations landed, items from `agent-control/human-queue.md`.

## Pair with

- [`steward`](../steward/SKILL.md) after manual passes
- [`e2e-acceptance`](../e2e-acceptance/SKILL.md) before declaring build done

## Anti-patterns

- Bulk merge all floating branches without per-branch review.
- Skipping checklist when user said "merge then manual."

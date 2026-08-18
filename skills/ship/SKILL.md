---
name: ship
description: Commit and push current workspace changes with safe git defaults. Use for ship, commit and push, push all, or great commit and push.
origin: adam
disable-model-invocation: true
---

# ship

Commit + push with safe defaults.

## Before any git write

1. `git status` + `git diff` — show what will ship.
2. **Never** commit secrets (`.env`, credentials) — warn and exclude.
3. **Never** force push to main/master.
4. **Never** `--no-verify` unless user explicitly asked.
5. Push only when user said push / ship all / push everything.

## Branch rules

| Context | Branch |
|---------|--------|
| Slice work | `adam/<slice-id>` per folder contract |
| `main` | merge only when user explicitly approved |

Respect `.cursor/adam.json` → `auto_merge_to_main`.

## Commit message

1–2 sentences, **why** not what:

```bash
git commit -m "$(cat <<'EOF'
Why this change matters.

EOF
)"
```

## Procedure

1. Stage relevant files only (unless user said all).
2. Commit.
3. `git push -u origin HEAD` when push requested.
4. `git status` after — confirm clean or report remainder.

## Scope

Current workspace root. Multi-repo: user names each repo or runs `/ship` per repo.

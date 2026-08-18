# Teach while building

Lightweight, **opt-in** micro-lessons during Adam builds — inspired by “teaching while building” products, but non-blocking and markdown-first.

---

## When it runs

| Condition | Behavior |
|-----------|----------|
| `adam/context/preferences.md` → **Teach me** | Show teach hooks at slice boundaries |
| **Pair with me** | Hooks at slice boundaries only (no extra jargon nudges) |
| **Just build it** | No hooks; `/what?` still available |
| User skipped opt-in at first build | Same as Just build it for hooks |

After **`calibrate`**, ask once:

> “Want a ~60-second concept before each major step?”

Answers: **Yes** · **Skip forever** · **Remind later** (re-ask at next `/grill-me`).

---

## Slice convention

Optional block in `slices/<id>/SPEC.md`:

```markdown
## Teach hook
- **Module:** docs/fundamentals/03-git-save-points.md
- **One line:** You're creating a branch so this feature can't break main.
```

Orchestrator reads the module link + one line when eligible. Paste ≤90 seconds of reading, then proceed with build. **Never block** on quiz or completion.

---

## Fundamentals modules

Canonical text: [`fundamentals/`](fundamentals/README.md) — nine app building blocks (modules 1–4 written; 5–9 planned).

Each module includes a default **Teach hook** section for copy-paste into SPECs.

---

## `/what?` vs teach hooks

| Tool | Trigger | Job |
|------|---------|-----|
| **Teach hook** | Proactive, slice boundary | “You’re about to…” context |
| **`/what?`** | User-invoked | Break down any term, pro/con, OSS examples |

Do not auto-invoke `/what?` — skill stays explicit (`disable-model-invocation: true`).

See [`notebooklm-adam-source.md`](notebooklm-adam-source.md) § Fundamentals series for atomization prompts.

# Teach while building

Lightweight, **opt-in** micro-lessons during Adam builds — inspired by “teaching while building” products, but non-blocking and markdown-first.

---

## When it runs

| Condition | Behavior |
|-----------|----------|
| `adam/context/preferences.md` → **Teach me** | Show teach hooks at slice boundaries |
| **Pair with me** | Hooks at slice boundaries only (no extra jargon nudges) |
| **Just build it** | No hooks; if they are confused, explain in this chat |
| User skipped opt-in at first build | Same as Just build it for hooks |

After **`calibrate`**, Teach me records teach-while-building as **yes** by default. One sentence in chat is enough; do not assign this doc as reading.

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

Do not send them to `/what?`. If they are confused, explain in the same chat ([`what`](../skills/what/SKILL.md)).

See [`notebooklm-adam-source.md`](notebooklm-adam-source.md) § Fundamentals series for atomization prompts.

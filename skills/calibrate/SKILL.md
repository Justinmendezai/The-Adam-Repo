---
name: calibrate
description: First-run interview that generates adam/context profile files (founder story, technical level, stack prefs, communication style). Use when starting with Adam, onboarding a new founder, or when context files are missing or stale.
origin: adam
---

# calibrate

Adam's first experience: **conversation before dependencies.**

## Goal

Produce durable context every agent reads before responding:

```
adam/context/user-profile.md
adam/context/technical-level.md
adam/context/preferences.md
adam/context/founder.md
adam/context/project.md
```

Create `adam/context/` if missing. Use templates in `~/adam/adam/context/` as starting shapes.

## Interview flow (one question at a time)

Walk these blocks depth-first. Restate each answer in one line; confirm; write the file section.

### Founder

- What are you building?
- Who is it for?
- Why does it matter?

→ `founder.md` + sections of `project.md`

### Technical level

Pick one: **never coded** | **beginner** | **intermediate** | **professional**

→ `technical-level.md` — include examples of what jargon is OK at this level

### Preferred stack (if known)

Framework, language, database, cloud, hosting — or "undecided / Adam recommend"

→ `project.md` ## Stack

### Communication

Pick one primary mode:

- **Teach me** — explain steps, define terms
- **Pair with me** — collaborative, moderate detail
- **Just build it** — minimal prose, max execution

→ `preferences.md`

### Preferences (optional)

- Detailed vs short responses
- Opinionated vs collaborative
- Risk tolerance for new dependencies

→ `preferences.md`

### Operator identity

Name/handle, timezone, how to address you — `user-profile.md`

## Stop condition

All six files exist with no `TODO` placeholders except explicitly deferred items.

## After calibration

1. If **never coded** or **beginner** + **Teach me**: point at [`docs/fundamentals/README.md`](../../docs/fundamentals/README.md) and ask the teach opt-in once — “Want a ~60-second concept before each major step?” (Yes / Skip forever / Remind later). Record choice in `preferences.md` under `## Teach while building`.
2. Point the user at [`docs/bootstrap.md`](../../docs/bootstrap.md) if the product repo is not set up yet.
3. Suggest **`setup-adam`** in the product repo next.
4. Tell them **`/what?`** is the ongoing explainer — breaks any question into simple terms, pros/cons, and OSS examples matched to their level. Teach hooks during build: [`docs/teach-while-building.md`](../../docs/teach-while-building.md).
5. Do not start building until the user confirms they're ready.

## Anti-patterns

- Batch 10 questions without waiting for answers
- Skipping technical level — it gates explanation depth
- Writing code during calibration

---
name: calibrate
description: First-run interview that generates adam/context profile files and then sets up the project. Use when starting with Adam, onboarding a new founder, when context files are missing, or when the user just opened Adam and does not know what to do next.
origin: adam
---

# calibrate

Adam's first experience: **conversation, then Adam does the setup.**

The operator should not need to know git, skills, MCP, packets, or which command to run next. Ask in plain language. Infer the rest. Do the mechanical work yourself.

## Goal

1. Produce durable context every later agent reads:

   ```
   adam/context/user-profile.md
   adam/context/technical-level.md
   adam/context/preferences.md
   adam/context/founder.md
   adam/context/project.md
   ```

2. Install host skills if they are missing.
3. Run [`setup-adam`](../setup-adam/SKILL.md) in the product folder.
4. Draft `packet/PACKET.md` from the interview (do not ask them to copy a template).

Create `adam/context/` if missing. Use templates in `~/adam/adam/context/` as starting shapes.

## Voice

One question at a time. Restate each answer in one line; confirm; write the file section.

Never ask them to pick jargon labels (`never coded`, framework names, hosting vendors) unless they already used those words. Never paste a bootstrap script for them to run unless a permission gate blocked you.

## Interview flow

### Founder

- What are you trying to make?
- Who is it for?
- Why does that matter to you?

→ `founder.md` + `project.md` one-liner

### First version (plain English)

- What would you need to see to call the first version real?

→ `project.md` current phase `idea` or `planning`; this becomes the packet goal + SC-1. Do not say "success criteria."

### Have you built software before?

Ask it that way. Map privately; do not read the labels out loud unless they ask:

| They say | Level |
|----------|--------|
| No / not really | never coded |
| A little / tutorials / one class | beginner |
| Yes, I ship things | intermediate |
| This is my job | professional |

→ `technical-level.md` (fill the table for **agents**, not for the user)

### How should I talk to you?

- **Explain as we go** → Teach me
- **Think it through with me** → Pair with me
- **Just go build** → Just build it

If Teach me, record teach-while-building as **yes** by default and say one sentence: "I'll explain each step in plain language before I do it. Tell me to skip that anytime." Do not link docs.

→ `preferences.md`

### What should I call you?

Infer timezone from the environment if you can; only ask if you cannot.

→ `user-profile.md`. Set **Primary IDE** from host detection below, not by asking.

### Stack (skip unless they volunteered tools)

If they never named a language, framework, database, or host, write `undecided — Adam recommends` and move on. Adam chooses during research, not during calibrate.

→ `project.md` ## Stack

## Host + folder (you do this; they do not)

Detect host. Do not quiz them:

| Signal | Host |
|--------|------|
| Claude Code / `CLAUDECODE` / this skill loaded from `.claude/skills` | `claude` |
| Codex / this skill loaded from `.agents/skills` or `.codex/skills` | `codex` |
| Otherwise | `cursor` |

If they pointed you at `https://github.com/Justinmendezai/The-Adam-Repo`, clone it if this workspace is not already the harness, then continue. Do not ask them to clone.

**Wrong clone:** if `git remote -v` shows `slowcoder360/adam`, stop. That is the private factory. Public first-run is `https://github.com/Justinmendezai/The-Adam-Repo`. Tell the operator to open that repo (or clone it). Do not keep editing install copy here.

If user-global skills are missing, run from this Adam clone (often `~/adam` or `~/The-Adam-Repo`):

```bash
./scripts/install-skills.sh cursor|codex|claude
```

Copy **folders**. Never flatten `SKILL.md` files.

**Product folder:**

- If the current workspace is the Adam harness (`skills/calibrate` + `foundation/` present) and they do not already have a product repo: ask once, plainly — "Do you already have a folder for this, or should I create one?" Create/init only after they answer. Do not make them run `git clone`.
- If the current workspace is already the product: use it.

Then run [`setup-adam`](../setup-adam/SKILL.md) there. Sync context files into that repo if calibrate started in the harness clone.

Write `project.md` → Product repo as an absolute path.

When you need GitHub (remote), Vercel, or Neon: follow [`docs/accounts.md`](../../docs/accounts.md). Do not ask for all three accounts during the interview.

## Packet draft (you write it)

After setup, write `packet/PACKET.md` from the interview. Valid enough to pass schema:

- `name` — short kebab from the one-liner
- `one_liner`, `owner` (what they asked to be called), `goals` (first-version answer)
- `out_of_scope` — what they said to skip, or `["Anything not in the first version"]`
- `success_criteria` — one SC from "what would make it real"
- `constraints.stack` — their tools or `["Adam recommends"]`
- `tech_context.repo_path` — absolute product path
- `open_questions` — anything still fuzzy

Do not dump the full template on them. Do not ask them to edit YAML.

## Stop condition

Context files exist (no leftover `TODO` except items they explicitly deferred), setup has run, `packet/PACKET.md` exists.

## After that (still in this chat)

One plain-language check: "I saved who you are and what we're building, and I set up the project. Want me to keep going and nail down the first version?"

If yes → immediately follow [`packet-intake`](../packet-intake/SKILL.md) in this chat (grill in plain language). Start with the grill preamble so they are not surprised by the questions. Do not wait for them to name a skill or type a slash command.

If never-coded or beginner: keep explaining in the same voice. Do not send them to `docs/bootstrap.md` or `docs/fundamentals/`. If they get stuck, explain here — do not pitch `/what?`.

Do not write product code during calibrate.

## Anti-patterns

- Batching a form of technical questions
- Asking them to choose a stack, IDE, or hosting vendor
- Pointing at bootstrap/README and waiting for them to set up
- "Next run `setup-adam`" / "type `/packet-intake`" / "run the next command"
- Listing a menu of skill names as the user's job
- Writing code during calibration

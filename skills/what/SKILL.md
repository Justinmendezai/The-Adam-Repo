---
name: what
description: Break down a question or statement into the simplest calibrated terms — plain definition, pros/cons, supporting context, and open-source examples for agents. Respects adam/context technical level and preferences. Use when they ask what, break this down, explain simply, what does this mean, or ELI5. Do not tell them to type /what.
origin: adam
---

# what?

**Explain mode** — not build mode. Turn confusion into calibrated clarity + OSS context agents can reuse.

## Before answering

1. Read (if present):
   - `adam/context/technical-level.md`
   - `adam/context/preferences.md` (Teach me / Pair / Just build it)
2. If **missing** → calibrate is incomplete. Answer at **beginner + Teach me** defaults, then continue calibrate in this chat. Do not tell them to type `/calibrate`.
3. Do **not** write product code unless user pivots to build.

## Calibrated voice (required)

| Level | Words | Structure | OSS research |
|-------|-------|-----------|--------------|
| **never coded** | No jargon without plain-English gloss; analogies first | Short paragraphs; numbered steps | 1–2 famous OSS **products** they'd recognize ("like how WordPress…") |
| **beginner** | Define terms on first use | Bullets; one concept per bullet | 1–2 repos with **what to look at** (README section, folder name) |
| **intermediate** | Standard dev vocabulary OK | Pro/con table + when-to-use | 2–3 repos or reference implementations + file paths to skim |
| **professional** | Terse; no tutorial padding | Bottom line → tradeoffs → links | Best OSS reference + why it matters; skip basics |

**Preferences override:**

- **Teach me** → +1 depth level of explanation (never skip "why").
- **Just build it** → compress to decision summary + links (still run OSS scan if non-obvious).
- **Pair with me** → middle path; ask one checkpoint question at end.

If **never coded** and topic involves IDE/git/repo: include a **"Where this lives"** box (Cursor = the app; repo = project folder; agent = helper in chat).

## Workflow

1. **Restate** the user's question in one plain sentence ("You're asking whether…").
2. **Simplest terms** — core idea in 2–4 sentences max before detail.
3. **Pros / cons / when** — markdown table (minimum 2 pros, 2 cons, 1 "use when / skip when").
4. **Supporting context** — only what changes the decision (constraints, common mistakes, related terms).
5. **OSS research pod** (always for non-trivial topics):
   - Search for **open-source reference implementations**, not blog opinions.
   - Prefer: active repo, clear README, license compatible with learning, similar problem shape.
   - Output **Agent context block** (below) — paths/links agents should read before implementing.
   - Save longer dumps to `scratch/research/what-<slug>-<YYYYMMDD>.md` when >15 lines.
6. **Next step** — do it or ask one plain-language question (“Want me to keep going on the first version?”). Never list slash commands.

Do not fabricate repo URLs — verify with search or mark `unverified`.

## Output shape

```markdown
## In one sentence
...

## Simplest terms
...

## Pros / cons
| | |
|---|---|
| Pros | ... |
| Cons | ... |
| Use when | ... |
| Skip when | ... |

## Supporting context
...

## Open-source starting points (for agents)
| Repo | Why it matters | Start here |
|------|----------------|------------|
| org/name | one line | README / path |

## Calibrated for: <level> · <preference mode>

## Suggested next
One plain-language question or the next action you will take in this chat. No slash commands.
```

## OSS research rules

- **Default:** 1–3 references. More only if user asked for a survey.
- **Prefer** official examples, awesome-lists with repo links, and widely cloned patterns over random tutorials.
- **For never-coded:** explain what a "GitHub repo" is in one sentence when first linking.
- **Deterministic over inference:** state license + last-commit recency when recommending fork/start-from.
- Heavy research → follow [`dispatch-research`](../dispatch-research/SKILL.md) yourself; this answer stays readable.

## Anti-patterns

- Wall of text at professional level when they asked a narrow question.
- Baby talk at professional level.
- Pros/cons without a recommendation.
- Recommending closed SaaS as "the OSS example."
- Skipping OSS block because "they only wanted an explanation" — agents still need a start point.

## Related

- One-time profile: [`calibrate`](../calibrate/SKILL.md)
- Strategy fork: [`brainstorm`](../brainstorm/SKILL.md)
- Deep research brief: [`dispatch-research`](../dispatch-research/SKILL.md)

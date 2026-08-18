# Module 3 — Git: save points and branches

**Promise:** You understand commits and branches as save points and parallel experiments.

**Stage:** 0–1  
**last_reviewed:** 2026-06-26

---

## Simple

**Git** is a **time machine for your project folder**.

- **Commit** = a named save point (“login page works”)
- **Branch** = a parallel timeline (“try dark mode without breaking main”)

Adam often builds on branches like `adam/add-login` so your stable line (`main`) stays safe until you merge.

---

## Practical

| Term | Think of it as… |
|------|------------------|
| **main** | The version you trust today |
| **Branch** | A sandbox for one feature or slice |
| **Commit** | Snapshot with a message |
| **Merge** | Bringing a sandbox back into main |
| **Push** | Uploading commits to GitHub (backup + collaboration) |

You don’t need to memorize commands on day one. You **do** need to know: **work happens on a branch, then merges when verified.**

Adam’s **`/ship`** skill exists so commits aren’t reckless — still read what’s being committed when you can.

---

## Technical

- **Working tree** — files as they exist right now
- **Staging** — marking which changes belong in the next commit
- **Remote** — copy on GitHub (or similar) linked to your laptop

**Go deeper (primary):** [GitHub Docs — Git basics](https://docs.github.com/en/get-started/using-git/about-git)  
**Backup:** [Pro Git book — ch. 1 (free)](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control)

---

## One failure mode

**Huge mixed commit** — login + unrelated refactor + debug prints in one save point. Hard to review and hard to undo. Fix = one slice, one branch, one focused merge.

---

## One verification step

Before merge: ask “**If this breaks production, can I revert one commit?**” If no, split the work.

---

## Teach hook (for slice SPECs)

> We’re creating a **branch** so this slice is an experiment. Main stays safe until tests pass and you merge.

---

## CTA

Next: [Frontend vs backend](04-frontend-vs-backend.md) · Confused on a git term? **`/what?`**

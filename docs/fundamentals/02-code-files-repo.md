# Module 2 — Code, files, and a repo

**Promise:** You know what a project folder is and why the agent edits files — not “the app” as magic.

**Stage:** 0  
**last_reviewed:** 2026-06-26

---

## Simple

**Code** is instructions saved as **text files** in a folder. The computer reads those files and behaves accordingly.

An **app** isn’t a single blob. It’s a **tree of files**: pages, styles, logic, tests, config. Change a file → behavior changes (after you run or deploy the app).

A **repo** (repository) is that folder **tracked over time** so you can see what changed and undo mistakes.

---

## Practical

| Thing | Plain English |
|-------|----------------|
| **Cursor** | The app where you chat with the agent and open files |
| **Project folder / repo** | The directory on disk that *is* your product |
| **`~/adam`** | Adam’s skills — separate from your product |
| **Agent** | Reads/writes files in your product repo when you approve |

When Adam “builds a login page,” it usually **creates or edits files** like `app/login/page.tsx` — not a mystical “login feature” floating in chat.

**Where this lives:** Finder (Mac) or File Explorer — your repo path. In Cursor: left sidebar file tree.

---

## Technical

- **Source code** — human-readable instructions (TypeScript, Python, etc.)
- **Dependencies** — other people’s code your project imports (`package.json`, `requirements.txt`)
- **Build** — step that turns source into something runnable (not always visible for interpreted stacks)

**Go deeper (primary):** [MDN — File structure basics](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/Dealing_with_files)  
**Backup:** Your product’s `README.md` once `setup-adam` scaffolds the tree

---

## One failure mode

**Editing the wrong folder** — changes in chat seem to “do nothing” because the agent updated a copy or the Adam folder instead of the product repo. Fix = confirm repo name in Cursor title bar before big builds.

---

## One verification step

After a slice lands, open the file tree and **click the file the agent named**. You should see new lines. If not, stop and run **`/repo-truth`**.

---

## Teach hook (for slice SPECs)

> We’re about to change **files on disk**. Each file is a piece of the app — you can always open it and read what changed.

---

## CTA

Next: [Git: save points and branches](03-git-save-points.md) · Run **`/setup-adam`** when your product repo is ready.

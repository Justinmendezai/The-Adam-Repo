# Module 1 — What is an app?

**Promise:** After this, you can name the two halves of every app — what you see vs what runs elsewhere.

**Stage:** 0 (AI-curious / never coded)  
**last_reviewed:** 2026-06-26

---

## Simple

An **app** is something you **use** (on a phone or browser) plus **invisible work** on computers that store data and enforce rules.

Think of a restaurant:

- **Dining room** = what you see (buttons, pages, menus on screen)
- **Kitchen** = where orders are cooked and stored (you don’t see it, but nothing works without it)

Most apps fail in your head when people forget the kitchen exists.

---

## Practical

In Cursor you’ll mostly edit **two kinds of places**:

| Place | You might see… | Job |
|-------|----------------|-----|
| **Frontend** | Pages, buttons, colors | Show things; collect clicks |
| **Backend** | Files named `route`, `api`, `server` | Save data; check passwords; send email |

When you click “Save,” the frontend asks the backend to persist it. If there is no backend yet, the button might look fine and still **not remember anything**.

**Where this lives:** Your **product repo** (the folder Adam helps you build) — not the `~/adam` folder. `~/adam` is Adam’s skills; the product repo is the actual app.

---

## Technical

- **Client** — browser or app on your device  
- **Server** — program running on a host (often in the cloud)  
- **Full-stack** — both sides in one project (common for small SaaS)

**Go deeper (primary):** [MDN — How the web works](https://developer.mozilla.org/en-US/docs/Learn/Getting_started_with_the_web/How_the_Web_works)  
**Backup:** [MDN — Client-side vs server-side](https://developer.mozilla.org/en-US/docs/Learn/Server-side/First_steps/Client-Server_overview)

---

## One failure mode

**“It works on my screen but nothing saves.”**  
Usually the UI was built before persistence (backend + database) existed. Fix = wire the button to real storage, not restyle the button.

---

## One verification step

Open your app, change something, **refresh the page**. If the change disappears, you’re looking at frontend-only behavior until backend work lands.

---

## Teach hook (for slice SPECs)

> You’re about to build something users will **see**. Remember: seeing it isn’t the same as **keeping** it — we’ll add the kitchen next.

---

## CTA

Next: [Code, files, and a repo](02-code-files-repo.md) · Confused? Run **`/what?`** in Cursor.

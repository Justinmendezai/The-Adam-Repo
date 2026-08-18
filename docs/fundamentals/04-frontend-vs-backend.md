# Module 4 — Frontend vs backend

**Promise:** You can say where UI lives vs where rules and data live.

**Stage:** 0–1  
**last_reviewed:** 2026-06-26

---

## Simple

**Frontend** = what users see and tap.  
**Backend** = what happens when they tap — checks, storage, email, payments.

They talk over the network using **requests** (often HTTP). The frontend asks; the backend answers or says no.

---

## Practical

In a typical Next.js product repo:

| Layer | Often in… | Examples |
|-------|-----------|----------|
| **Frontend** | `app/`, `components/` | Button, form, layout |
| **Backend** | `app/api/`, `lib/`, server actions | “Create account,” “Charge card” |
| **Shared** | `lib/types`, validation schemas | Shapes both sides agree on |

**Rule of thumb:** If it must stay **secret** (API keys, admin rules) or **authoritative** (who owns this row?), it belongs on the **backend**, not only in the browser.

---

## Technical

- **SSR / server components** — blur the line; some “frontend” files still run on the server. For beginners: follow where **secrets** and **database** calls live — that’s backend territory.
- **API route** — backend endpoint the frontend calls

**Go deeper (primary):** [MDN — Client-Server overview](https://developer.mozilla.org/en-US/docs/Learn/Server-side/First_steps/Client-Server_overview)  
**Backup:** Framework docs — Next.js “Data Fetching” / “Route Handlers”

---

## One failure mode

**Secret in frontend code** — API keys pasted into a file the browser downloads. Anyone can steal them. Fix = move secret to server env vars (Module 7).

---

## One verification step

Ask: “Could a curious user see this in browser devtools?” If yes, it must not be a private key.

---

## Teach hook (for slice SPECs)

> This slice touches **both sides**. UI collects input; server code decides if it’s valid and where it’s stored.

---

## CTA

Next (planned): Database basics · **`/what?`** — “Should this live frontend or backend?”

# Demo plan — task SaaS MVP

## Goal

Web app: users sign up, create tasks, mark complete. Stripe subscription for "pro" unlimited tasks.

## Stack

Next.js, Postgres, Vercel, Stripe Checkout.

## Success criteria

- SC-1: User can sign up and create 10 tasks on free tier
- SC-2: Upgrade flow charges card and removes task limit

## Open questions

- Auth: email magic link vs OAuth?
- Free tier limit: 10 tasks or 10 active?

## Out of scope v1

- Mobile app, teams, API public access

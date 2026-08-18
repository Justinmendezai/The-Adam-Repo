# Packet format

A **packet** is the input you hand the orchestrator. One folder, one `PACKET.md`, optional supporting files. Validated against `schema.json`.

## Why

The orchestrator's first job is `packet-intake`: read the packet, validate it, find the gaps, then research and plan. A consistent packet shape means less time spent figuring out what you actually want.

## Minimum viable packet

A folder containing at least:

```
my-project-packet/
└── PACKET.md
```

Everything else is optional but encouraged.

## Full layout

```
my-project-packet/
├── PACKET.md            # Required. The brief. Filled-in template.
├── refs/                # Optional. PDFs, screenshots, prior docs, transcripts.
├── data/                # Optional. CSVs, JSON, sample inputs.
├── schemas/             # Optional. API contracts, db schemas, type defs.
└── examples/            # Optional. UI mocks, target output samples, repos to mimic.
```

## Required sections in `PACKET.md`

See [`template/PACKET.md`](template/PACKET.md). At a minimum:

1. **One-liner** — one sentence describing the project.
2. **Goals** — bullet list of what done looks like.
3. **Out of scope** — explicit list of what we are *not* doing this round.
4. **Success criteria** — measurable, testable. The `tests-first` skill writes failing tests for these.
5. **Constraints** — tech stack, deployment target, perf budgets, deadlines.
6. **Tech context** — repo path, key libs, conventions to honor.
7. **E2E / Playwright** *(optional)* — `e2e` block: **browser/UI** specs, CLI, base URL. Omit for API-only builds.
8. **Verification layers** *(optional)* — `verification.layers`: **api_e2e**, **integration**, **contract**, **agentic_qa**, plus security ids (**dependency_audit**, **sast**, **secret_scan**, **authz_review**, **security_headers**). See [`template/PACKET.md`](template/PACKET.md).
9. **Security** *(optional)* — `security` block: `audit_ref`, `threat_model_ref`, `acceptance_required`, `block_ship_on`. Run [`security-audit`](../skills/security-audit/SKILL.md) before refactor planning.
10. **Open questions** — ambiguities you already know about. The orchestrator will surface more during intake.

## Validation

`packet-intake` walks the front matter against [`schema.json`](schema.json) manually. A JSON-schema validator script may be added later.

## Tips

- Keep `PACKET.md` under ~400 lines. Move long context to `refs/`.
- When you have a complex requirement, drop a screenshot or sample doc into `refs/` and reference it from `PACKET.md`. Don't paste large blobs inline.
- `success criteria` should be the kind of thing you could write a failing test for. If you can't, sharpen it during intake before slicing.

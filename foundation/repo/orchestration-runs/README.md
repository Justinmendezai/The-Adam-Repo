# Orchestration runs

One folder per **bounded build orchestrator cycle** (disposable sprint manager).

```
orchestration-runs/
├── README.md           # this file
└── run-001/
    ├── summary.md      # 2–4k chars target
    ├── commits.md      # or diffs.md — high-level
    ├── test-results.md # paste or paths to reports
    └── open-issues.md  # delta from this run
```

## Conventions

- **Append-only:** do not edit prior `run-NNN` folders after the fact; add a correction in a later run if needed.
- **Link** `scratch/run-results/` from `summary.md` rather than copying large JSON.
- **`agent-control/current-state.md`** should point at the latest run id when the run completes.

## Numbering

Use zero-padded folders: `run-001`, `run-002`, … or ISO date `run-2026-05-17-001` if multiple runs per day.

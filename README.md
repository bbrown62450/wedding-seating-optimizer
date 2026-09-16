# Wedding Seating Optimizer: requirements fit for an AI implementer

An exercise from the E-gineering group project: take a product requirements
document (PRD) written for people and rewrite it so an AI implementing agent
can build from it without guessing.

## What is here

| File | What it is |
|---|---|
| `docs/original/wedding-seating-optimizer-requirements.md` | v0.1, as written by the team lead. Never edited. |
| `docs/requirements.md` | v0.2, the rewrite. Same ids, same order, one reading per sentence, a `Verify by:` line on every requirement. |
| `docs/change-log.md` | One row per changed requirement: the ambiguous wording, what replaced it, which rule drove it. |
| `docs/decisions.md` | The eight product decisions v0.1 left open, answered, plus every threshold in one table. |
| `docs/ambiguity-checklist.md` | The twelve rules applied, and the banned-word table. Reusable on the next PRD. |
| `scripts/check-requirements.sh` | Proves v0.2 follows the mechanical rules. Exit 0 means it does. |

## How to read it

1. Skim v0.1 to see the starting point.
2. Read `docs/ambiguity-checklist.md` for the rules.
3. Read v0.2 with the change log beside it.

## The eight decisions

| Id | Decision |
|---|---|
| D-01 | Shared access with a stale-object warning; no real-time editing |
| D-02 | Canvas grid coordinates, 0 to 10,000; no physical units |
| D-03 | Table-level assignment only; seats stored, not solved |
| D-04 | Owner and Editor see private notes; no fourth permission |
| D-05 | 500 guests, 60 tables, 4,000 rules, 20 collaborators per event; 50 events per owner |
| D-06 | Backups purged 30 days after deletion |
| D-07 | Natural-language rule assistant in v1; drafts only until approved |
| D-08 | Wedding-specific labels over a generic engine |

## Run the check

```bash
scripts/check-requirements.sh
```

## Next step

The team lead builds an agentic workflow that consumes `docs/requirements.md`.
Nothing in this repo is application code.

## Who did what

Beau Brown owns the content and made the eight decisions. Claude (Fable 5.1)
drafted v0.2, the change log, the checklist, and the checker script from those
decisions and the v0.1 text; Beau reviews every line before it merges.

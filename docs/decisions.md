# Product decisions

Decided by Beau Brown (product owner for this document) on 2026-09-16.
Each decision answers one item from section 18 of v0.1. Requirements cite
these ids inline, for example `(D-03)`. To change a decision, edit this file
and the requirements that cite it; do not edit a requirement alone.

| Id | Question (v0.1 section 18) | Decision | Consequence in requirements.md |
|---|---|---|---|
| D-01 | Real-time multiuser editing, or shared access only? | Shared access only. Two collaborators may open the same event. When a save targets an object that changed since the saver loaded it, the server rejects the save with error `STALE_OBJECT` and the client shows the newer value and offers Reload or Overwrite. No live cursors, no merging. | FR-086, AC-012; 4.2 lists real-time editing as out of scope. |
| D-02 | Physical measurement or canvas coordinates? | Canvas coordinates. Every position is a pair of integers from 0 to 10,000 on each axis (grid units). Distance is Euclidean between table centers, rounded to the nearest integer. No physical units anywhere. | Definitions Grid unit, Table center, Table distance; FR-006, FR-010, FR-014, FR-035. |
| D-03 | Seat-level assignment in the MVP? | No. v1 assigns guests to tables only. Seat positions may be stored and displayed. ADJACENT_SEAT rules are stored but always reported with status Unevaluable. Seat locks are stored as data and honored on manual placement only. | FR-009 to FR-012, FR-044, FR-057, 4.2. |
| D-04 | Separate permission for private notes? | No. Owner and Editor read and write private notes. Viewer never sees them. | FR-017, FR-027, FR-078, FR-084. |
| D-05 | Production limits? | Per event: 500 guests, 60 tables, 4,000 active rules, 20 collaborators. Per owner: 50 events. The server rejects a create that would exceed a limit with error `LIMIT_EXCEEDED`. NFR-001's 250 guests, 30 tables, 2,000 rules stays the timed benchmark. | NFR-015, FR-004, Thresholds table. |
| D-06 | Backup retention after permanent deletion? | 30 days. Deleted event data is absent from every backup 30 days after the delete completes. | NFR-009. |
| D-07 | Natural-language rule assistant in v1? | Yes. A text box sends the text and the event's guest, group, table, zone, and focal point names to a language model, which returns zero or more proposed rules in the structured rule format. Each proposal is shown to the user as an editable draft. A draft becomes an active rule only when an Owner or Editor clicks Approve. The assistant has no write access to the rule store. | FR-087 to FR-089, AC-013, section 1 rule R3. |
| D-08 | Wedding-specific or generic? | Wedding-specific labels, default template, and default group names. The rule types, data model, and solver contain nothing wedding-specific. | 4.1, FR-024, FR-028, FR-039. |

## Thresholds

Every number a requirement depends on, in one place. v0.1 tagged some of
these Proposed; in v0.2 they are decided values and the tag is gone.

| Name | Value | Used by |
|---|---|---|
| Grid extent | 0 to 10,000 per axis, integers | FR-006, FR-010 |
| NEAR default distance | table distance <= 1,500 grid units | FR-034 |
| AWAY default distance | table distance >= 3,000 grid units | FR-034 |
| Table capacity range | 1 to 50 seats | FR-006 |
| Custom table shape | polygon of 3 to 12 vertices | FR-007 |
| Soft-constraint weight | integer 1 to 100, default 50 | FR-032 |
| Priority category weights | Wedding Party 100, Immediate Family 90, Extended Family 70, Friends 50, Coworkers 40, Vendors 10 | FR-039 |
| Group name length | 1 to 40 characters | FR-025 |
| Private note length | 0 to 2,000 characters | FR-017 |
| Override explanation length | 0 to 500 characters | FR-056 |
| Version name length | 1 to 80 characters | FR-061 |
| Undo depth | at least 50 steps per editing session | FR-060 |
| Editing session idle timeout | 60 minutes | Definitions |
| Solver time limit | 60 seconds | FR-052, NFR-001 |
| Optimization benchmark | 250 guests, 30 tables, 2,000 rules in 15 seconds | NFR-001 |
| Interactive feedback | 95% of actions within 500 ms | NFR-002 |
| Autosave delay | within 5 seconds of the last change | NFR-003 |
| Availability | 99.9% monthly, maintenance announced 48 hours ahead excluded | NFR-012 |
| Backup retention after delete | 30 days | NFR-009, D-06 |
| Limits per event | 500 guests, 60 tables, 4,000 rules, 20 collaborators | NFR-015, D-05 |
| Limits per owner | 50 events | NFR-015, D-05 |
| Minimum viewport | 360 CSS pixels wide | NFR-011 |
| CSV import maximum | 1,000 rows per file | FR-021 |

## Benchmark environment

NFR-001 and NFR-002 are measured here and nowhere else:

- One container with 2 vCPU and 4 GB RAM running the server and the solver.
- One solver process, single-threaded, time limit 60 seconds.
- Dataset: `benchmarks/250-guests.json` (to be added by the implementer; 250 guests, 30 tables of capacity 10, 2,000 active rules of mixed types, 20 locks). The dataset is committed so the benchmark is repeatable.
- Client: current Chrome on a machine with at least 4 CPU cores, measured with the browser's Performance API from the input event to the first paint that reflects the change.

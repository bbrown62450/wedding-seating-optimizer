# Wedding Seating Optimizer

## Product Requirements Document

**Status:** v0.2, rewritten for an AI implementing agent
**Source:** v0.1 in `docs/original/`; every edit is listed in `docs/change-log.md`
**Decisions:** `docs/decisions.md` (cited inline as D-01 to D-08)
**Product owner for this document:** Beau Brown
**Audience:** The implementing agent first; product, design, engineering, and QA second

---

## 1. Rules for the implementing agent

These rules are requirements on the agent's behavior, not advice.

**R1.** Every statement containing SHALL or SHALL NOT is a requirement. The agent implements each one as written or reports it under R2. The agent does not weaken, drop, or reinterpret a requirement.

**R2.** If two requirements cannot both be met, or a requirement cannot be met with the decisions in `docs/decisions.md`, the agent stops work on the affected requirements, records the ids and the reason in a file `docs/open-questions.md`, and asks the product owner. It does not choose.

**R3.** The seating engine is a deterministic constraint solver (IG-02). The language-model assistant (D-07) produces rule drafts only. Nothing the assistant produces reaches the rule store, the solver, or a saved chart without an Owner or Editor clicking Approve (FR-088).

**R4.** Every number a requirement depends on is in the Thresholds table of `docs/decisions.md`. The agent reads values from there. If a value is missing there, R2 applies.

**R5.** Section 19 lists the choices left to the agent. The agent may choose freely there and nowhere else.

**R6.** If a term used in a requirement is not defined in section 5 and the agent can read it two ways, R2 applies.

**R7.** The agent writes an automated test for every `Verify by:` line before marking the requirement done.

---

## 2. Product Purpose

The application helps a wedding planner, a couple, or an event organizer create a seating chart from a guest list, a room layout, relationship information, and prioritized seating rules.

The system:

1. Creates each new event with an editable wedding rule template (FR-028).
2. Stores guests, parties, groups, relationships, and rules (sections 8 and 9).
3. Generates a table assignment for every Eligible guest (FR-043).
4. Reports which rules each assignment satisfies and violates (FR-049, FR-078).
5. Accepts manual assignments and locks (section 11).
6. Recalculates when guests are added, removed, or changed (section 12).
7. In Low-disruption and Event-day modes, keeps existing assignments within the limits those modes define (FR-064 to FR-071).

---

## 3. Product Principles

Each principle is enforced by the requirements cited after it.

1. **Rules are data.** Every seating rule is a stored record with the fields in FR-033. No rule exists only in a prompt or in model context (R3, IG-01).
2. **Results are explainable.** Every optimization result lists satisfied rules, violated rules, and the guests each affects (FR-049).
3. **Manual decisions win.** A Locked assignment is never changed by recalculation (FR-058).
4. **Timing decides how much may move.** Planning mode may move any unlocked guest; Low-disruption mode moves at most the number the Editor sets; Event-day mode moves zero previously assigned guests (FR-063 to FR-068).
5. **No false success.** When the hard constraints cannot all be met, the system keeps the saved chart and reports the conflict (FR-050). A rule that cannot be evaluated is reported as Unevaluable, never as satisfied (FR-012, IG-06).
6. **Private notes stay private.** Private notes are never shown to Viewers and never exported unless an Owner or Editor opts in through the warning in FR-085 (FR-027, FR-084).

---

## 4. Scope

### 4.1 In the first release

- Event and room setup: tables, seats as stored positions, zones, focal points (section 7)
- Guest, party, and group management with CSV import (section 8)
- Rule template and the twelve rule types in FR-034 (section 9)
- Natural-language rule drafting with mandatory approval (FR-087 to FR-089, D-07)
- Deterministic table-level assignment (section 10, D-03)
- Manual assignment, locks, undo, named versions (section 11)
- Planning, Low-disruption, and Event-day recalculation (section 12)
- Conflict explanation and corrective options (FR-050, FR-051, FR-069, FR-070)
- Seating chart display, search, and filters (section 13)
- PDF and CSV exports (section 14)
- Wedding-specific labels, template, and group names over a generic engine (D-08)

### 4.2 Out of scope for the first release

- Invitation design or delivery
- RSVP collection from guests
- Catering orders and meal production
- Vendor payment management
- Travel or hotel coordination
- Venue CAD or architectural drawing
- Reading private messages or social-media data
- Real-time collaborative editing with live updates (D-01)
- Seat-level optimization and evaluation of ADJACENT_SEAT rules (D-03)
- Physical units for positions and distances (D-02)
- Templates for events other than weddings (D-08)
- Any permission beyond Owner, Editor, Viewer (D-04)

---

## 5. Definitions

Requirements use these terms with exactly these meanings. Capitalized rule
type names (NEAR, AWAY, and the rest) are identifiers from FR-034.

| Term | Definition |
|---|---|
| Grid unit | The unit of the room layout. Every position is a pair of integers (x, y), each from 0 to 10,000 (D-02). |
| Table center | The (x, y) position stored on a table (FR-006). |
| Table distance | The Euclidean distance between two Table centers, rounded to the nearest integer grid unit. The distance from a table to a Focal point uses the Focal point's position the same way. |
| NEAR | A rule is satisfied when the Table distance between the subject's table and the target's table (or Focal point) is less than or equal to the rule's distance parameter. Default parameter 1,500 grid units. |
| AWAY | A rule is satisfied when that Table distance is greater than or equal to the rule's distance parameter. Default parameter 3,000 grid units. |
| Same table | Two guests are at the Same table when their assignments name the same table id. |
| Different table | Two guests are at Different tables when both are assigned and the table ids differ. Two unassigned guests are not at Different tables. |
| Zone | A named area of the room. A table belongs to at most one Zone. A guest is in a Zone when their assigned table belongs to it. |
| Focal point | A named (x, y) position the Owner or Editor designates, such as the head table or the dance floor. An event has at least one. |
| Adjacent seats | Two seats at the same table whose ordinal numbers differ by 1, or are 1 and the table's capacity (the ring closes). Not evaluated in the first release (D-03). |
| Eligible guest | A guest with RSVP status Confirmed, or with status Pending and the Reserved flag set to true (FR-019). |
| Party | The unit of invitation. Every guest belongs to exactly one Party. A Party may contain one guest. |
| Placeholder guest | A guest record with the Placeholder flag true, created to hold a seat for an unnamed companion (FR-020). |
| Likely duplicate | Two guest rows (existing or in an import) whose normalized display names are equal, or whose email addresses are equal when both have one. Normalized means: Unicode NFKD with combining marks removed, lowercased, runs of whitespace collapsed to one space, leading and trailing whitespace removed. |
| Invalid row | An import row missing the display_name column, or with an rsvp_status value outside the four allowed values, or with an age_category or priority_category value outside the allowed lists. |
| Sufficient capacity | The sum of the capacities of all tables is greater than or equal to the count of Eligible guests. |
| Hard constraint | A rule the solver may not violate. An Exception (below) is the only way an assignment may violate one. |
| Soft constraint | A rule with an integer weight from 1 to 100. The solver may violate it. |
| Score | The sum of the weights of the satisfied Soft constraints in an assignment. Higher is better. |
| Deterministic inputs | The complete set of inputs that define one optimization run: all guests and their fields, all tables, seats, zones, and focal points, all active rules with parameters, all locks, the mode, the movement limit (Low-disruption only), the solver version string, the solver time limit, and the solver random seed. |
| Tie-break | When two assignments have the same Score (and, in Low-disruption mode, the same Disruption count), the system returns the one whose list of (guest id, table id) pairs, sorted by guest id, is lexicographically smaller. |
| Locked assignment | An assignment with a lock record (FR-057). Recalculation may not change it. |
| Disruption count | The number of guests whose assigned table id in a proposed chart differs from their table id in the last saved chart. Guests unassigned in the saved chart do not count. |
| Seat change | A guest whose table id is unchanged but whose seat id differs. Counted and reported separately; never a Disruption. |
| Unresolved conflict | A set of Hard constraints and locks that cannot all be satisfied at once. |
| Rule violation | A Hard or Soft constraint that a proposed or saved assignment does not satisfy. |
| Unevaluable | The status of a rule the system cannot evaluate. In the first release every ADJACENT_SEAT rule is Unevaluable (D-03). An Unevaluable rule contributes 0 to the Score and is listed separately from violations. |
| Exception | A record that an Owner or Editor confirmed a specific Hard constraint may be violated for specific guests, with who, when, and the explanation text (FR-045, FR-056). |
| Stale object | An object whose stored version differs from the version the client loaded before saving (D-01). |
| Editing session | The period from opening an event in one browser tab until that tab is closed or has had no input for 60 minutes. |
| Visible feedback | A change to the rendered page that reflects the action, or a progress indicator, whichever comes first. |
| Planning mode | Recalculation that may move any guest whose assignment is not Locked. |
| Low-disruption mode | Recalculation with a Disruption count limit the Editor sets, treated as a Hard constraint. |
| Event-day mode | Recalculation that treats every existing assignment as Locked unless an Owner or Editor unlocks it. |

---

## 19. Left to the implementer

The agent may choose these and only these without asking:

1. Programming language, web framework, and UI library.
2. Database engine and schema, provided NFR-006 and NFR-013 hold.
3. Hosting and deployment, provided NFR-005 and NFR-012 hold.
4. Which deterministic constraint solver, provided IG-02 and FR-048 hold. OR-Tools CP-SAT is the reference choice.
5. The language model and prompt used for FR-087, provided FR-088 and R3 hold.
6. PDF rendering library and CSV writer.
7. Visual design, provided NFR-010, NFR-011, and FR-075 hold.
8. Internal ids and their format, provided every id is unique within the event.
9. The procedure used to find the constraint set reported in FR-050, provided the set it reports is one whose removal makes the problem feasible.

Everything else is decided by this document or by `docs/decisions.md`.

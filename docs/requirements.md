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

## 6. Users and Permissions

**Roles.** Owner: manages the event, collaborators, rules, guests, tables, assignments, exports, and deletion. Editor: everything an Owner does except deleting the event and changing the Owner. Viewer: reads the chart and the exports in FR-080 to FR-083; changes nothing; never sees private notes (D-04).

**FR-001.** The Owner SHALL be able to grant Editor or Viewer access to a person identified by email address, and to revoke it. The event has exactly one Owner. (a) Granting to an email already holding a role replaces the role. (b) The server rejects a grant that would exceed 20 collaborators with error LIMIT_EXCEEDED (D-05).
Verify by: as Owner grant Editor, then Viewer, then revoke; the collaborator's role changes each time and access ends on revoke. The 21st grant returns LIMIT_EXCEEDED.

**FR-002.** The server SHALL check the caller's role on every request that reads or changes event data and SHALL return HTTP 403 with error FORBIDDEN, changing nothing, when the role does not permit the request. The client's hiding or disabling of controls is not the enforcement.
Verify by: a Viewer's direct API call to change a guest returns 403 and the guest is unchanged.

**FR-003.** For every change to a guest, rule, table, zone, focal point, assignment, lock, or saved version, the system SHALL record the changing user's id and the UTC timestamp on the changed record and in the audit record (NFR-008).
Verify by: change each object type once; each record and the audit log show the caller's id and a UTC timestamp within one second of the change.

---

## 7. Event and Room Setup

**FR-004.** Any signed-in user SHALL be able to create an event and becomes its Owner. An event SHALL contain: (a) name, 1 to 120 characters; (b) date, a calendar date; (c) time zone, an IANA name; (d) venue name, 0 to 120 characters; (e) expected guest count, an integer from 1 to 500, used only for the capacity warning in FR-041(d); (f) at least one Focal point with a name and a Grid position. The server rejects the 51st event for one Owner with error LIMIT_EXCEEDED (D-05).
Verify by: create an event with every field; each is stored as entered. Omit the Focal point; creation is rejected with error FOCAL_POINT_REQUIRED.

**FR-005.** An Owner or Editor SHALL be able to add, edit, duplicate, reorder, and remove tables. Duplicating copies every table field except id and position, placing the copy 500 grid units to the right (x + 500, clamped to 10,000). Removing a table with assigned guests unassigns them and reports their names. The server rejects the 61st table with error LIMIT_EXCEEDED (D-05).
Verify by: each operation once; state matches the described result.

**FR-006.** Each table SHALL have: (a) a unique id within the event; (b) a display label, 1 to 20 characters, unique within the event; (c) a capacity, integer 1 to 50; (d) a shape from FR-007; (e) a Table center in Grid units (D-02); (f) a rotation in whole degrees from 0 to 359.
Verify by: create a table with each field at its limits; values outside the ranges are rejected with error VALIDATION.

**FR-007.** The system SHALL support exactly three shapes: round (radius in Grid units), rectangular (width and depth in Grid units), and custom (a polygon of 3 to 12 vertices in Grid units relative to the Table center).
Verify by: create one of each; a custom shape with 2 or 13 vertices is rejected with error VALIDATION.

**FR-008.** An Owner or Editor SHALL be able to change a table's Table center and rotation on the room layout by dragging, and by typing values.
Verify by: drag a table; its stored center changes to the drop position. Type a center; the layout shows it there.

**FR-009.** An Owner or Editor SHALL be able to record seats around a table, up to the table's capacity. Seats are stored and displayed. In the first release the solver does not assign seats (D-03, FR-044).
Verify by: add capacity + 1 seats; the last is rejected with error CAPACITY_EXCEEDED.

**FR-010.** Each seat SHALL have a unique id within the event, an ordinal from 1 to the table's capacity, unique within the table, and a position in Grid units relative to the Table center.
Verify by: two seats with the same ordinal at one table are rejected with error VALIDATION.

**FR-011.** The system SHALL compute Adjacent seats from seat ordinals as defined in section 5 and SHALL show the two neighbors of a selected seat.
Verify by: at a table of capacity 8, seat 8's neighbors are 7 and 1.

**FR-012.** In the first release every ADJACENT_SEAT rule SHALL be reported with status Unevaluable in every result (D-03). An Unevaluable rule SHALL NOT be shown as satisfied and SHALL NOT add to the Score.
Verify by: add an ADJACENT_SEAT rule and run optimization; the result lists it under Unevaluable, and the Score is unchanged by its presence.

**FR-013.** The system SHALL reject any assignment, manual or automatic, that would make a table's assigned guest count exceed its capacity, with error CAPACITY_EXCEEDED and no change. To seat more guests an Owner or Editor first raises the capacity (FR-006).
Verify by: fill a table to capacity; the next drop returns CAPACITY_EXCEEDED and the chart is unchanged.

**FR-014.** The system SHALL compute Table distance as defined in section 5 and SHALL show it when two tables are selected.
Verify by: tables at (0,0) and (3000,4000) show distance 5000.

**FR-015.** An Owner or Editor SHALL be able to create, rename, and delete Zones. A new event has these Zones: Front, Center, Rear, Accessible, Children's Area, Vendor Area. Zone names are 1 to 40 characters and unique within the event. A table is in at most one Zone. Deleting a Zone removes its tables from it and disables rules that name it, reporting their ids.
Verify by: assign a table to two Zones; the second is rejected with error VALIDATION. Delete a Zone named by a rule; the rule shows status Disabled.

---

## 8. Guest Management

**FR-016.** Each guest record SHALL contain: (a) a unique id within the event; (b) a display name, 1 to 80 characters; (c) an RSVP status from FR-018; (d) exactly one Party (section 5). The server rejects the 501st guest with error LIMIT_EXCEEDED (D-05).
Verify by: a guest without a Party is rejected with error VALIDATION; the 501st guest returns LIMIT_EXCEEDED.

**FR-017.** A guest record SHALL optionally contain: pronouns (0 to 30 characters); age category, one of Adult, Child, Infant; meal choice (0 to 40 characters); accessibility needs (0 to 200 characters) and a wheelchair flag; email (0 to 254 characters); zero or more groups (FR-024); a seating-priority category (FR-039) or none; private notes (0 to 2,000 characters), readable and writable by Owner and Editor only (D-04); a Reserved flag; a Placeholder flag.
Verify by: save each field at its limit; a 2,001-character note is rejected with error VALIDATION; a Viewer's read of the guest omits private notes.

**FR-018.** RSVP status SHALL be one of Confirmed, Pending, Declined, Cancelled. (a) Confirmed guests are Eligible. (b) Pending guests are Eligible only when Reserved is true. (c) Declined and Cancelled guests are never Eligible; changing a guest to either status removes their assignment and frees the seat.
Verify by: each transition; Eligibility and assignment follow (a) to (c).

**FR-019.** Automatic assignment SHALL place Eligible guests only. An Owner or Editor sets Reserved on a Pending guest to make them Eligible.
Verify by: a Pending guest with Reserved false stays unassigned after optimization; set Reserved true and rerun; the guest is assigned.

**FR-020.** An Owner or Editor SHALL be able to create a Placeholder guest in a Party (display name defaults to "Guest of " followed by the host's display name; status Pending; Reserved true). Converting a Placeholder to a named guest keeps the same id, assignment, Party, groups, and rules, sets Placeholder false, and sets the new name and RSVP status.
Verify by: create a Placeholder, assign it to Table 3, convert it; the named guest is still at Table 3 with the same id.

**FR-021.** Guests SHALL be creatable one at a time, as a Party of several guests in one form, and from a CSV file. The CSV SHALL be UTF-8 with a header row and these columns: display_name (required), party (text; rows with the same value join one Party; blank means a Party of one), rsvp_status (default Pending), email, groups (semicolon-separated names), age_category, meal, accessibility, wheelchair (true or false), priority_category, notes. Unknown columns are ignored and reported. Maximum 1,000 rows per file.
Verify by: import a file with every column; each guest carries the values. A 1,001-row file is rejected with error LIMIT_EXCEEDED before any row is applied.

**FR-022.** Before applying a CSV import, the system SHALL show: (a) every Invalid row with its row number and the reason; (b) every Likely duplicate pair, row against existing guest or row against row; (c) the count of guests that will be created; (d) the count of existing guests that will be updated (rows whose display_name and party match an existing guest exactly after normalization).
Verify by: a file with one invalid row, one duplicate of an existing guest, and two new rows shows 1, 1, 2, 0 in the preview.

**FR-023.** An Owner or Editor SHALL be able to cancel an import from the preview. Cancelling changes no event data.
Verify by: preview then cancel; guest count and every guest record are unchanged.

**FR-024.** A new event SHALL contain exactly these groups: Household, Couple, Immediate Family, Extended Family, Wedding Party, Friends, Coworkers, Children, Vendors (D-08). A group has a name and a list of member guests.
Verify by: a new event lists the nine groups and no others.

**FR-025.** An Owner or Editor SHALL be able to create, rename, and delete groups. Names are 1 to 40 characters and unique within the event. Deleting a group disables rules that name it and reports their ids.
Verify by: create a group with a duplicate name; rejected with error VALIDATION.

**FR-026.** A guest SHALL be a member of zero or more groups.
Verify by: add one guest to three groups; all three list the guest.

**FR-027.** Private notes SHALL be absent from every screen a Viewer can open and from every export unless an Owner or Editor opts in through FR-085.
Verify by: AC-008, and a Viewer's guest detail response contains no notes field.

---

## 9. Seating Rules

**FR-028.** A new event SHALL contain this rule template (D-08). Every row is an active rule the Owner or Editor may change under FR-030.

| Template rule | Type (FR-034) | Subject | Target or parameter | Hardness | Weight |
|---|---|---|---|---|---|
| Couples sit together | SAME_TABLE | group Couple, per Party | | Hard | |
| Households sit together | SAME_TABLE | group Household, per Party | | Hard | |
| Wedding party sits at the front | NEAR_FOCAL | group Wedding Party | first Focal point, 1,500 | Soft | 100 |
| Immediate family sits at the front | NEAR_FOCAL | group Immediate Family | first Focal point, 1,500 | Soft | 90 |
| Children sit in the children's area | IN_ZONE | group Children | Zone Children's Area | Soft | 60 |
| Vendors sit in the vendor area | IN_ZONE | group Vendors | Zone Vendor Area | Soft | 80 |
| Wheelchair users sit in accessible seating | IN_ZONE | guests with wheelchair true | Zone Accessible | Hard | |

"per Party" means one rule instance for each Party whose members are in the group.
Verify by: a new event lists these seven rules with these values.

**FR-029.** The template rules SHALL be ordinary rules: same storage, same fields (FR-033), same editing (FR-030). Nothing distinguishes a template rule from a rule the Editor adds except its origin field, which is "template" or "user" or "assistant" (FR-087).
Verify by: edit a template rule's weight; the stored rule shows the new weight and origin "template".

**FR-030.** An Owner or Editor SHALL be able to enable, disable, duplicate, edit, and delete any rule. A disabled rule is stored but ignored by the solver and by results.
Verify by: disable a Hard rule that was being violated; the next result lists no violation for it.

**FR-031.** Every rule SHALL be either a Hard constraint or a Soft constraint. Changing Hard to Soft requires FR-042.
Verify by: the rule form offers exactly two hardness values.

**FR-032.** Every Soft constraint SHALL have an integer weight from 1 to 100, default 50. 100 is the highest priority.
Verify by: weight 0 and 101 are rejected with error VALIDATION; a new Soft rule shows 50.

**FR-033.** Every rule SHALL store: id; type (FR-034); subject (a guest id, a group id, or a wheelchair-flag selector); target (a guest id, group id, table id, Zone id, or Focal point id, as the type requires); parameter (an integer, as the type requires); hardness; weight (Soft only); enabled flag; origin; who created it and when (FR-003).
Verify by: read a rule of each type over the API; every field listed is present.

**FR-034.** The system SHALL support exactly these twelve rule types. "Satisfied" is defined per type. Subject and target groups expand to every pair of members (subject group against target group) or every pair within the group (single group).

| Type | Subject | Target / parameter | Satisfied when |
|---|---|---|---|
| SAME_TABLE | guest or group | guest or group, or none for a single group | every pair is at the Same table |
| DIFFERENT_TABLE | guest or group | guest or group | every pair is at Different tables |
| ADJACENT_SEAT | guest or group | guest or group | Unevaluable in the first release (D-03) |
| MIN_DISTANCE | guest or group | guest or group; parameter N grid units | every pair's Table distance >= N |
| NEAR | guest or group | guest or group; parameter N, default 1,500 | every pair's Table distance <= N |
| AWAY | guest or group | guest or group; parameter N, default 3,000 | every pair's Table distance >= N |
| IN_ZONE | guest or group | Zone | every subject is in the Zone |
| OUT_OF_ZONE | guest or group | Zone | no subject is in the Zone |
| NEAR_FOCAL | guest or group | Focal point; parameter N, default 1,500 | every subject's Table distance to the Focal point <= N |
| AWAY_FOCAL | guest or group | Focal point; parameter N, default 3,000 | every subject's Table distance to the Focal point >= N |
| ASSIGN_TABLE | guest or group | table | every subject is at that table |
| EXCLUDE_TABLE | guest or group | table | no subject is at that table |

Verify by: one rule of each type against a two-table layout; the result marks each satisfied or violated as the table above predicts. AC-015 covers MIN_DISTANCE.

**FR-035.** MIN_DISTANCE, NEAR, AWAY, NEAR_FOCAL, and AWAY_FOCAL SHALL store their distance as an integer number of Grid units (D-02). The system SHALL NOT store a distance rule without a number.
Verify by: saving a MIN_DISTANCE rule with a blank parameter is rejected with error VALIDATION.

**FR-036.** A rule whose subject is a group and whose type is SAME_TABLE with no target SHALL keep every member of the group at one table.
Verify by: a group of 4 with a Hard SAME_TABLE rule ends at one table after optimization.

**FR-037.** A SAME_TABLE group rule SHALL be Hard (splitting prohibited) or Soft with a weight (splitting permitted at that cost). No third option exists.
Verify by: the rule form for SAME_TABLE offers Hard or Soft with weight; nothing else.

**FR-038.** Each seating-priority category SHALL map to a weight (FR-039). For every Eligible guest with a category, the system SHALL evaluate one implicit Soft NEAR_FOCAL constraint against the event's first Focal point with parameter 1,500 and that weight. Implicit constraints appear in results like stored rules, with origin "priority".
Verify by: two guests, one Wedding Party and one Vendor, one table within 1,500 of the Focal point with one free seat; the Wedding Party guest gets it.

**FR-039.** The default categories and weights SHALL be: Wedding Party 100, Immediate Family 90, Extended Family 70, Friends 50, Coworkers 40, Vendors 10 (D-08). An Owner or Editor SHALL be able to change a category's weight (1 to 100) and add categories.
Verify by: change Friends to 95; the implicit constraints for Friends carry 95 in the next result.

**FR-040.** An Owner or Editor SHALL be able to set a priority weight on one guest or one group that replaces the category weight for those guests.
Verify by: set a Vendor guest's override to 100; that guest's implicit constraint shows 100 while other Vendors show 10.

**FR-041.** Before running the solver, the system SHALL run these checks and, if any fails, SHALL show the failing check with the ids involved and SHALL NOT run the solver: (a) two Hard rules that no assignment can satisfy together, detected for these pairs: SAME_TABLE against DIFFERENT_TABLE on the same pair of guests, ASSIGN_TABLE against EXCLUDE_TABLE on the same guest and table, two ASSIGN_TABLE rules on one guest naming different tables, and a lock that contradicts an ASSIGN_TABLE rule; (b) a group with a Hard SAME_TABLE rule whose member count exceeds every table's capacity; (c) a Hard IN_ZONE or ASSIGN_TABLE rule naming a Zone with no tables or a table with no free capacity for the subjects; (d) not Sufficient capacity. Conflicts the solver finds beyond these are handled by FR-050.
Verify by: one fixture per check (a) to (d); each shows the named check and the solver does not run.

**FR-042.** Changing a rule from Hard to Soft SHALL require the Owner or Editor to click Confirm in a dialog that shows the rule and states that the solver may now violate it.
Verify by: the change without the dialog's Confirm leaves the rule Hard.

**FR-086.** When a save targets a Stale object, the server SHALL reject it with error STALE_OBJECT and return the current stored version, and the client SHALL show the current value and offer Reload (discard the local change) or Overwrite (resubmit against the current version) (D-01).
Verify by: AC-012.

**FR-087.** An Owner or Editor SHALL be able to type a seating instruction in plain language. The system SHALL send the text and the event's guest, group, table, Zone, and Focal point names to a language model and SHALL show the model's output as zero or more draft rules in the FR-033 format, each editable (D-07).
Verify by: type "Aunt May must not sit with Uncle Bob"; a draft DIFFERENT_TABLE rule appears naming both guests with hardness Soft, weight 50.

**FR-088.** A draft rule SHALL NOT be stored as a rule, used by the solver, or shown in results until an Owner or Editor clicks Approve on that draft. Approving stores it with origin "assistant". Discarding removes it. Drafts not approved within the Editing session are discarded.
Verify by: AC-013.

**FR-089.** When the model returns output that does not parse into the FR-033 format, or names a guest, group, table, Zone, or Focal point that does not exist in the event, the system SHALL show "The assistant could not turn that into a rule" with the unmatched names, and SHALL create no draft.
Verify by: type an instruction naming a guest not in the event; no draft appears and the message names the guest.

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

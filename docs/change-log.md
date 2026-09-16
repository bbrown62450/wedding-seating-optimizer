# Change log: v0.1 to v0.2

Every v0.1 requirement id survives. Rows below name the ambiguous wording,
what replaced it, and the checklist rule that drove the change
(`docs/ambiguity-checklist.md`).

## Added

| Id | What | Why |
|---|---|---|
| R1 to R7 | Section 1 rewritten as numbered rules for the agent | Rule 11 |
| FR-086 | Stale-object save conflict | D-01 |
| FR-087 to FR-089 | Natural-language rule assistant, approval, failure | D-07 |
| NFR-015 | Limits enforced with LIMIT_EXCEEDED | D-05 |
| AC-009 to AC-015 | Scenarios for Low-disruption limit, determinism, import preview, save conflict, assistant drafts, capacity rejection, MIN_DISTANCE | Rule 8 |
| IG-01 to IG-08 | Guardrails given ids and Verify by lines | Rule 11 |
| Section 19 | Left to the implementer | Rule 10 |
| Definitions | 22 new terms (Grid unit through Stale object) | Rule 2 |

## Removed

None. FR-035's "minimum number of intervening table zones" option is gone from the rule (zones have no order, so the count had no meaning); the id and the grid-unit half remain.

## Changed

| Id | v0.1 wording (the part that had two readings) | v0.2 | Rule |
|---|---|---|---|
| FR-001 | "event owner" | Owner; grant by email; 20-collaborator limit; regrant replaces | 4, 5 |
| FR-002 | "enforce permissions on the server" | HTTP 403 FORBIDDEN, no change, on every request | 5 |
| FR-003 | "identity and timestamp" | user id and UTC timestamp on the record and in the audit log | 2 |
| FR-004 | "authorized user"; "expected guest count" with no use | any signed-in user becomes Owner; count 1 to 500 used only by FR-041(d); focal point has a position | 4, 2 |
| FR-005 | "duplicate" undefined | copy placed at x + 500; removing a table unassigns and reports | 5 |
| FR-006 | "position on a two-dimensional room layout" | Table center in Grid units 0 to 10,000; capacity 1 to 50; rotation 0 to 359 | 2, D-02 |
| FR-007 | "custom-shaped" | polygon of 3 to 12 vertices | 2 |
| FR-008 | "rotate and reposition" | by dragging and by typing values; roles named | 4 |
| FR-009 | "optional seat-level configuration" | seats stored and displayed, not solved (D-03) | 10 |
| FR-010 | "defined position relative to its table" | ordinal 1 to capacity plus Grid offset | 2 |
| FR-011 | "adjacent-seat relationships" | ordinals differ by 1, ring closes | 2 |
| FR-012 | conditional on "not configured" | always Unevaluable in v1 | D-03 |
| FR-013 | "prevent" | reject with CAPACITY_EXCEEDED, no change | 5 |
| FR-014 | "proximity" | Table distance, Euclidean, rounded | 2 |
| FR-015 | "such as Front, Center, ..." | the six default Zones; one Zone per table; delete disables rules | 3 |
| FR-016 | "party or household association" | exactly one Party; Party of one allowed | 2 |
| FR-017 | field list with no types or limits | every optional field typed and bounded; notes Owner/Editor only | 2, D-04 |
| FR-018 | four statuses with no effects | effect of each status on Eligibility and assignment | 5 |
| FR-019 | "explicitly reserves" | Reserved flag on a Pending guest | 12 |
| FR-020 | "without losing their assignment or relationships" | same id, assignment, Party, groups, rules; default name and status | 7 |
| FR-021 | "imported from a CSV file" | column list, encoding, header, party join rule, 1,000-row cap | 3 |
| FR-022 | "likely duplicate", "invalid rows" | Likely duplicate and Invalid row defined; update rule stated | 2 |
| FR-023 | "the user" | Owner or Editor; cancel from the preview | 4 |
| FR-024 | "including Household, ..." | exactly the nine groups | 3 |
| FR-025 | "additional guest-group types" | names 1 to 40, unique; delete disables rules | 2 |
| FR-027 | "guest-facing screens" | screens a Viewer can open, and every export | 4 |
| FR-028, FR-029 | "editable wedding-rule template", "proposed rules for couples, ..." | the seven template rules as a table with type, subject, hardness, weight | 3 |
| FR-032 | no default | default 50 | 9 |
| FR-033 | "identify the guests, groups, tables, zones, or focal points" | the full field list of a rule record | 3 |
| FR-034 | nine prose rules with "near", "away", "adjacent" | twelve typed rules with satisfied-when definitions and default distances | 2, 3 |
| FR-035 | "measurable layout distance or ... intervening table zones" | Grid units only | 2, D-02 |
| FR-038 | "ranked relative to a designated focal point" | implicit Soft NEAR_FOCAL per guest with the category weight | 2 |
| FR-039 | "include Wedding Party, ..." | exactly six categories with weights | 3 |
| FR-041 | "contradictory hard constraints" and three other phrases | checks (a) to (d) with the exact pairs detected | 5 |
| FR-042 | "user confirmation" | Confirm in a dialog stating the consequence | 12 |
| FR-043 | "sufficient capacity" | Sufficient capacity defined; gated on FR-041 | 2 |
| FR-044 | "when seat-level layouts exist" | no seat assignment in v1 | D-03 |
| FR-045 | "explicitly authorizes a documented exception" | Exception record via FR-054 and FR-056 | 12 |
| FR-046 | "maximize the weighted total" | Score defined; Tie-break named | 6 |
| FR-048 | "identical ... solver settings" | Deterministic inputs listed; stored with the result | 6 |
| FR-049 | six bullets | eight lettered fields with names | 7 |
| FR-050 | "identify the hard constraints involved" | a set whose removal makes the problem feasible; procedure left to implementer | 5, 10 |
| FR-051 | "such as increasing capacity, ..." | exactly four options with the rule for when each applies | 3 |
| FR-052 | "timed-out" | 60-second limit; which of three outcomes is shown | 2, 5 |
| FR-053 | "drag-and-drop, seat swapping, and table reassignment controls" | three lettered actions | 7 |
| FR-054 | "explicit confirmation" | Confirm in a dialog naming rule and guests; Exception recorded | 12 |
| FR-056 | "record an explanation" | 0 to 500 characters with user id and timestamp | 2 |
| FR-057 | three lock kinds | seat lock also locks the table (D-03); locks are records | 5 |
| FR-059 | "authorized users" | Owner or Editor | 4 |
| FR-060 | "current editing session" | Editing session defined; depth at least 50; a result is one step | 2 |
| FR-061 | "named" | 1 to 80 characters, unique | 2 |
| FR-062 | "compare" | every guest whose table or seat differs; restore is undoable | 5 |
| Section 12 table | "shortly before the event" | objectives in order per mode | 2 |
| FR-064 | "maximum number of guests" | L, integer 0 to assigned count, set before the run | 2 |
| FR-066 | "minimize ... before maximizing" | objective order with Tie-break third | 6 |
| FR-068 | "unoccupied seats" | tables with free capacity; Score over new guests only | 2 |
| FR-069 | "ranked by disruption count and violated-rule weight" | three-key ascending order | 6 |
| FR-070 | "such as adding a table, ..." | exactly four kinds, each with its two numbers | 3 |
| FR-072 | "comparison" | old and new values, Disruption count, Seat change count | 5 |
| FR-075 | "without relying on color alone" | icon and text label | 2 |
| FR-076 | "search" | case-insensitive substring; outline table and seat | 2 |
| FR-077 | filter list | AND combination stated | 5 |
| FR-078 | "to authorized users" | Owner and Editor for notes (D-04); rule statuses listed | 4 |
| FR-080, FR-081, FR-082, FR-083 | "printable", "PDF and CSV" | PDF version, page rule, CSV headers | 2 |
| FR-085 | "authorized user"; "privacy warning" | Owner or Editor; checkbox label; field names shown; audit row | 4, 5 |
| NFR-001, NFR-002, NFR-003, NFR-012 | "(Proposed)"; "documented production test environment" | tag removed; Benchmark environment in decisions.md | 9 |
| NFR-002 | "visible feedback" | Visible feedback defined; p95 stated | 2 |
| NFR-004 | "retry after connectivity is restored" | every 10 seconds; indicator text | 2 |
| NFR-006 | "encrypted at rest" | AES-256 or stronger | 2 |
| NFR-008 | list of audited actions | full list plus role grants and deletion; entry fields | 3 |
| NFR-009 | "retention period ... must be documented" | 30 days (D-06); typed-name confirmation | 9 |
| NFR-011 | "event-day interface" | every screen used in Event-day mode | 4 |
| AC-001 to AC-008 | "sufficient table capacity", "any optimization mode" | named fixtures, all three modes, exact counts | 2, 8 |
| Guardrails 1 to 8 | prose | IG-01 to IG-08 with Verify by | 11 |
| Section 18 | eight open questions | closed; pointer to decisions.md | 10 |
| FR-026, FR-030, FR-031, FR-036, FR-037, FR-040, FR-047, FR-055, FR-058, FR-063, FR-065, FR-067, FR-071, FR-073, FR-074, FR-079, FR-084, NFR-005, NFR-007, NFR-010, NFR-013, NFR-014 | none | Verify by line added; roles named where "the user" appeared | 4, 8 |

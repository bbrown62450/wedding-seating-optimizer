# Ambiguity checklist: making a PRD fit for an AI implementer

These are the rules applied to turn v0.1 into v0.2. They are written so the
next PRD can go through the same pass. `scripts/check-requirements.sh`
enforces the mechanical ones.

## The test for every sentence

Read the sentence as an agent that will build exactly what it says and has
no one to ask. If two competent engineers could build two different things
from it, the sentence fails.

## Rules

1. **Keep the id and the order.** FR-001 in the rewrite is the same
   requirement as FR-001 in the source. New requirements get new ids after
   the last one; nothing is renumbered, so the change log maps one to one.
2. **Replace relative words with a measure.** A number, a unit, a count, or
   a matching rule. Banned in requirement text: near, away, far, adjacent,
   shortly, sufficient, insufficient, likely, appropriate, quickly, large,
   small. The measure is defined once in the Definitions section and the
   defined term is used everywhere else.
3. **Close every open list.** "such as", "including", and "etc" are banned.
   Either list every member or state the rule that decides membership.
4. **Name the actor by role.** "the user" and "authorized user" are banned.
   Write Owner, Editor, Viewer, or the combination.
5. **Name the failure behavior.** If a requirement can fail, say what the
   system does instead: the error code shown and the state preserved.
6. **Make determinism concrete.** If two runs must match, list every input
   that defines a run, the score function, and the tie-break order.
7. **One claim per statement.** A sentence joining two testable claims with
   "and" becomes lettered sub-statements under the same id.
8. **Every requirement ends with `Verify by:`.** One line naming the
   observable check: a scenario id, a query, a measured number.
9. **Decided, not Proposed.** A threshold is a value. It lives in
   `docs/decisions.md`; the requirement cites it. The word Proposed is
   banned.
10. **Fence what is deferred.** One section lists what the document
    deliberately leaves to the implementer (language, framework, database,
    hosting) and says the agent may choose there and nowhere else. Another
    lists what is out of scope.
11. **Rules, not advice.** Guidance to the agent is written as numbered,
    testable rules, not paragraphs of intent.
12. **Plain US English, no em dashes.** "explicitly" and "silently" are
    banned because they describe intent, not behavior: say what the screen
    shows or what the record stores.

## Words that always need a measure

| Word in the source | What to write instead |
|---|---|
| near, close to | table distance <= N grid units (state N) |
| away from, far from | table distance >= N grid units (state N) |
| adjacent | seat ordinals differ by 1 modulo the table's capacity |
| shortly before the event | the named mode (Low-disruption, Event-day) |
| sufficient capacity | sum of table capacities >= count of eligible guests |
| likely duplicate | the exact matching rule (normalized name, or email) |
| explicitly authorize | clicks Confirm in the dialog that names the rule |
| silently | (delete the word; state what is shown) |
| such as, including | the full list, or the membership rule |
| the user | Owner, Editor, or Viewer |
| reasonable, quickly, fast | the number of milliseconds and the percentile |

## Running the check

```bash
scripts/check-requirements.sh docs/requirements.md docs/decisions.md
```

Exit 0 means every mechanical rule holds. Rules 5, 6, 7, and 11 are
reviewed by a person; the script cannot judge them.

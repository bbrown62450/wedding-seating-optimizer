---
name: linting-requirements
description: Use when a requirements document, PRD, user story, or acceptance criteria will be handed to an AI agent to implement, or when someone asks whether requirements are clear, ambiguous, testable, or "AI-ready". Also use before running a build or evaluation workflow against a spec.
---

# Linting Requirements

## Overview

A requirement passes when two engineers who have never met would build the same thing from it. The output of this skill is a findings table where every row carries a replacement sentence, not a prose review and not a list of questions.

## When to use

- A spec is about to be fed to an agent, a workflow, or a contractor.
- Someone asks "are these requirements good enough?"
- A build produced something the author did not expect and the spec is suspected.

Do not use for code review, or for documents with no numbered requirements (lint the structure first: give every requirement an id).

## Procedure

1. Run the mechanical check and paste its output verbatim as the first section of the report:
   ```bash
   .claude/skills/linting-requirements/check.sh <requirements.md> [decisions.md]
   ```
   It flags banned relative words, unnamed actors, requirements without a `Verify by:` line, `Proposed` tags, unknown decision ids, and em dashes. Run `--help` for the word list.
2. Read every numbered requirement and ask the seven judgment questions below. The script cannot ask them.
3. Write the report in exactly the shape under Report contract. One row per problem; a requirement with three problems gets three rows.
4. Only when asked to fix: edit the source keeping every id and its order, add new ids after the last one, then rerun the check until it exits 0.

## Judgment questions

| Question | If no, Kind |
|---|---|
| Is every quantity a number with a unit, a count, or a matching rule? | Define |
| Is every list closed (no "such as", "including", "etc")? | Define |
| Is the actor a named role? | Actor |
| When the requirement can fail, is the failure behavior stated (error shown, state preserved)? | Fail |
| Does the sentence make exactly one testable claim? | Split |
| Is there an observable check a test could run? | Verify |
| Does the requirement depend on a product choice the author has not made? | Decide |

## Report contract

```markdown
## Mechanical check
<check.sh output, verbatim>

## Findings
| Id | Quoted phrase | Kind | Proposed wording |
|---|---|---|---|
| FR-012 | "sufficient capacity" | Define | Sufficient capacity: the sum of table capacities is greater than or equal to the count of eligible guests. |

## Decisions needed
1. <question>. Options: <A> or <B>. Default: <A>, because <one clause>.

## Terms to define
- <term>: <proposed definition>
```

Proposed wording is a complete replacement sentence the author can paste. "Clarify X" and "specify Y" are not proposed wording. Every Decide row also appears under Decisions needed with a default; a question without a default is a finding without a fix.

## Common mistakes

- Writing the review as prose with a verdict paragraph. The reader wants rows to act on.
- Asking the author ten questions and stopping. Pick a default for each and let the author overrule it.
- Marking "define" when the real problem is a product decision the author has not made, or the reverse.
- Renumbering requirements during a fix. Ids are how the team talks about the document.
- Editing the source when only a report was requested.

---
name: triage-assessment
description: This skill should be used when assessing todo validity and priority during automated triage. It standardizes recommendation decisions and idempotent assessment section updates.
---

# Triage Assessment Skill

Apply a consistent, evidence-based rubric to todo files and write standardized assessment sections.

## Use Cases

Use this skill when:

- Running `/triage-automated`
- Evaluating `todos/*-pending-*.md` or `todos/*-ready-*.md`
- Re-assessing existing todos for MVP prioritization

## Rubric

Score each todo using these three dimensions:

- **Validity**
  - **High:** Clear, reproducible, and actionable issue/opportunity.
  - **Medium:** Plausible and actionable, but evidence is incomplete.
  - **Low:** Weakly supported, speculative, or not actionable as written.

- **Severity**
  - **High:** Material user/business/system impact if true.
  - **Medium:** Noticeable impact with workarounds.
  - **Low:** Minor impact, mostly polish or edge-only.

- **Likelihood**
  - **High:** Happens frequently or in common flows.
  - **Medium:** Happens occasionally under realistic conditions.
  - **Low:** Rare or highly constrained.

## Recommendation Mapping

Use this deterministic decision order (top-to-bottom). First match wins:

1. **Cut** when **Validity = Low**.
2. **Build now** when **Severity = High** and **Likelihood = Medium or High** and **Validity != Low**.
3. **Build soon** when **Severity = Medium** and **Likelihood = High** and **Validity != Low**.
4. **Build soon** when **Severity = High** and **Likelihood = Low** and **Validity = High**.
5. **Defer** for all remaining combinations.

Interpretation notes:

- `Validity = Medium` never auto-promotes an item above `Build soon`.
- `Likelihood = Low` is a strong signal for `Defer` unless Severity is High and Validity is High.
- If confidence is weak between adjacent outcomes, choose the lower urgency option.

## Effort Review Rules

Review each option in `## Proposed Solutions`:

1. Confirm or adjust effort (`Small`, `Medium`, `Large`).
2. Keep justification to one short line per option.
3. Prefer conservative estimates when dependencies or unknowns exist.
4. If a todo has one option, assess that one option only.

## Idempotent Update Rules

When updating a todo file:

1. Add or replace `## Triage Assessment`.
2. Add or replace `## Implementation Effort Review`.
3. Replace existing section content in place; do not duplicate headings.
4. Preserve all unrelated content (frontmatter, other sections, work logs).

Use exactly this section structure:

```markdown
## Triage Assessment

- **Validity:** High | Medium | Low
- **Severity:** High | Medium | Low
- **Likelihood:** High | Medium | Low
- **MVP Recommendation:** Build now | Build soon | Defer | Cut
- **Rationale:** 2-4 sentences grounded in problem statement, findings, and risk.

## Implementation Effort Review

- **Option 1 - <name>:** Confirmed/Adjusted to Small | Medium | Large - <brief justification>
- **Option 2 - <name>:** Confirmed/Adjusted to Small | Medium | Large - <brief justification>
- **Option 3 - <name>:** Confirmed/Adjusted to Small | Medium | Large - <brief justification>
```

If fewer options exist, include only existing options.

## Output Expectations for Automated Triage

At run completion, provide grouped rollup buckets:

- Do now (Build now)
- Do soon (Build soon)
- Defer
- Cut candidates

Include counts for assessed, updated, unchanged, and cut candidates.

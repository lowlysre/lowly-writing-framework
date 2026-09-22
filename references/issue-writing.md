# Issue titles, template selection, related-work references

Loaded from `SKILL.md` when drafting or editing an issue body. Body-structure rules shared with PR bodies (fill-template, Context section, length ceiling, diagrams) live in `references/body-writing.md`, read both before drafting a substantial issue body.

## Titles

Defer to the local repo's convention first: check its issue templates and recently filed issues for a prefix scheme (`[Bug]`, `[Feature]`) or a plain descriptive style. Absent a convention, default to a short, present-tense description of the problem or ask, no trailing period, no emoji, 4-10 words: `login redirects to a blank page after SSO logout`, not `Fix login redirect bug`.

## Template selection

A repo with more than one issue template needs a form guess before anything else. Check `.github/ISSUE_TEMPLATE/` (or a legacy `.github/ISSUE_TEMPLATE.md`) for the templates on offer and pick the one that actually matches the ask, a bug report isn't a feature request wearing a different heading. When two templates could plausibly fit, or the repo has none and the ask is non-trivial, ask the user rather than guessing. Per `references/body-writing.md`'s Body structure section, fill only what the chosen template asks for, leave a section blank rather than writing "N/A".

For a YAML issue form (`.yml`/`.yaml` template), render each field as a `### Label` heading followed by its answer, matching the form's own field order.

## Related work

An issue doesn't carry closing keywords itself, that's the PR's job pointing at the issue (see `references/pr-writing.md`'s Issue references). A related issue or PR still gets referenced with the formatting rule in `SKILL.md` Formatting: plain text, no backticks, always the full `owner/repo#123` form.

## Proposed solutions

The body states the problem or ask, per `references/body-writing.md`'s why-over-how rule, not how to fix it. A specific proposed fix, an implementation sketch, or "here's the change I'd make" belongs in a separate top-level comment (`gh issue comment <n> --body-file solution.md`), not folded into the body alongside the problem statement. Keeping them apart lets the body stay the stable reference for what's wrong while a comment thread can hold several competing proposals, or one that gets revised, without rewriting the description each time. This doesn't apply to a template whose whole point is a solution ask (a feature request template's "describe the solution you'd like" field, an EARS requirements doc), there the proposal is the body's actual content, not an addition to a problem statement.

## Context section

`references/body-writing.md`'s `## Context` section applies to issues, but for an issue specifically don't add it off a hunch that "this feels like part of something bigger." Confirm it mechanically: `gh issue view <this-issue> --json parent --jq .parent.number` finds the parent tracking issue (empty output means there isn't one), then `gh issue view <parent> --json subIssues --jq .subIssues.totalCount` counts how many sibling sub-issues that parent has. Two or more siblings is the actual tell that this issue is one slice of a larger, actively-decomposed effort and earns the section. A parent listing only this one sub-issue is a single "part of X" relationship, not a larger effort with peers, skip the section per body-writing.md's own carve-out for a standalone issue with no wider context. Once the tell fires, write the section itself exactly as body-writing.md describes: the effort and this item's place in the sequence, two short paragraphs max.

## AI watermark

Skip it. The `## AI watermark` rule in `references/pr-writing.md` applies to PR bodies and PR/review comments only, not issue bodies.

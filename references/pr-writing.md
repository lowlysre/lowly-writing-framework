# PR titles, issue-closing rules, testing, author annotations, AI watermark

Loaded from `SKILL.md` when drafting or editing a PR title or body. Body-structure rules shared with issue bodies (fill-template, Context section, length ceiling, diagrams) live in `references/body-writing.md`, read both before drafting a substantial PR body.

## Titles

Defer to the local repo's convention first: check CONTRIBUTING, PR templates, and recent merged titles (imperative-mood-with-module-prefix, bracket-tag schemes, etc.). Absent a convention, default to conventional commits (`fix:`, `feat:`, `chore:`, `docs:`, `test:`, lowercase after the colon). 4-10 words, no trailing period, no emoji, no version numbers except dependency bumps.

## Issue references

**Issue link goes inline when a sentence carries it, standalone when none does.** `Guards the rotation step, fixes owner/repo#4512` beats a trailer line whenever the fix has a natural home in a sentence, but a standalone `Closes owner/repo#123` line (first or last) is fine at any body size, don't contort a sentence just to embed it.

**Every issue reference closes, no exceptions.** Use `fixes`/`closes`/`resolves owner/repo#123` for the issue the PR addresses, same-repo or cross-repo, even when manual follow-up steps remain, listing those steps in the body doesn't downgrade the link to `Part of owner/repo#123` or `Relates to owner/repo#123`. There's no such thing as a justified non-closing reference: `Part of owner/repo#123`/`Relates to owner/repo#123` is never correct, full stop. Write the reference plain, never in backticks, GitHub only autolinks `owner/repo#123` as one contiguous run: wrapping the whole thing in code formatting turns it into inert text, and so does wrapping only the `owner/repo` part and leaving `#123` bare next to it, that split is still not a single autolinkable run. Text with the right keyword still isn't proof the link took, verify it against the API per `references/self-check.md`'s mechanical checks.

**When this PR only covers a slice of an issue, narrow the issue instead of the link.** Don't reach for `Part of owner/repo#123` because the PR won't fully resolve the parent, that trades an explicit link for a vague one. File (or reuse) a sub-issue scoped to exactly what this PR delivers, link the sub-issue under the parent tracking issue, and close the sub-issue from this PR with a normal keyword. The parent stays open and shows the relationship through the sub-issue, the PR still gets its explicit close. If no issue at all exists yet for a PR, the same rule applies: make one scoped to what the PR does (asking the user first if scope or ownership is unclear), don't ship a PR with no closing reference.

## Testing section

Absent a template, the heading is `## Testing`, not a bolded `**Testing:**` label or any other variant.

Be honest, this is non-negotiable. Say when tests were added and move on. If testing is hard or missing, say why, but only against a concrete test, script, or documented manual QA step that exists and wasn't run, a fixture the suite lacks, a manual step the runbook calls for that got skipped this time. Don't invent a higher bar the project never held itself to: "couldn't fully end-to-end test this" with no named e2e suite behind it is manufactured doubt, not honesty, skip it. Never write generic "all tests pass" prose or fabricate verification steps. Leave honest unchecked boxes; don't tick inapplicable items. Skip mentioning local checks CI already runs, only call out what CI doesn't cover: check the repo's CI config for what already runs on every push before writing a sentence like "ran `uv run pytest`" or "ran the linter locally", a check CI re-runs on this PR anyway is redundant proof, not honesty. Reserve the section for what CI can't see: manual exploratory steps actually taken, or a real, nameable gap in coverage.

A claim can be true when written and stale by the time the PR is pushed; the self-check in `references/self-check.md` covers re-verifying claims against the current diff.

A gap that carries real risk, an untested rollback path, a manual step that has to run in the right order, earns a `> [!WARNING]` or `> [!CAUTION]` admonition instead of a footnote sentence. A gap that's just inconvenient (no fixture for an edge case) stays a plain sentence.

Manual steps someone must run around the merge get their own short section (`## Pre-merge` / `## Post-merge (manual)`, heading not a bolded label) with an unchecked box per step for the operator to tick, not prose buried in Testing.

## Author annotations

A small aside about a specific line or file, one that doesn't change a reviewer's verdict, goes in a review comment the author leaves on that line instead of in the body. The body stays on the primary change, and a reviewer who lands on the line still finds the explanation. It also keeps a tiny edit from reading as accidental or sloppy to a human or AI reviewer.

- Annotations are the default, not an opt-in. Drafting a body includes reading the diff for line-anchored asides and for scope beyond the linked issue (bundled cleanups, dead-code removal, a changed default, a dropped workflow step). Each one is written as an annotation and kept out of the body. They can't be posted until the PR exists and its head is pushed, so post them right after the create call, without waiting to be asked. A PR you're creating for the user is theirs by construction; on an existing PR, check authorship first
- Determine authorship before posting annotations on an existing PR: `gh pr view <n> --json author -q .author.login` against `gh api user -q .login`. Same login means these rules apply. A different login means you're reviewing, so use `references/review-comments.md` instead
- The test is whether the aside explains a place or the PR. A line-anchored aside is an annotation, a PR-wide point stays in the body
- Typical fits: a mechanical edit repeated across files, an incidental tweak (a pinned version, a renamed variable, a reordered block), a value that's temporary until something lands, a change bundled in beyond the linked issue. A one-line `Bonus` bullet that names a specific line moves here once the body is crowded; in a short body it can stay as the bullet, but a bundled change in a file the issue never mentions gets its annotation either way
- A detail trimmed from the body to meet the length ceiling in `references/body-writing.md` moves to an annotation when it's line-anchored, rather than disappearing
- Never move anything from the `Never trim these` list in `SKILL.md`. Breaking changes, migration steps, risk, and known gaps stay in the body, a reviewer who skips the Files changed tab would miss them
- A lasting explanation of why the code looks the way it does belongs in a code comment, per `references/docs-and-comments.md`. An annotation carries what only matters while this PR is under review
- One annotation per distinct point. A repeated change gets one comment on the first occurrence saying how many other places match, not a comment per file
- Anchor it on the lines the note explains: a multi-line range (`start_line` through `line`) when it's about a block, so the UI highlights what it references. Never the line above it. Only lines in the diff can carry a comment, and both ends of a range must sit in the same hunk
  - A deleted block has no right-side lines. Anchor on the deleted lines themselves with `side=LEFT` (and `start_side=LEFT`), using their line numbers in the base file. Fall back to an adjacent context line only when the API rejects it, and then say "the block below" or "the block above" in the note
- Start it with `note:` and keep it to a sentence or two. The reviewer labels from `references/review-comments.md` aren't needed otherwise
- Append the `<!--:robot:-->` watermark per the rule below, on its own last line
- Post them after the PR exists and its head is pushed, as standalone line comments, one per annotation. An author doesn't leave a review, so never a pending review, and never `add_pr_review_comment`: that tool stages into a pending review and is for reviewing someone else's PR. Post through `gh api`, see `Author annotations` in `references/gh-cli.md`

## AI watermark

Append `<!--:robot:-->` as its own line at the very end of every PR body, after any `<details>` block or trailer, GitHub renders an HTML comment as nothing, so it marks the body as AI-authored without costing the reader any attention. Applies to PR bodies and PR/review comments only, not README/doc prose, code comments, or issue bodies/comments, those aren't in scope. Same rule for review comments lives in `references/review-comments.md`.

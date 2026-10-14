# PR review comments

Loaded from `SKILL.md` when drafting or posting a review comment on someone else's PR.

Same structural rules as everywhere: why over how, one point per sentence. Label every comment using [conventional comments](https://conventionalcomments.org/): `praise:`, `nitpick:`, `suggestion:`, `issue:`, `question:`, `thought:`, `chore:`, `note:`. Add a decoration when it changes how the author should act, `suggestion (non-blocking):`, `issue (security):`.

- Labels are plain text: `issue:`, not bolded or backticked. `issue:` and `suggestion:` are blocking by default, so mark non-blocking ones explicitly; a `(blocking)` decoration is noise, only the non-default decoration earns ink
- One comment, one point, don't stack unrelated feedback in a thread
- `suggestion:` says what to change and why; use a GitHub suggested edit (see `Suggested edits` below) for a few-line fix
- `question:` is a real question, not a suggestion wearing a question mark. If you already know the answer you want, use `suggestion:` instead
- Review the change the author is actually trying to make, not just the line they touched. When the diff solves the literal ask but misses the real problem, name that before nitpicking mechanics
- Probe before you prescribe on risky changes: one or two sharp `why` questions beat a barrage of directives
- `nitpick:` is always non-blocking, don't pile them on
- `praise:` is fine and encouraged when earned, one line, no gushing
- The label already carries severity (`issue (security):`); don't also wrap the body in a `> [!WARNING]` admonition
- Append `<!--:robot:-->` as the last line, per the `## AI watermark` rule in `references/pr-writing.md`

## Review order and priorities

- Read the PR body and decide whether the change should exist at all before reading code. If not, say so first, with what to do instead, so the author doesn't polish work that gets thrown away
- Review the main file first, then the rest. When the design is wrong, post that comment immediately instead of finishing the pass, since most line comments disappear with the redesign
- Weigh design, behavior, needless complexity, tests that would actually fail on a regression, and docs the change makes stale before naming and style. Flag speculative generality (`suggestion:` to solve today's problem) as complexity, not polish
- The agent drafts comments only; the approve, request-changes, or merge verdict is the user's
- When you couldn't follow the code, ask for it to be rewritten clearer or commented in the code, not explained in the thread. An explanation that lives only in the review is lost to the next reader
- Style the repo doesn't specify follows the surrounding code, and the author's choice when nothing surrounds it. Several valid designs: accept the author's, don't argue preference
- A comment about the code, not the author: "this adds a thread with no measured benefit", not "why did you add a thread"
- `praise:` names what was good and why, so the author repeats it

## Delivery mode

"Leave comments" means one of three things. Pick the mode before drafting, because it decides the tool and whether a pending review exists:

- Staged review comments: the user asks to review, stage, or leave review comments on a PR the session is linked to. Use `add_pr_review_comment`; the comments sit in a pending review the user submits
- Annotated line comments: the user says not to stage, or wants comments posted now, or the session has no linked PR. Post each with the `gh api .../pulls/<n>/comments` call in `references/gh-cli.md`; each lands immediately as its own single-comment review
- PR-level comment: the point isn't tied to a line, or spans several files. Post with `gh pr comment --body-file`, labeled the same way

Anchor every finding that points at a line in the diff to that line, one comment each. Never fold several line-level findings into one PR-level comment: threads can't be resolved individually, suggested edits can't be applied, and the author has to hunt for the lines. A PR-level comment carries only cross-cutting points. When it carries more than one, give each its own labeled bullet or short heading, not a run of paragraphs.

A missing PR link only rules out `add_pr_review_comment`, not posting. When the user names a PR, fall back to `gh` instead of stopping at drafts; ask only when the PR itself is ambiguous. A later "don't stage" or "just comment" from the user switches the mode for every comment already drafted.

## Suggested edits

A suggested edit is a `suggestion` fenced block inside a line comment on the PR's **Files changed** tab. The author applies it with **Commit suggestion** (or batches several into one commit), and GitHub credits the reviewer as co-author. Reach for one when the fix is mechanical and the exact replacement text is known.

- The block replaces exactly the lines the comment is anchored to, so anchor it on the lines being replaced: one line for a single-line fix, a line range for a multi-line one. Anchor on the wrong lines and applying it clobbers code the reviewer never meant to touch
- Write the full replacement lines, indentation included. The block's content is swapped in verbatim, so a dropped leading space or tab lands in the file
- An empty `suggestion` block deletes the anchored lines
- Keep the `suggestion:` label and its one-sentence why above the block. The block shows what, the sentence says why
- Keep a suggestion to about 5 anchored lines. Past that, the block is hard to review inline, easy to apply wrongly, and goes stale on the author's next push. Describe a larger change in a plain `suggestion:` comment, or split it into separate comments that each stand alone
- Only lines in the diff can carry one. Code outside the diff, or a point spanning several files, gets a plain `suggestion:` describing the change
- A suggestion in a pending (unsubmitted) review can't be applied yet, and one on a resolved, outdated, or closed-PR thread can't be applied at all
- One suggestion block per comment; two edits to different lines are two comments
- To show a code fence inside a suggestion, open and close the block with four backticks so the inner three-backtick fence doesn't end it early
- Don't suggest an edit to a file the author doesn't control (generated output, a lockfile, vendored code). Fix the source and say so

````markdown
suggestion: Use the constant so a timeout change lands in one place.

```suggestion
    timeout: DEFAULT_TIMEOUT_MS,
```
````

Through `add_pr_review_comment`, pass the block in `body`, set `line` to the last anchored line and `startLine` to the first for a range. Through `gh`, see `Suggested edits` in `references/gh-cli.md`.

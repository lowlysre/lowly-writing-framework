# PR review comments

Loaded from `SKILL.md` when drafting or posting a review comment on someone else's PR.

Same structural rules as everywhere: why over how, one point per sentence. Label every comment using [conventional comments](https://conventionalcomments.org/): `praise:`, `nitpick:`, `suggestion:`, `issue:`, `question:`, `thought:`, `chore:`, `note:`. Add a decoration when it changes how the author should act, `suggestion (non-blocking):`, `issue (security):`. Unlabeled `issue:`/`suggestion:` read as blocking, so mark non-blocking ones explicitly.

- Labels are plain text: `issue:`, not bolded or backticked. `issue:` and `suggestion:` are blocking by default, so a `(blocking)` decoration is noise; only the non-default decoration earns ink
- One comment, one point, don't stack unrelated feedback in a thread
- `suggestion:` says what to change and why; use a GitHub suggested edit (see `Suggested edits` below) for a few-line fix
- `question:` is a real question, not a suggestion wearing a question mark. If you already know the answer you want, use `suggestion:` instead
- Review the change the author is actually trying to make, not just the line they touched. When the diff solves the literal ask but misses the real problem, name that before nitpicking mechanics
- Probe before you prescribe on risky changes: one or two sharp `why` questions beat a barrage of directives
- `nitpick:` is always non-blocking by definition, don't pile them on
- `praise:` is fine and encouraged when earned, one line, no gushing
- Review comments already carry severity through the label (`issue (security):`); don't also wrap the body in a `> [!WARNING]` admonition, that's marking the same thing twice
- Append `<!--:robot:-->` as the last line, per the `## AI watermark` rule in `references/pr-writing.md`

## Suggested edits

A suggested edit is a `suggestion` fenced block inside a line comment on the PR's **Files changed** tab. The author applies it with **Commit suggestion** (or batches several into one commit), and GitHub credits the reviewer as co-author. Reach for one when the fix is mechanical and the exact replacement text is known.

- The block replaces exactly the lines the comment is anchored to, so anchor it on the lines being replaced: one line for a single-line fix, a line range for a multi-line one. Anchor on the wrong lines and applying it clobbers code the reviewer never meant to touch
- Write the full replacement lines, indentation included. The block's content is swapped in verbatim, so a dropped leading space or tab lands in the file
- An empty `suggestion` block deletes the anchored lines
- Keep the `suggestion:` label and its one-sentence why above the block. The block shows what, the sentence says why
- Keep a suggestion to about 5 anchored lines. Past that, the block is hard to review inline, easy to apply wrongly, and goes stale on the author's next push. Describe a larger change in a plain `suggestion:` comment, or split it into separate comments that each stand alone
- Only comment lines that appear in the diff can carry one. Code outside the diff, or a point spanning several files, gets a plain `suggestion:` describing the change
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

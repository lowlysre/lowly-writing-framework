# PR review comments

Loaded from `SKILL.md` when drafting or posting a review comment on someone else's PR.

Same structural rules as everywhere: why over how, one point per sentence. Label every comment using [conventional comments](https://conventionalcomments.org/): `praise:`, `nitpick:`, `suggestion:`, `issue:`, `question:`, `thought:`, `chore:`, `note:`. Add a decoration when it changes how the author should act, `suggestion (non-blocking):`, `issue (security):`. Unlabeled `issue:`/`suggestion:` read as blocking, so mark non-blocking ones explicitly.

- Labels are plain text: `issue:`, not bolded or backticked. `issue:` and `suggestion:` are blocking by default, so a `(blocking)` decoration is noise; only the non-default decoration earns ink
- One comment, one point, don't stack unrelated feedback in a thread
- `suggestion:` says what to change and why; use a GitHub suggestion block for a few-line fix
- `question:` is a real question, not a suggestion wearing a question mark. If you already know the answer you want, use `suggestion:` instead
- Review the change the author is actually trying to make, not just the line they touched. When the diff solves the literal ask but misses the real problem, name that before nitpicking mechanics
- Probe before you prescribe on risky changes: one or two sharp `why` questions beat a barrage of directives
- `nitpick:` is always non-blocking by definition, don't pile them on
- `praise:` is fine and encouraged when earned, one line, no gushing
- Review comments already carry severity through the label (`issue (security):`); don't also wrap the body in a `> [!WARNING]` admonition, that's marking the same thing twice
- Append `<!--:robot:-->` as the last line, per the `## AI watermark` rule in `references/pr-writing.md`

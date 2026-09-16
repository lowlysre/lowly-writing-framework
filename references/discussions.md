# Discussion posts, comments, and answers

Loaded from `SKILL.md` when drafting or editing a GitHub Discussion: the opening post, a comment or reply on one, or marking a comment as the answer. Body-structure rules shared with PR and issue bodies (fill-template, Context section, length ceiling, diagrams) live in `references/body-writing.md`, read it alongside this file before drafting an opening post. The `gh discussion` and GraphQL mechanics live in `references/gh-cli.md`'s Discussions section.

## Category selection

Every discussion lands in exactly one category, and the category decides what the post is for: a question expecting an answer (an answerable category, usually `Q&A`), a proposal (`Ideas`), a maintainer broadcast (`Announcements`), a vote (`Polls`), or open-ended conversation (`General`, `Show and tell`). List the repo's categories with `gh api graphql` per `references/gh-cli.md`, the `isAnswerable` flag on each tells you whether the Answers rules below apply. Pick the category that matches the ask, a question isn't an idea wearing a question mark. When two categories could plausibly fit, ask the user rather than guessing.

Check `.github/DISCUSSION_TEMPLATE/<category-slug>.yml` for a category form. GitHub renders that form in the browser, `gh discussion create` doesn't, so fill it yourself in the body: each field as a `### Label` heading followed by its answer, in the form's own field order, same as a YAML issue form in `references/issue-writing.md`. Fill only what the form asks for, per `references/body-writing.md`'s Body structure section.

## Titles

In an answerable category, the title is the question itself, ending in `?`: `does the rotation job retry on a 429 from the secrets backend?`, not `rotation job retry behavior`. A reader scanning Q&A decides whether they can answer from the title alone, a topic label makes them open it to find out.

Everywhere else, follow the issue-title rules in `references/issue-writing.md`: defer to the repo's convention, otherwise a short present-tense description, no trailing period, no emoji, 4-10 words.

## Opening post

`references/body-writing.md` applies in full: fill the category form or use the lightweight `## Summary` fallback, motivation first, `## Context` at the top when there's a wider effort, the 3-paragraph and 3,000-character ceilings.

A question in an answerable category is a bug report until proven otherwise, so the `Never trim these` list in `SKILL.md` applies: the exact error text, what was tried, the version or commit in play. An answerer can't reproduce a paraphrase.

## Comments and replies

A discussion comment is prose, not a code review. Don't open it with a Conventional Comments label (`suggestion:`, `question:`), those belong on PR review comments per `references/review-comments.md`. `SKILL.md` Formatting still applies in full: one point per sentence, paragraphs by topic, backticks on identifiers, full `owner/repo#123` references.

Reply in the thread when responding to a specific comment (`gh discussion comment <comment-url>`), and post a top-level comment (`gh discussion comment <number>`) only when addressing the opening post or the whole discussion. A reply posted as a top-level comment loses the thread it's answering and reads as a non sequitur to the next reader.

One comment, one point. Two unrelated responses to two different comments are two replies, not one comment quoting both.

## Answers

Only an answerable category has an answer to mark. Mark the comment that actually resolves the question, not the asker's "that worked, thanks" reply and not a comment that merely links elsewhere. When the resolving comment is a reply deep in a thread, mark that reply, GitHub surfaces it at the top regardless of depth.

Marking an answer is GraphQL-only (`markDiscussionCommentAsAnswer`, `unmarkDiscussionCommentAsAnswer`), as is closing a discussion with a reason (`closeDiscussion` with `RESOLVED`, `OUTDATED`, or `DUPLICATE`), see `references/gh-cli.md`. Don't close a discussion that has an answer marked unless the category also expects closing, marking the answer already changes its rendered state.

## Related work

Discussions share the repo's number sequence with issues and PRs, so the `owner/repo#123` formatting rule in `SKILL.md` autolinks a discussion the same way: plain text, no backticks, always the full form.

A PR can't close a discussion. `closes owner/repo#123` pointing at a discussion number is inert, and `closingIssuesReferences` won't report it. When a discussion turns into work, file an issue scoped to that work (or convert the discussion in the browser, GitHub has no API for that), and close the issue from the PR per `references/pr-writing.md`'s Issue references. A comment on the discussion pointing at the new issue is enough to link them.

## AI watermark

Skip it. The `## AI watermark` rule in `references/pr-writing.md` applies to PR bodies and PR/review comments only, not discussion posts or comments.

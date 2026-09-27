# Discussion posts, replies, answers, upvotes

Loaded from `SKILL.md` when drafting or editing a GitHub Discussion post, a discussion comment or reply, or marking an answer. The `gh`/GraphQL mechanics for all of these live in `references/gh-cli.md`'s Discussions section; this file covers what the artifact contains. The opening post also follows `references/body-writing.md`, read both before drafting a substantial post.

## Category selection

Pick the category before drafting, the category decides whether the discussion can have an answer at all. List the repo's categories with their `isAnswerable` flag using the GraphQL query in `references/gh-cli.md`, and pick the one that matches the ask: a how-do-I question goes in the answerable Q&A category, not `General`. When two categories plausibly fit, ask the user rather than guessing.

- An Announcement-format category only accepts new posts from maintainers and admins. Don't draft a post there for a user without that access, pick another category or ask
- A category form lives at `.github/DISCUSSION_TEMPLATE/<category-slug>.yml`, the filename matching the category's slug. Render it the same way as a YAML issue form per `references/issue-writing.md`'s Template selection section: each field as a `### Label` heading followed by its answer, in the form's own field order. Forms are YAML only, there's no markdown discussion template
- Polls can't be created through the API (`createDiscussion` has no poll field) and category forms don't apply to them. When the user wants a poll, draft the title, question, and options, then hand them over to post in the UI

## Titles

In an answerable category, the title is the question itself, ending in `?`: `How do I pin a reusable workflow to a SHA?`, not `Reusable workflow pinning`. A reader scanning the list should know what's being asked without opening it. In any other category, use the issue title rules in `references/issue-writing.md`.

## Opening post

Follow `references/body-writing.md` for structure, same as an issue body. A Q&A post is a bug report without a template, so the `Never trim these` list in `SKILL.md` applies in full: the exact error text, what was already tried, and the version of every tool in play. A question missing those gets a round-trip asking for them before anyone can answer it.

## Comments and replies

Discussion threads are two levels deep: a top-level comment, then replies under it. A reply can't have replies of its own.

- Prose only, no Conventional Comments labels, those belong to PR review comments per `references/review-comments.md`
- Respond to an existing comment as a reply in its thread, not as a new top-level comment. A top-level comment is for a new answer or a new point about the opening post
- One comment, one point, except when answering, per Answering below
- Never post a "+1", "same here", or "any update?" comment. Upvote the discussion or top-level comment instead, per Upvotes and reactions below

## Answering

Lead with the answer, then the reasoning or steps behind it. A reader landing from search reads the marked answer first and may read nothing else.

When the answer responds to one specific line in a long post, quote only that line with `>` and answer directly below it in plain, unquoted text. Quote the sentence being answered, never the whole post, and never blockquote the answer itself. This is the same shape as `references/body-writing.md`'s Anticipated reviewer questions section.

A post asking several questions gets one comment answering all of them, not one comment per question. Only one comment per discussion can be marked as the answer, so splitting the answers leaves all but one unmarked. Inside that comment, give each question its own `>` quote followed by its answer, in the order the post asked them:

```markdown
> Does the cache survive a runner restart?

No. It's keyed to the workflow run, a new run starts cold.

> Can I share it across repos?

Only through an artifact upload in one repo and a download in the other.
```

## Marking answers and closing

- Mark the comment that actually resolves the question, not the "thanks, that worked" reply under it. A threaded reply can be marked when it's the one holding the resolution. A minimized comment can't be marked
- If the resolution came from somewhere outside the thread (a PR, a release, a doc), post a comment stating it with the link, then mark that comment. Don't leave the answer only in a closing reason
- Marking an answer doesn't close the discussion. Close only when the thread is finished, with the reason that matches: `RESOLVED` for a non-answerable category whose ask is settled, `OUTDATED` when the question is out of date, `DUPLICATE` with a comment linking the discussion it duplicates
- Only the discussion author and users with triage access or above can mark an answer. Don't offer to mark one for a user who can't

## Upvotes and reactions

Upvotes work on discussions and top-level comments and sort the list by what matters to the community. Reactions work on every comment and reply and carry no ranking weight.

- Upvote instead of posting agreement as a comment. On a reply, which can't be upvoted, use a reaction instead
- An upvote or reaction is attributed to the user, same as a comment. Only add one when the user asks for it, never as a side effect of reading a thread

## Related work

Discussions share the repo's number sequence with issues and PRs, so `owner/repo#123` autolinks a discussion the same way, and the full-form rule in `SKILL.md` Formatting applies on every mention. A PR's closing keyword can't close a discussion, though. When a discussion turns into work, file an issue referencing it and have the PR close the issue.

## AI watermark

Skip it, same as issue bodies. The `## AI watermark` rule in `references/pr-writing.md` applies to PR bodies and PR/review comments only.

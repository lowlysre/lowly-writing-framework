# Discussion posts, comments, answers, upvotes

Loaded from `SKILL.md` when drafting or editing a GitHub Discussion post, a discussion comment or reply, or marking an answer. The `gh`/GraphQL mechanics for all of these live in `references/gh-cli.md`'s Discussions section; this file covers what the artifact contains. The opening post follows `references/body-writing.md`, same as an issue body.

## Kinds of post

Decide what the post is for before picking a category, the kind decides where it goes and how the thread ends:

- Question: needs one resolving answer
- Proposal or idea: needs feedback, and eventually a decision
- Announcement: informs, no reply needed to succeed
- Show and tell, poll, or open conversation: shares something, asks for a pick, or raises a topic without a defined outcome

These are kinds of post, not category names. When the user asks for a discussion about something already ready to work on, a bug with a reproduction or a scoped feature, say it belongs in an issue before drafting.

## Before posting

Search first: `gh discussion list --search "<terms>" --state all` and `gh issue list --search "<terms>" --state all`. When a hit covers the topic, point the user to it instead of drafting. When a near-miss doesn't, link it in the new post and say in one sentence how this one differs, so it isn't closed as a duplicate. Announcements are the exception, a new release gets its own post.

## Category selection

Don't assume a category exists by name. The defaults a repo starts with (General, Q&A, Ideas, Show and tell, Polls, Announcements) get renamed, deleted, and joined by custom ones. List the repo's actual categories with the GraphQL query in `references/gh-cli.md` and pick by each one's `description`, which outranks its name: a custom `Plugins` category described as "questions and ideas about plugins" takes a plugin proposal over a generic ideas category.

- `isAnswerable` only matters for a question: put it in an answerable category when one fits, so an answer can be marked. Don't put a proposal or conversation there just because it exists, the thread shows "unanswered" forever
- When two categories plausibly fit, or none clearly does, ask the user. Pass the category's `slug` to `--category`, it's stable across renames
- An Announcement-format category only accepts posts from maintainers and admins, and the API doesn't expose a category's format. A permission error from `gh discussion create` is the likely cause: pick another category or ask, don't retry
- A category form lives at `.github/DISCUSSION_TEMPLATE/<category-slug>.yml`, check for one after picking. Render it like a YAML issue form per `references/issue-writing.md`'s Template selection section: each field as a `### Label` heading followed by its answer, in the form's field order
- Polls can't be created through the API. Draft the title, question, and options, then hand them to the user to post in the UI
- `hasDiscussionsEnabled: false` from the same query means discussions are off. Say so rather than falling back to an issue unasked

## Titles

A question's title is the question itself, ending in `?`, with whatever tells it apart from similar ones: `Why does actions/cache miss on every run after a runner image update?`, not `Cache problems`. Anything else uses the issue title rules in `references/issue-writing.md`.

## Comments and replies

Threads are two levels deep: a top-level comment, then replies under it. A reply can't have replies of its own.

- No Conventional Comments labels, those belong to PR review comments per `references/review-comments.md`
- Respond to an existing comment as a reply in its thread. A top-level comment is for a new answer, a new position, or a new point about the opening post
- When responding to one line of a long post, quote only that line with `>` and respond below it in plain text, the same shape as `references/body-writing.md`'s Anticipated reviewer questions section
- Correcting your own comment, or an announcement post: edit it so it stands on its own, fetching the live text first per `references/gh-cli.md`. A correction stacked in a reply leaves the original wrong for the next reader
- Never post a "+1", "same here", "thanks", or "any update?" comment. Upvote instead, per Upvotes and reactions below

## Answering a question

Answer the problem the asker actually has, not only the literal question. "How do I add the Debug button back in v18?" answered with "it was dropped in v18" is correct and still unhelpful; the useful answer is how to debug in v18. When the literal answer is "you can't", say what to do instead in the same comment.

A post asking several questions gets one comment answering all of them. Only one comment per discussion can be marked as the answer, so splitting them leaves all but one unmarked. Give each question its own `>` quote followed by its answer:

```markdown
> Does the cache survive a runner restart?

No. It's keyed to the workflow run, a new run starts cold.

> Can I share it across repos?

Only through an artifact upload in one repo and a download in the other.
```

## Wrapping up

Every kind except an announcement ends with its outcome written down in the thread.

- Question: mark the comment that resolves it, not the "thanks, that worked" reply under it. A threaded reply can be marked; a minimized comment can't. Only the discussion author and users with triage access or above can mark an answer
- Question resolved outside the thread (a PR, a release), or in a category that isn't answerable: post a comment stating the resolution with the link, then mark it where marking is possible
- Proposal, conversation, or poll: post a closing summary with the outcome, accepted with a link to the tracking issue, declined with the reason, or parked with what would reopen it, then close
- Close with `RESOLVED` once the outcome is posted, `OUTDATED` when the topic is out of date, `DUPLICATE` with a comment linking the thread it duplicates. Marking an answer doesn't close a discussion on its own

## Upvotes and reactions

Upvotes work on discussions and top-level comments and sort the list. Reactions work on every comment and reply and carry no ranking weight.

- Upvote instead of posting agreement or thanks. On a reply, which can't be upvoted, use a reaction
- Same problem or need as the post: upvote it, and only comment when there's new information (another version affected, a use case the proposal misses)
- An upvote or reaction is attributed to the user. Only add one when the user asks, never as a side effect of reading a thread

## Related work

Discussions share the repo's number sequence with issues and PRs, so `owner/repo#123` autolinks a discussion, and the full-form rule in `SKILL.md` Formatting applies. A PR's closing keyword can't close a discussion. When a discussion turns into work, file an issue referencing it, link the issue in the discussion's closing summary, and have the PR close the issue.

## AI watermark

Skip it: `references/pr-writing.md`'s watermark covers PR bodies and PR/review comments only.

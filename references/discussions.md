# Discussion posts, replies, answers, upvotes

Loaded from `SKILL.md` when drafting or editing a GitHub Discussion post, a discussion comment or reply, or marking an answer. The `gh`/GraphQL mechanics for all of these live in `references/gh-cli.md`'s Discussions section; this file covers what the artifact contains. The opening post also follows `references/body-writing.md`, read both before drafting a substantial post.

Question-and-answer structure here follows Stack Overflow's [How do I ask a good question?](https://stackoverflow.com/help/how-to-ask) and [How do I write a good answer?](https://stackoverflow.com/help/how-to-answer), refined by [My Mother Was StackExchange](https://lowlysre.substack.com/p/my-mother-was-stackexchange). A discussion thread outlives the person who asked it: "write like someone will read it years from now. Because odds are someone will."

## Before posting

Search first, a question already answered in the repo doesn't need a second thread. Run `gh discussion list --search "<terms>" --state all` and `gh issue list --search "<terms>" --state all` with the error text or the feature name. When a hit covers the question, point the user to it instead of drafting. When a near-miss doesn't, link it in the new post and say in one sentence why it didn't help, that's what keeps the new post from being closed as a duplicate.

## Category selection

Don't assume a category exists by name. The defaults a repo starts with (General, Q&A, Ideas, Show and tell, Polls, Announcements) are only a starting point, maintainers rename, delete, and add their own. List the repo's actual categories with their `name`, `description`, and `isAnswerable` flag using the GraphQL query in `references/gh-cli.md`, and pick by what each category says it's for, not by what its name sounds like.

- A question needing one resolving answer goes in a category where `isAnswerable` is `true`, whatever it's called (`Help`, `Support`, `Troubleshooting`). With no answerable category at all, the post still works, it just can't have an answer marked, see Marking answers below
- A category's `description` outranks its name. A custom `Plugins` category described as "questions about writing plugins" takes a plugin question even when a generic answerable category also exists
- When two categories plausibly fit, or none clearly does, ask the user rather than guessing. Pass the category's `slug` to `--category`, it's stable across renames of the display name
- An Announcement-format category only accepts new posts from maintainers and admins, and the API doesn't expose a category's format. When `gh discussion create` fails with a permission error, that's the likely cause: pick another category or ask, don't retry
- A category form lives at `.github/DISCUSSION_TEMPLATE/<category-slug>.yml`, the filename matching the category's slug, so check for one after picking. Render it the same way as a YAML issue form per `references/issue-writing.md`'s Template selection section: each field as a `### Label` heading followed by its answer, in the form's own field order. Forms are YAML only, there's no markdown discussion template
- Polls can't be created through the API (`createDiscussion` has no poll field) and category forms don't apply to them. When the user wants a poll, draft the title, question, and options, then hand them over to post in the UI
- When the same query returns `hasDiscussionsEnabled: false`, the repo has discussions turned off. Say so rather than falling back to an issue unasked

## Titles

In an answerable category, the title is the specific question itself, ending in `?`, carrying whatever tells it apart from similar questions: the error message, the tool, the unusual circumstance. `Why does actions/cache miss on every run after a runner image update?`, not `Cache problems`. Name the tool in plain words, not as a bracketed `[cache]` prefix, labels do that job. Draft the body first and the title last, the body is where the actual question gets pinned down.

In any other category, use the issue title rules in `references/issue-writing.md`.

## Opening post

Follow `references/body-writing.md` for structure, same as an issue body. For a question:

- Open with the problem in prose, expanding on the title, before any code or log. A post that starts with a code block makes the reader reverse-engineer the question from it
- Say what was already tried and why it didn't work, including the near-miss threads from Before posting
- Include a minimal reproduction: the smallest config, command, or snippet that still shows the problem, not the whole workflow file or program. Paste it into the post, a link to a gist or sandbox is fine alongside it but not instead of it
- Paste error messages, logs, and code as text in a fenced block, never as a screenshot. Screenshots are for rendering bugs and UI state only
- The `Never trim these` list in `SKILL.md` applies in full: the exact error text and the version of every tool in play
- One question per post. Two unrelated questions get two discussions, so each can have its own marked answer

## Comments and replies

Discussion threads are two levels deep: a top-level comment, then replies under it. A reply can't have replies of its own.

- Prose only, no Conventional Comments labels, those belong to PR review comments per `references/review-comments.md`
- Respond to an existing comment as a reply in its thread, not as a new top-level comment. A top-level comment is for a new answer or a new point about the opening post
- One comment, one point, except when answering, per Answering below
- Asking for clarification: one or two sharp questions as a reply, not a barrage. Ask `why` before prescribing when the request looks risky or odd, the answer to "why do you need to shrink this file?" often changes what the right answer is
- Never post a "+1", "same here", "thanks", or "any update?" comment. Upvote the discussion or the comment that helped instead, per Upvotes and reactions below

## Answering

Answer the problem the asker actually has, not only the literal question. "How do I add the Debug button back in v18?" answered with "it was dropped in v18" is correct and still unhelpful; the useful answer is how to debug in v18. When the literal answer is "you can't" or "don't do that", say what to do instead in the same comment.

- Lead with the answer, then the reasoning or steps behind it. A reader landing from search reads the marked answer first and may read nothing else
- State the assumptions and limits the answer depends on: the version it was checked against, the platform, the config it assumes
- A link that carries the answer gets its one relevant sentence quoted alongside it, per the link-rot rule in `SKILL.md` Formatting. The answer has to survive the link going dead
- Building on an existing answer: quote the part being extended or corrected and add what it's missing, don't restate the whole thing
- Correcting your own answer after feedback: edit the answer so it stands on its own, fetching the live text first per `references/gh-cli.md`. A correction stacked in a reply below leaves the marked answer wrong for the next reader
- A partial answer is still worth posting when it's labeled as one. Time-boxed and stuck, post what was found and what was ruled out as a comment, it saves the next person that ground even when it doesn't close the question

When the answer responds to one specific line in a long post, quote only that line with `>` and answer directly below it in plain, unquoted text. Quote the sentence being answered, never the whole post, and never blockquote the answer itself. This is the same shape as `references/body-writing.md`'s Anticipated reviewer questions section.

Someone else's post asking several questions gets one comment answering all of them, not one comment per question. Only one comment per discussion can be marked as the answer, so splitting the answers leaves all but one unmarked. Inside that comment, give each question its own `>` quote followed by its answer, in the order the post asked them:

```markdown
> Does the cache survive a runner restart?

No. It's keyed to the workflow run, a new run starts cold.

> Can I share it across repos?

Only through an artifact upload in one repo and a download in the other.
```

## Marking answers and closing

- Mark the comment that actually resolves the question, not the "thanks, that worked" reply under it, and not necessarily the first correct one. A threaded reply can be marked when it's the one holding the resolution. A minimized comment can't be marked
- If the resolution came from somewhere outside the thread (a PR, a release, a doc), post a comment stating it with the link, then mark that comment. Don't leave the answer only in a closing reason
- Marking an answer doesn't close the discussion. Close only when the thread is finished, with the reason that matches: `RESOLVED` for a non-answerable category whose ask is settled, `OUTDATED` when the question is out of date, `DUPLICATE` with a comment linking the discussion it duplicates
- Only the discussion author and users with triage access or above can mark an answer. Don't offer to mark one for a user who can't

## Upvotes and reactions

Upvotes work on discussions and top-level comments and sort the list by what matters to the community. Reactions work on every comment and reply and carry no ranking weight.

- Upvote instead of posting agreement or thanks as a comment. On a reply, which can't be upvoted, use a reaction instead
- Having the same problem: upvote the discussion rather than commenting, unless there's new information to add (another version affected, a narrower reproduction), then post that as a comment
- An upvote or reaction is attributed to the user, same as a comment. Only add one when the user asks for it, never as a side effect of reading a thread

## Related work

Discussions share the repo's number sequence with issues and PRs, so `owner/repo#123` autolinks a discussion the same way, and the full-form rule in `SKILL.md` Formatting applies on every mention. A PR's closing keyword can't close a discussion, though. When a discussion turns into work, file an issue referencing it and have the PR close the issue.

## AI watermark

Skip it, same as issue bodies. The `## AI watermark` rule in `references/pr-writing.md` applies to PR bodies and PR/review comments only.

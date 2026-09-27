# Discussion posts, comments, answers, upvotes

Loaded from `SKILL.md` when drafting or editing a GitHub Discussion post, a discussion comment or reply, or marking an answer. The `gh`/GraphQL mechanics for all of these live in `references/gh-cli.md`'s Discussions section; this file covers what the artifact contains. The opening post also follows `references/body-writing.md`, read both before drafting a substantial post.

## Discussion or issue

An issue is work someone can act on: a bug with a reproduction, a scoped feature. A discussion is anything not settled enough for that yet: a question, an idea still looking for a shape, an announcement, a show-and-tell, a poll, open-ended feedback. When the user asks for a discussion about something that's already ready to work on, or an issue about something that isn't, say so before drafting. When a discussion turns into work, see Related work below.

## Kinds of post

Decide what the post is for before picking a category or drafting a word, the kind sets the title, the body, and how the thread ends. Most discussions are one of:

- Question: needs one resolving answer
- Proposal or idea: needs feedback, and eventually a decision
- Announcement: informs, no reply needed to succeed
- Show and tell: shares something built with or for the project
- Poll: asks the community to pick between fixed options
- Open conversation: feedback, brainstorming, a topic without a defined outcome

These are kinds of post, not category names. A repo's categories may map one to one, lump several together, or split one kind across several categories, see Category selection below.

## Before posting

Search first, a topic already under discussion doesn't need a second thread. Run `gh discussion list --search "<terms>" --state all` and `gh issue list --search "<terms>" --state all` with the error text, the feature name, or the proposal's subject. When a hit covers it, point the user to it instead of drafting, adding to an existing thread beats splitting the conversation. When a near-miss doesn't, link it in the new post and say in one sentence how this one differs, that's what keeps the new post from being closed as a duplicate. Announcements are the exception, a new release gets its own post.

## Category selection

Don't assume a category exists by name. The defaults a repo starts with (General, Q&A, Ideas, Show and tell, Polls, Announcements) are only a starting point, maintainers rename, delete, and add their own. List the repo's actual categories with their `name`, `description`, and `isAnswerable` flag using the GraphQL query in `references/gh-cli.md`, and pick by what each category says it's for, not by what its name sounds like.

- A category's `description` outranks its name. A custom `Plugins` category described as "questions and ideas about plugins" takes a plugin proposal even when a generic ideas category also exists
- `isAnswerable` only matters for a question: put it in an answerable category when one fits, so an answer can be marked. Don't put a proposal or conversation in an answerable category just because it exists, the thread will sit "unanswered" forever
- When two categories plausibly fit, or none clearly does, ask the user rather than guessing. Pass the category's `slug` to `--category`, it's stable across renames of the display name
- An Announcement-format category only accepts new posts from maintainers and admins, and the API doesn't expose a category's format. When `gh discussion create` fails with a permission error, that's the likely cause: pick another category or ask, don't retry
- A category form lives at `.github/DISCUSSION_TEMPLATE/<category-slug>.yml`, the filename matching the category's slug, so check for one after picking. Render it the same way as a YAML issue form per `references/issue-writing.md`'s Template selection section: each field as a `### Label` heading followed by its answer, in the form's own field order. A form replaces the per-kind structure below, fill what it asks for. Forms are YAML only, there's no markdown discussion template
- When the same query returns `hasDiscussionsEnabled: false`, the repo has discussions turned off. Say so rather than falling back to an issue unasked

## Titles

Specific enough that a reader scanning the list knows what's inside without opening it. Name tools in plain words, not as a bracketed `[cache]` prefix, labels do that job. Draft the body first and the title last, the body is where the point gets pinned down.

- Question: the question itself, ending in `?`, carrying whatever tells it apart from similar ones: the error, the tool, the unusual circumstance. `Why does actions/cache miss on every run after a runner image update?`, not `Cache problems`
- Proposal: the proposed change as a short noun phrase, `Per-directory config overrides`, not `Idea` or `Feature request`
- Announcement: what changed and, when it matters, when: `v3.0 drops Node 18 support on 2026-11-01`
- Anything else: the issue title rules in `references/issue-writing.md`

## Opening post

Follow `references/body-writing.md` for structure, same as an issue body: why first, the repo's form if there is one, the length ceiling. One topic per post, two unrelated questions or proposals get two discussions so each can reach its own outcome. Paste code, logs, and errors as text in a fenced block, never as a screenshot, screenshots are for UI state and rendering bugs only.

What the body has to carry depends on the kind.

### Question

- The problem in prose, expanding on the title, before any code or log. A post that opens with a code block makes the reader reverse-engineer the question
- What was already tried and why it didn't work, including the near-miss threads from Before posting
- A minimal reproduction: the smallest config, command, or snippet that still shows the problem, pasted into the post. A gist or sandbox link is fine alongside it, not instead of it
- The `Never trim these` list in `SKILL.md` applies in full: the exact error text and the version of every tool in play

### Proposal or idea

- The problem or gap first, who hits it and what it costs them, then the proposed direction. A proposal with no problem statement can't be weighed against doing nothing
- The alternatives already considered, one line each, so the thread doesn't relitigate them
- The open questions the author wants input on, as a short list at the end. A proposal that doesn't say what feedback it wants gets upvotes and no decision

### Announcement

- What changed and who it affects, in the first sentence
- What a reader has to do about it, and by when. Breaking changes and migration steps fall under `Never trim these` in `SKILL.md`
- A link to the release, PR, or doc with the full detail, and where to take questions. Replies on an announcement are for clarifying it, not for support threads
- A correction or update edits the post itself, with a dated line saying what changed, rather than a comment the next reader won't see

### Show and tell

- What it is and what it does for someone using this project, in the first sentence, then the link
- How it uses or extends the project, and its status (experimental, maintained, archived) so nobody builds on an abandoned prototype

### Poll

Polls can't be created through the API (`createDiscussion` has no poll field) and category forms don't apply to them. Draft the title, the question, and the options, then hand them to the user to post in the UI. Options don't overlap and together cover the realistic answers. The body, when there is one, says what the result will be used for.

### Open conversation

- The topic and why it's being raised now
- What kind of response is wanted: experiences, objections, a show of interest. An open conversation with no stated ask drifts

## Comments and replies

Discussion threads are two levels deep: a top-level comment, then replies under it. A reply can't have replies of its own.

- Prose only, no Conventional Comments labels, those belong to PR review comments per `references/review-comments.md`
- Respond to an existing comment as a reply in its thread, not as a new top-level comment. A top-level comment is for a new answer, a new position, or a new point about the opening post
- One comment, one point, except when answering several questions, per Answering a question below
- When responding to one specific line in a long post or comment, quote only that line with `>` and respond directly below it in plain, unquoted text. Quote the sentence, never the whole post, and never blockquote the response itself. This is the same shape as `references/body-writing.md`'s Anticipated reviewer questions section
- Asking for clarification: one or two sharp questions as a reply, not a barrage. Ask `why` before prescribing when a request looks risky or odd, the answer to "why do you need to shrink this file?" often changes what the right answer is
- A link that carries the point gets its one relevant sentence quoted alongside it, per the link-rot rule in `SKILL.md` Formatting
- Correcting your own comment after feedback: edit it so it stands on its own, fetching the live text first per `references/gh-cli.md`. A correction stacked in a reply below leaves the original wrong for the next reader
- Never post a "+1", "same here", "thanks", or "any update?" comment. Upvote instead, per Upvotes and reactions below

## Answering a question

Answer the problem the asker actually has, not only the literal question. "How do I add the Debug button back in v18?" answered with "it was dropped in v18" is correct and still unhelpful; the useful answer is how to debug in v18. When the literal answer is "you can't" or "don't do that", say what to do instead in the same comment.

- Lead with the answer, then the reasoning or steps behind it. A reader landing from search reads the marked answer first and may read nothing else
- State the assumptions and limits the answer depends on: the version it was checked against, the platform, the config it assumes
- Building on an existing answer: quote the part being extended or corrected and add what it's missing, don't restate the whole thing
- A partial answer is still worth posting when it's labeled as one. Time-boxed and stuck, post what was found and what was ruled out, it saves the next person that ground even when it doesn't close the question

A post asking several questions gets one comment answering all of them, not one comment per question. Only one comment per discussion can be marked as the answer, so splitting the answers leaves all but one unmarked. Inside that comment, give each question its own `>` quote followed by its answer, in the order the post asked them:

```markdown
> Does the cache survive a runner restart?

No. It's keyed to the workflow run, a new run starts cold.

> Can I share it across repos?

Only through an artifact upload in one repo and a download in the other.
```

## Responding to a proposal or conversation

- State the position first (for, against, for with a change), then the reasoning. A reader skimming the thread should get the position from the first line
- An objection names the concrete case it breaks, not a general unease. A use case the proposal misses is the most useful comment it can get
- Plain support with nothing to add is an upvote, not a comment
- Answer the proposal's own open questions when it lists them, quoting each one per Comments and replies above

## Wrapping up

Every kind except an announcement ends with its outcome written down, so a reader landing from search a year later doesn't have to reconstruct it from the thread.

- Question: mark the comment that actually resolves it, not the "thanks, that worked" reply under it, and not necessarily the first correct one. A threaded reply can be marked when it's the one holding the resolution. A minimized comment can't be marked. Only the discussion author and users with triage access or above can mark an answer, don't offer to mark one for a user who can't
- Question resolved outside the thread (a PR, a release, a doc), or asked in a category that isn't answerable: post a comment stating the resolution with the link, then mark that comment where marking is possible
- Proposal, conversation, or poll: post a closing summary comment with the outcome, accepted with a link to the tracking issue, declined with the reason, or parked with what would reopen it, then close
- Close with the reason that matches: `RESOLVED` once the outcome is posted, `OUTDATED` when the topic is out of date, `DUPLICATE` with a comment linking the thread it duplicates. Marking an answer doesn't close a discussion on its own

## Upvotes and reactions

Upvotes work on discussions and top-level comments and sort the list by what matters to the community. Reactions work on every comment and reply and carry no ranking weight.

- Upvote instead of posting agreement or thanks as a comment. On a reply, which can't be upvoted, use a reaction instead
- Same problem or same need as the post: upvote it rather than commenting, unless there's new information to add (another version affected, a narrower reproduction, a use case the proposal misses), then post that as a comment
- An upvote or reaction is attributed to the user, same as a comment. Only add one when the user asks for it, never as a side effect of reading a thread

## Related work

Discussions share the repo's number sequence with issues and PRs, so `owner/repo#123` autolinks a discussion the same way, and the full-form rule in `SKILL.md` Formatting applies on every mention. A PR's closing keyword can't close a discussion, though. When a discussion turns into work, file an issue referencing it, link the issue back in the discussion's closing summary, and have the PR close the issue.

## AI watermark

Skip it, same as issue bodies. The `## AI watermark` rule in `references/pr-writing.md` applies to PR bodies and PR/review comments only.

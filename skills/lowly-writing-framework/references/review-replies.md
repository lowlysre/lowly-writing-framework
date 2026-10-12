# Replying to review feedback

Loaded from `SKILL.md` when the author of a PR answers reviewer comments on it: replying in a thread, resolving one, re-requesting review. Writing a review comment on someone else's PR is `references/review-comments.md`.

Same structural rules as everywhere: why over how, one point per sentence. The label on each reviewer comment (see `references/review-comments.md`) says what the reviewer expects back, so read it before replying.

## Before replying

- Fetch the live threads first and work from the unresolved ones, never from a notification or an earlier list in the conversation. The command is in `Replying to review threads` in `references/gh-cli.md`
- Push before you reply. A reply that says it's done points at a commit the reviewer can open, so confirm it's on the PR head: `gh pr view <n> --json headRefOid -q .headRefOid` matches `git rev-parse HEAD`
- Apply a round of feedback in one push, then reply to every thread against that push. One push per thread sends the reviewer chasing several SHAs
- On an outdated thread, read the lines at the current head before answering. The code may have moved, or an earlier change may have settled it
- Add fixup commits while review is open and squash at merge. A rebase or force-push after replying orphans the SHAs the replies cite

## Review with the user first

- Show the user every drafted reply, and the resolve decision for each thread, before anything posts. That includes replies, resolving, reactions, and re-requesting review, through structured tools or `gh`. Posting notifies the reviewer and can't be recalled, and the user knows context the agent doesn't
- Present them thread by thread: the reviewer's comment, the drafted reply, and whether the thread would be resolved or left open. Flag any reply that declines, cites research, or leaves a thread open with a question, since those are the judgment calls
- Post only what the user approves, as approved. An edit to the wording means showing the new text again if the change is more than a typo
- Standing permission overrides this. If the user said to post without review ("just post them", "no need to check with me"), skip the pause for that session and say once that you did. Permission given for one PR or one round doesn't carry to the next

## One reply per thread

- Reply inside the thread, to its first comment. A top-level "addressed all feedback" comment leaves every thread without an outcome
- Open with the outcome, in one of four shapes:
  - Done: `Done in <sha>.` Add a clause only when what changed differs from what was asked, and end with a question when the reviewer should confirm it per `Resolving` below. Write the SHA plain, 7 or more characters: GitHub autolinks it, and backticks turn it into dead text
  - Answer: for a `question:`, the answer first. If the question exposed unclear code, fix the code or its comment, then name the commit. An explanation that lives only in a thread is lost to the next reader, so the durable part goes in a code comment per `references/docs-and-comments.md`, or in the PR body's Anticipated reviewer questions per `references/body-writing.md`
  - Not doing: the decision, then the reason and its evidence, then what would change it. See `Disagreeing` below
  - Later: a link to the follow-up issue in full `owner/repo#123` form, and one sentence on why it doesn't belong in this PR. File the issue first per `references/issue-writing.md`
- A reply with no outcome ("good point", "thanks", "will look") is a miss. Make the change or the decision, then reply
- Match the reply to the label:
  - `issue:` and `suggestion:`, and any unlabeled comment, are blocking. Each gets Done, Not doing, or Later, never silence
  - `nitpick:` and `suggestion (non-blocking):` can be declined in one line
  - `question:` is answered, not marked done
  - `thought:` and `note:` need a reply only if they ask for something
  - `praise:` gets a thumbs-up reaction, not a reply
- Append `<!--:robot:-->` as the last line of a reply an agent drafted, per the `## AI watermark` rule in `references/pr-writing.md`

## Disagreeing

- State the decision first, then the evidence: a line-anchored permalink to precedent in the repo, the exact error text, a one-sentence quote from the doc, or a source found per `Researching before you reply`. A reply that is only opinion is where threads stall
- Name what would change the answer, so the reviewer has a concrete way to reopen it
- Open every link and confirm the lines at that SHA say what the reply claims before posting. A cited precedent that doesn't resolve is worse than none
- Don't resolve a thread whose reply declines

````markdown
Not changing this. `fetch_all` is the only caller of `paginate`, and it caps `page_size` at 100:

https://github.com/acme/sdk/blob/<full-sha>/sdk/client.py#L88-L91

So the extra guard can't fire today. If a second caller skips that cap, the guard is worth adding.
````

## Researching before you reply

Look things up instead of answering from memory in two cases. In both, a reply that cites what you read is stronger than one that asserts it.

- Objective correctness: the comment or your reply turns on how a language, library, API, or tool behaves, such as a default value, a version's semantics, a security property, or a spec requirement. Check the primary source for the version the repo pins (docs, changelog, spec, source), not a blog post or a summary of one. If the repo's own code or tests settle it, that beats the web
- Abstract principle: your reply leans on a design idea ("single-responsibility", "idempotent retries", "parse, don't validate"). Find the canonical statement of it, then tie it to a concrete consequence in this diff. The principle alone is name-dropping: "this keeps `build_query` unit-testable without a database" is the claim, and the link only backs it
- Skip research for taste and for anything the repo's conventions already answer. Local precedent comes first, per `Disagreeing`

Rules for using what you find:

- Open the source and confirm it says what you're about to claim, and that it applies to the version in use. A search snippet or an answer from memory isn't confirmation
- Link it inline as a named markdown link with the one relevant sentence quoted alongside, per `SKILL.md` Formatting. The reviewer shouldn't have to open it to see what it says
- Research can show the reviewer is right. Then reply Done, and say what you checked, so the concession is as concrete as a decline would have been
- If sources disagree, or you can't find one, say what's unverified instead of picking a side. Don't cite a source you didn't open, and don't invent the principle's name or attribution
- Keep it to one or two links per reply. A reply that stacks citations reads as an argument to win, not a point to settle

````markdown
Keeping the explicit `timeout` argument. A new socket has no timeout unless one is set, so dropping it would hang on a dead peer:

[Python socket docs](https://docs.python.org/3/library/socket.html#socket.setdefaulttimeout): "When the socket module is first imported, the default is None."

If you'd rather the default live in one place, I can move it to `DEFAULT_TIMEOUT_S`.
````

## Suggested edits

- A suggestion applied unchanged needs no reply beyond resolving the thread: the commit is the reply. Batch several into one commit with **Add suggestion to batch**
- A suggestion applied with changes gets a Done reply that says what differs
- A suggestion on an outdated or resolved thread can't be applied with a click. Make the change by hand and reply Done

## Resolving

A commit isn't proof the reviewer is satisfied. The question for each Done is whether the change was exactly what the comment asked for, or whether the author made a call the reviewer should see.

- Done and resolve when the change is mechanical and there's one reasonable reading: a rename, a typo, a suggested edit applied verbatim, a `nitpick:` taken as written
- Done and leave open, ending with a specific question, when any of these hold:
  - The ask had more than one reasonable fix and you picked one
  - You read the comment differently than its words suggest, or only part of it landed
  - The comment was an `issue:` about correctness, security, or behavior. The reviewer holds the context to judge whether the fix closes it, so the author doesn't
  - The change reached beyond the anchored lines, or tests changed with it
  - The reviewer hedged ("I think", "maybe") or probed with a `question:` that you answered with code
- Name what you did and ask the reviewer to confirm it: `Done in 3f9a1c2. Guarded at the call site rather than inside paginate(), since fetch_all is the only caller. Does that cover what you meant?` A bare "let me know if that works" gives them nothing to check. Ask one thing per thread
- When unsure which side a thread falls on, leave it open. A reviewer closing a thread costs one click, and an author closing one early can bury a finding that was only half addressed
- Leave it open as well when the reply declines, defers, applies only part of the ask, or asks something back. The reviewer closes those
- The repo's convention wins. If `CONTRIBUTING.md` or the PR template says reviewers resolve their own threads, resolve none
- Never resolve a thread you haven't replied to, and never bulk-resolve a list
- With structured tools, `reply_and_resolve_review_thread` fits a mechanical Done and an Answer nothing hangs on, `reply_to_review_thread` fits the rest. Through `gh`, see `Replying to review threads` in `references/gh-cli.md`

## After the round

- Re-request review from each reviewer who left blocking feedback or an open thread, once the push and the replies are in, so the notification lands on a PR whose threads already show outcomes. Skip reviewers who only approved or praised
- If the feedback changed the PR's scope or approach, update the PR body: fetch it first, and strike through a pivot that needs to stay visible per `SKILL.md` Formatting. Thread replies leave the description describing the old PR. Re-check the Testing section against what the new commits changed, per `references/pr-writing.md`

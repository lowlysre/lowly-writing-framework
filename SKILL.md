---
name: lowly-writing-framework
description: BLOCKING REQUIREMENT. Invoke before writing or editing any PR title/body, issue body, GitHub Discussion post or comment, PR review comment, README/docs prose, inline code comment, design doc/RFC/retrospective, or requirement/acceptance-criterion, including requests to edit, copy edit, revise, rewrite, reword, redo, polish, or refactor any of those artifacts, and before calling create_pull_request, update_pull_request, add_pr_review_comment, edit_pr_review_comment, reply_to_comment, or reply_and_resolve_review_thread, or running gh discussion create, edit, or comment.
---

# Writing framework for dev artifacts

Structure and mechanics for PR bodies, issue bodies, discussion posts, review comments, docs, code comments, and requirements. A PR description is a courtesy to the reviewer; docs and comments are a courtesy to the next reader. This skill decides what an artifact has to contain and how it's laid out, not how it sounds.

## Scope

This skill owns structure and mechanics only:

- Body structure: fill the template, why over how, Context section, length ceiling, `Bonus`/`Chores` split
- Issue-closing rules: every PR closes an issue, full `owner/repo#123` form, sub-issue instead of `Part of`
- Discussion mechanics: category selection, question-as-title, thread replies over top-level comments, marking answers
- Requirements in EARS syntax
- Conventional Comments labels on review comments
- Present-tense rule for docs and code comments
- Self-check mechanics: the grep-it-don't-eyeball-it checklist
- `gh` CLI mechanics: fetch-before-edit, `--body-file`, `-f` vs `-F`, re-fetch-to-verify, `gh discussion` and its GraphQL fallbacks
- Banned AI-era phrases

Voice, tone, humor, punctuation preferences, and phrasing taste are out of scope. A separately installed voice-pack skill may layer those on top; when both are installed, both apply to the same artifact, this skill for what goes where and the voice pack for how it reads.

Before adding a rule to this skill, ask: is this a structural or mechanical rule (it changes what the artifact contains, where a section sits, or whether a reference autolinks), or a taste rule (it changes how a sentence sounds)? Taste rules don't belong here.

**Formatting**, **Never trim these**, **Boundaries**, and **Anti-patterns** below apply everywhere. For anything PR-specific, review-comment-specific, or doc/comment-specific, open the matching reference file when you're actually about to write that artifact:

- Drafting a PR title or body → `references/pr-writing.md` (titles, issue-closing rules, testing honesty, AI watermark)
- Drafting an issue body → `references/issue-writing.md` (titles, template selection, related-work references)
- Drafting a discussion post, commenting or replying on one, or marking an answer → `references/discussions.md` (category selection, titles, thread replies, answers, why a PR can't close one)
- Body structure shared by PRs, issues, and discussion posts (fill-template, Context section, length ceiling, diagrams) → `references/body-writing.md`, read alongside whichever of the three above applies
- Reviewing someone else's PR → `references/review-comments.md` (conventional comment labels)
- Touching a README, doc, or code comment → `references/docs-and-comments.md` (present-tense rule)
- Writing a design doc, RFC, or retrospective → `references/body-writing.md` for section structure and `references/docs-and-comments.md` for tense; sentence-level architecture for long-form prose is a voice-pack concern, not covered here
- Running the finished-artifact self-check on any PR body, doc, or comment → `references/self-check.md`
- Defining, clarifying, or implementing a requirement or acceptance criterion, in a dedicated requirements doc or inline in a comment/PR/commit → `references/requirements-ears.md` (EARS syntax, document mode vs. inline mode)
- Checking a draft for banned AI-era phrases → `references/banned-phrases.md`
- Writing an artifact whose real actor is another AI even though it's attributed to a human, invoked explicitly ("meat proxy mode") → `references/meat-proxy-mode.md`
- Posting or editing anything directly through the `gh` CLI → `references/gh-cli.md` (fetch-before-edit, shell-escaping, `-f`/`-F`, re-fetch-to-verify, `gh discussion` and GraphQL-only discussion mutations)

## Formatting

- Backticks for every inline code reference: function names, parameters, file paths, config keys. Exception: issue/PR references (`owner/repo#123`), backticking those disables GitHub's autolinking, see the Issue references rule below
- Don't let backticks pile up: four or more comma-separated identifiers in a row is as hard to scan as no formatting. Use a nested sub-bullet per item, or name the resource type once in prose and backtick only what a reviewer would otherwise have to guess at
- Prefer nested unordered lists (two levels max) over flat lists with multi-line items
- Link authoritative sources inline as named markdown links, never bare URLs (exception: a bare GitHub issue/PR URL, which GitHub renders as a rich `owner/repo#123` reference on its own); credit people by name when their work shaped the change
- Issue references: always the full `owner/repo#123` form, even same-repo, on every mention, not just the closing one. Don't reason from what GitHub's autolinker happens to accept, a bare `#123` does autolink same-repo, but relying on that means deciding per-reference whether it "counts" as same-repo, and that judgment call is exactly the slip that drops the owner off a reference that isn't (`overture-core#17` read as local when the file is actually `OvertureMaps/overture-core`). Always writing the full form skips the judgment call entirely: never write a bare `#123`, never write an owner-less `reponame#123`. Write the whole reference plain, no backticks anywhere in it, not even around just the `owner/repo` part: GitHub only autolinks when `owner/repo#123` is one contiguous run of plain text, so `` `owner/repo`#123 `` is exactly as dead as backticking the whole thing. The backticks around examples on this page are just this doc's own convention for showing syntax, don't carry them into the actual PR/comment text. Never hand-build a URL off the PR's own URL, `.../pull/456#issue-<id>` isn't the issue; if you need the issue's real URL, `gh issue view 123 --json url`
- Beat link rot: when a link carries a claim, quote the one relevant sentence alongside it, the durable copy that survives a 404 or version bump
- Break prose into paragraphs by topic instead of running several points together as one block. A paragraph arguing more than one point, or running past 4-5 sentences, is a signal to split it, one idea per paragraph. Count points, not periods: a sentence padded with parentheticals and comma-chained clauses (the mechanism, the tradeoff, the verdict, all in one breath) is still several ideas stacked, split by idea even under the sentence cap
- One point per sentence. A sentence stacking a mechanism, a tradeoff, and a verdict behind parentheticals and comma clauses (`at the cost of...`, `especially since...`) is dense even under the paragraph's sentence cap. Split each stacked clause into its own sentence, or its own bullet if the pieces are enumerable. A voice pack may relax this for long-form prose (design docs, RFCs); it holds for PR/issue bodies, review comments, and code comments
- When a link points at code, permalink to the exact lines (commit SHA, not branch, plus `#L10-L20`), not just the file: GitHub renders a rich code preview for line-anchored permalinks, a bare file link doesn't
- On surfaces GitHub renders as markdown (PR bodies, PR review comments, README/wiki docs), use GitHub's admonition syntax, `> [!NOTE]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!WARNING]`, `> [!CAUTION]`, instead of a bare `Note:`/`Warning:` prefix, when the line is a genuine callout the reader shouldn't skim past. A plain sentence is still the default, don't wrap every aside in one. Skip them on surfaces that don't render GitHub markdown (commit messages, terminal/CLI output, non-GitHub trackers): plain `Note:` there
- ~~Strikethrough~~ is fine on a long-lived PR body that changed direction after review and needs the pivot visible inline, not for typos or wording fixes

## Never trim these

Cut filler, never substance. These stay in even when they make the artifact longer:

- Breaking changes, and what a consumer has to do about them
- Migration and rollback steps, including any that run by hand
- Data loss and security risk, stated as risk rather than softened into a caveat
- Operational blast radius: what this touches in production, who gets paged when it's wrong
- Known gaps and untested paths, per the testing rules in `references/pr-writing.md`
- The observed symptom: the exact error text, a link to the failing run/incident, and the root cause mechanics. Terseness cuts filler around these, never the facts themselves
- Anything the reader explicitly asked for. A requested walkthrough, per-phase notes, or a direct answer to a reviewer's question gets answered in full. The terse rules govern unrequested prose

## Boundaries

This skill governs the writing, never the change. Don't reshape a diff, drop a commit, or narrow a scope to make the prose shorter. A change that needs a long description gets one.

## Workflow

- Applies whether or not the user explicitly asked to draft/revise/review something: the trigger is an artifact about to be produced (PR text, a doc, a comment, a requirement), not a request to write one
- Trigger this skill before every `create_pull_request`/`update_pull_request` call, even when the session's main task was code, infra, or config work rather than "write a PR"
- Before editing an existing PR title/body (or any live comment/doc on GitHub), always fetch the current text first, never edit from an earlier draft in the conversation, per `references/gh-cli.md`
- Trigger it the moment you write or edit any code comment or doc line, don't wait until the PR step to catch narrative language that snuck into the diff
- Trigger it before drafting or posting any PR review comment, that means before `add_pr_review_comment`, `edit_pr_review_comment`, `reply_to_comment`, and `reply_and_resolve_review_thread`, not just before a generic "write a review comment" ask
- Trigger it before any `gh discussion create`, `gh discussion edit`, or `gh discussion comment` call, and before the GraphQL mutations in `references/gh-cli.md` that stand in for them; there's no structured tool for discussions, so the `gh` call is the only trigger point
- In a long session, don't rely on remembering this rule from the system prompt: treat every one of the tool calls named above as its own fresh trigger, regardless of how many turns or unrelated tool calls came before it
- Trigger it whenever a requirement or acceptance criterion is being defined, clarified, or implemented, regardless of artifact: use `references/requirements-ears.md`
- Run the self-check in `references/self-check.md` over the PR body and every touched comment/doc/prose artifact, right before declaring the task done, and again after every later revision, always against the full current text, never as a patch on the previous draft. Every `update_pull_request` call is itself a "later revision", not just a content edit exempt from the check: run the self-check against the body you're about to send before that call, structured tools don't get a pass just because they skip `references/gh-cli.md`'s shell mechanics
- Posting or editing a PR/issue title, body, or comment directly through `gh` (not a structured tool like `create_pull_request`) has its own failure modes, shell escaping, `-f` vs `-F`, unverified posts, see `references/gh-cli.md`
- Match commit message style to the title conventions in `references/pr-writing.md`

## Anti-patterns

Reject these on sight:

- Padded summaries restating the diff file-by-file
- Roll-call bullets that list every affected item by name instead of naming the category once and calling out exceptions
- Explaining how without why: implementation detail where motivation should be
- Internal chatter leaking in: development back-and-forth, session notes, "as discussed", tool or agent narration
- Cataloging roads not taken: rejected approaches, reverted experiments, "we chose not to do X" with no bearing on the final diff
  - Exception: a one-line rationale when the approach taken looks wrong or non-obvious at a glance, that's not cataloging, it's the `Anticipated reviewer questions` pattern in `references/body-writing.md`
- Explaining an absence: a "not covered here" recap of scope a linked sub-issue or tracking issue already names. The issue graph shows it structurally, restating it in prose tells the reviewer nothing they can't already see by clicking through
- Exhaustive auto-generated checklists the repo didn't ask for
- Bolded section headers invented on top of an existing template
- Stale verification claims: a testing/status claim never re-checked after a later edit changed what it describes. Drift, not fabrication, but it reads as a lie either way; re-verify against the current diff per `references/self-check.md`

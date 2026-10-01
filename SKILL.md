---
name: lowly-writing-framework
description: BLOCKING REQUIREMENT. Invoke before writing or editing any PR title/body, issue body, GitHub Discussion post/comment/answer, PR review comment, README/docs prose, inline code comment, design doc/RFC/retrospective, or requirement/acceptance-criterion, including requests to edit, copy edit, revise, rewrite, reword, redo, polish, or refactor any of those artifacts, and before calling create_pull_request, update_pull_request, add_pr_review_comment, edit_pr_review_comment, reply_to_comment, or reply_and_resolve_review_thread.
---

# Writing framework for dev artifacts

Structure and mechanics for PR bodies, issue bodies, discussions, review comments, docs, code comments, and requirements. A PR description is a courtesy to the reviewer; docs and comments are a courtesy to the next reader. This skill decides what an artifact has to contain and how it's laid out, not how it sounds.

## Scope

This skill owns structure and mechanics only: what an artifact contains, where each section sits, whether a reference autolinks, which grep catches a slip. The routing table below lists every topic it covers.

Voice, tone, humor, punctuation preferences, and phrasing taste are out of scope. A separately installed voice-pack skill may layer those on top; when both are installed, both apply to the same artifact, this skill for what goes where and the voice pack for how it reads.

**Formatting**, **Never trim these**, **Boundaries**, and **Anti-patterns** below apply everywhere. For anything PR-specific, review-comment-specific, or doc/comment-specific, open the matching reference file when you're actually about to write that artifact:

- Drafting a PR title or body → `references/pr-writing.md` (titles, issue-closing rules, testing honesty, AI watermark)
- Drafting an issue body → `references/issue-writing.md` (titles, template selection, related-work references, keeping proposed solutions out of the body)
- Drafting a Discussion post, comment, or reply, or marking an answer → `references/discussions.md` (kinds of post, category selection from the repo's actual categories, threading and answer-marking mechanics, wrapping up with a written outcome, upvotes instead of "+1" comments)
- Body structure shared by PRs, issues, and discussion posts (fill-template, Context section, linking docs the PR already carries, length ceiling, diagrams) → `references/body-writing.md`, read alongside whichever of the three above applies
- Adding a mermaid diagram to a PR/issue body or doc → `references/diagrams.md` (GitHub rendering mechanics, known GitHub limitations, theme/styling, legends for color-coded diagrams)
- Reviewing someone else's PR → `references/review-comments.md` (conventional comment labels, suggested edits)
- Touching a README, doc, or code comment → `references/docs-and-comments.md` (present-tense rule)
- Writing a design doc, RFC, or retrospective → `references/body-writing.md` for section structure and `references/docs-and-comments.md` for tense; sentence-level architecture for long-form prose is a voice-pack concern, not covered here
- Running the finished-artifact self-check on any PR body, doc, or comment → `references/self-check.md`
- Defining, clarifying, or implementing a requirement or acceptance criterion, in a dedicated requirements doc or inline in a comment/PR/commit → `references/requirements-ears.md` (EARS syntax, document mode vs. inline mode)
- Checking a draft for banned AI-era phrases → `references/banned-phrases.md`
- Writing an artifact whose real actor is another AI even though it's attributed to a human, invoked explicitly ("meat proxy mode") → `references/meat-proxy-mode.md`
- Posting or editing anything directly through the `gh` CLI → `references/gh-cli.md` (fetch-before-edit, shell-escaping, `-f`/`-F`, re-fetch-to-verify, line-anchored suggested edits, `gh discussion` and GraphQL-only discussion mutations)
- Drafting a PR, issue, or discussion body → also read the `Bodies` sections of `references/calibration-examples.md`, plus its `PR Testing section` for a PR (before/after pairs for the judgment-call rules; skip the file for review comments, code comments, and docs). In meat proxy mode, read its `Meat proxy mode` section too

## Formatting

- Backticks for every inline code reference: function names, parameters, file paths, config keys. Exception: issue/PR references (`owner/repo#123`), backticking those disables GitHub's autolinking, see the Issue references rule below
- Don't let backticks pile up: four or more comma-separated identifiers in a row is as hard to scan as no formatting. Use a nested sub-bullet per item, or name the resource type once in prose and backtick only what a reviewer would otherwise have to guess at
- Prefer nested unordered lists (two levels max) over flat lists with multi-line items
- Link authoritative sources inline as named markdown links, never bare URLs (exceptions: a bare GitHub issue/PR URL, which GitHub renders as a rich `owner/repo#123` reference on its own, and a bare line-anchored code permalink, which only expands to a code preview when pasted bare); credit people by name when their work shaped the change
- Issue references: always the full `owner/repo#123` form on every mention, same-repo included, so there's never a per-reference call about what counts as same-repo. Never a bare `#123`, never an owner-less `reponame#123`. No backticks anywhere in it, not even around just the `owner/repo` part: GitHub only autolinks one contiguous run of plain text (the backticks on this page only show syntax). Never hand-build a URL off the PR's own URL, `.../pull/456#issue-<id>` isn't the issue; get the real one with `gh issue view 123 --json url`
- Beat link rot: when a link carries a claim, quote the one relevant sentence alongside it, the durable copy that survives a 404 or version bump
- Break prose into paragraphs by topic, one idea per paragraph. A paragraph arguing more than one point, or running past 4-5 sentences, needs splitting
- One point per sentence. A sentence stacking a mechanism, a tradeoff, and a verdict behind parentheticals and comma clauses (`at the cost of...`, `especially since...`) is several ideas even under the paragraph's sentence cap: count points, not periods. Split each stacked clause into its own sentence, or its own bullet if the pieces are enumerable. A voice pack may relax this for long-form prose (design docs, RFCs); it holds for PR/issue bodies, review comments, and code comments
- When a link points at code, permalink to the exact lines (commit SHA, not branch, plus `#L10-L20`), not just the file: GitHub renders a rich code preview for line-anchored permalinks, a bare file link doesn't
  - Shape: `https://github.com/<owner>/<repo>/blob/<full-sha>/<path>#L10-L20`, bare on its own line so the preview expands (a Markdown-file or named link stays an ordinary link). Never a branch name or short SHA, they drift; if the SHA can't be resolved, say so instead of linking the branch
  - SHA: `gh api repos/<owner>/<repo>/commits/<ref> --jq .sha` (current repo: `git rev-parse HEAD`). Use `2>&1`, not `2>null`, so a failure is visible
  - Lines: read them from the file at that SHA, never from memory or a hand count. `gh api -H "Accept: application/vnd.github.raw" "repos/<owner>/<repo>/contents/<path>?ref=<sha>"` piped to `grep -n '<pattern>'` (PowerShell: `Select-String`, `.LineNumber`). Keep it in the pipe, no temp file in the working tree, and `?ref=` in the URL, not `-f ref=`, which makes the call a POST
- On surfaces GitHub renders as markdown (PR bodies, PR review comments, README/wiki docs), use GitHub's admonition syntax, `> [!NOTE]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!WARNING]`, `> [!CAUTION]`, instead of a bare `Note:`/`Warning:` prefix, when the line is a genuine callout the reader shouldn't skim past. A plain sentence is still the default, don't wrap every aside in one. Skip them on surfaces that don't render GitHub markdown (commit messages, terminal/CLI output, non-GitHub trackers): plain `Note:` there
- ~~Strikethrough~~ is fine on a long-lived PR body that changed direction after review and needs the pivot visible inline, not for typos or wording fixes
- Never hard-wrap a paragraph at a fixed column: write each paragraph as one line in the source. GitHub collapses a mid-paragraph newline to a space, so wrapping only makes the raw source (`gh pr view`, an editor, a diff) look broken. Break lines only between block elements (headings, list items, code fences) and at paragraph boundaries

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
- Trigger this skill before each of these, even when the session's main task was code, infra, or config work rather than "write a PR":
  - `create_pull_request`, `update_pull_request`
  - `add_pr_review_comment`, `edit_pr_review_comment`, `reply_to_comment`, `reply_and_resolve_review_thread`
  - Writing or editing any code comment or doc line, the moment you do it, so narrative language doesn't sneak into the diff before the PR step
  - Defining, clarifying, or implementing a requirement or acceptance criterion, regardless of artifact: use `references/requirements-ears.md`
- In a long session, don't rely on remembering this rule from the system prompt: treat each trigger above as fresh, regardless of how many turns or unrelated tool calls came before it
- Before editing an existing PR title/body (or any live comment/doc on GitHub), always fetch the current text first, never edit from an earlier draft in the conversation, per `references/gh-cli.md`
- Run the self-check in `references/self-check.md` over the PR body and every touched comment/doc/prose artifact, right before declaring the task done and again after every later revision, always against the full current text. Every `update_pull_request` call is a later revision: run the self-check on the body you're about to send, structured tools included
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

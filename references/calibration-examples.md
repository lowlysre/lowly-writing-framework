# Calibration examples

Before/after pairs for structural rules stated elsewhere in this skill, grouped by the artifact they apply to. Read the section matching the artifact you're drafting, alongside that artifact's reference file; the section for `SKILL.md` rules applies to every artifact. Each example names the rule it shows and where that rule lives. The rule text stays in its home file, this file only shows it applied.

Copy the structure, not the content. The project names, sentences, file paths, and issue numbers inside each example are placeholders, so a draft that reuses them (an `acme/` owner, a "retry path") has copied the example instead of applying the rule. How the sentences read is a voice-pack concern, not this file's.

Several "before" halves trip the mechanical checks in `references/self-check.md` on purpose. That's the mistake being shown, not a finding in this file.

## Contents

- Every artifact (`SKILL.md` rules)
  - Admonition vs. plain sentence, in a PR body
  - Admonition vs. plain sentence, in a README
  - Issue references and scope notes
  - One point per sentence
  - Roll-call bullets
  - Summary that restates the diff
- PR and issue bodies (`references/body-writing.md`)
  - Anticipated reviewer question
  - Pulling an aside into `Bonus`
  - Altitude on a large diff
  - Context section placement
  - Four paragraphs into headings
- PR `## Testing` (`references/pr-writing.md`)
  - Claim CI already covers
  - Doubt with no named test behind it
  - Manual steps around the merge
- Review comments (`references/review-comments.md`)
  - `question:` that's a suggestion
  - Non-blocking decoration
- Code comments (`references/docs-and-comments.md`)
  - Issue number in a code comment
- Meat proxy mode (`references/meat-proxy-mode.md`)
  - Prose ask into executable steps

## Every artifact

<examples>

<example>

### Admonition vs. plain sentence, in a PR body

Shows the admonition rule in `SKILL.md` Formatting: a `> [!WARNING]` is for a line the reader shouldn't skim past, a plain sentence is the default.

Before, every gap gets the same callout, so none of them stands out:

```markdown
## Testing
Unit tests cover the new retry path.

> [!WARNING]
> No test covers the rollback script, it only runs manually today and hasn't been exercised against prod-sized data.

> [!WARNING]
> Fixture data for the malformed-header case doesn't exist yet, so that branch is untested.
```

After:

```markdown
## Testing
Unit tests cover the new retry path.

> [!WARNING]
> No test covers the rollback script, it only runs manually today and hasn't been exercised against prod-sized data.

Fixture data for the malformed-header case doesn't exist yet, so that branch is untested.
```

The untested rollback script is a rollback risk from `SKILL.md`'s Never trim these list, so it keeps the callout. The missing fixture is a known gap that still gets stated, per the testing rules in `references/pr-writing.md`, but it carries no production risk, so it drops to a plain sentence.

</example>

<example>

### Admonition vs. plain sentence, in a README

Same rule on a different surface, `references/docs-and-comments.md` applies it to READMEs.

Before:

```markdown
> [!NOTE]
> The CLI reads `config.toml` from the current directory.

> [!WARNING]
> `sync --prune` deletes remote branches that have no local copy, and there's no undo.
```

After:

```markdown
The CLI reads `config.toml` from the current directory.

> [!WARNING]
> `sync --prune` deletes remote branches that have no local copy, and there's no undo.
```

The config path is ordinary reference information. The irreversible delete is data loss, so it's the only line that earns a callout.

</example>

<example>

### Issue references and scope notes

Shows three rules at once:

- The full `owner/repo#123` form on every mention, and never hand-building a URL off the PR's own URL, both in `SKILL.md` Formatting
- The `Explaining an absence` anti-pattern in `SKILL.md`
- The "Not covered here" carve-out in `references/body-writing.md`

Before:

```markdown
Phase 1 of the migration ([#455](https://github.com/acme/infra-tofu/pull/91#issue-3299451674)).

Not covered here (tracked in separate sub-issues):
- Copying the existing packages (ops-team#464)
- Dual-publish workflows (ops-team#466)
```

What's wrong with it:

- The link is built off the PR's own URL: `.../pull/91#issue-<id>` points at the PR, not issue 455
- `ops-team#464` has no owner, so it doesn't autolink from a PR in another repo
- The "Not covered here" list recaps scope the linked sub-issues already name, the issue graph shows it without the prose

After:

```markdown
Phase 1 of the migration. Closes acme/ops-team#465.
```

The PR closes its own sub-issue, every cross-repo reference carries its owner, and the issue graph carries both the out-of-scope work and the parent relationship.

</example>

<example>

### One point per sentence

Shows the one-point-per-sentence rule in `SKILL.md` Formatting.

Before, one sentence carries the change, the reason, the cost, and the verdict:

```markdown
The cache now keys on the lockfile hash (instead of the branch name, which missed dependency bumps on long-lived branches), at the cost of a cold cache on every lockfile change, which is acceptable since those land about once a week.
```

After:

```markdown
The cache now keys on the lockfile hash instead of the branch name. Branch-name keys missed dependency bumps on long-lived branches. Keying on the lockfile means a cold cache on every lockfile change. Those land about once a week, so the extra misses are acceptable.
```

Same facts, one per sentence. The parenthetical and both trailing clauses became sentences of their own.

</example>

<example>

### Roll-call bullets

Shows the roll-call anti-pattern in `SKILL.md`: name the category once, call out only the exceptions.

Before:

```markdown
- Updated `billing/handler.py` to use the new client
- Updated `orders/handler.py` to use the new client
- Updated `shipping/handler.py` to use the new client
- Updated `returns/handler.py` to use the new client
- Updated `refunds/handler.py` to use the new client and added a retry, since refunds call a slower upstream
```

After:

```markdown
All five service handlers move to the new client. The refunds handler also retries, since it calls a slower upstream.
```

The four identical bullets collapse into a count. The one bullet that differed is the only one still named, because it's the only one a reviewer needs to look at separately.

</example>

<example>

### Summary that restates the diff

Shows two `SKILL.md` anti-patterns together: a padded summary restating the diff file by file, and how without why.

Before:

```markdown
## Summary
- `retry.py`: add `max_attempts` parameter
- `retry.py`: add exponential backoff
- `client.py`: pass `max_attempts=3` to `retry()`
- `tests/test_retry.py`: add tests
```

After:

```markdown
## Summary
Calls to the payments API failed outright on the first 503, which the API returns for a few seconds during every vendor deploy. Requests now retry up to 3 times with backoff before failing.
```

The diff already lists the files. The summary says what broke, who saw it, and what the change does about it, none of which the diff shows.

</example>

</examples>

## PR and issue bodies

<examples>

<example>

### Anticipated reviewer question

Shows the `Anticipated reviewer questions` section of `references/body-writing.md`: only the question is blockquoted, the answer sits below it as plain text.

Before, the answer is quoted along with the question, so the body reads like a transcript:

```markdown
> *Why not just override the default at the call site instead of changing the module-level default?*
>
> The call site is generated code we don't own. Patching the module default is the only surface we control until upstream exposes a config option.
```

After:

```markdown
> *Why not just override the default at the call site instead of changing the module-level default?*

The call site is generated code we don't own. Patching the module default is the only surface we control until upstream exposes a config option.
```

The question names the alternative a reviewer would reach for first. The answer gives the constraint that rules it out, one point per sentence, with no `>` on any answer line.

</example>

<example>

### Pulling an aside into `Bonus`

Shows the `Bonus`/`Chores` split in `references/body-writing.md`: an unrelated fix gets its own sub-header, however short it is.

Before:

```markdown
## Summary
Exports timed out for accounts with more than 10k rows because the query loaded every row before paginating. The export now streams rows in pages of 500. Also fixed a typo in the export button's tooltip.
```

After:

```markdown
## Summary
Exports timed out for accounts with more than 10k rows because the query loaded every row before paginating. The export now streams rows in pages of 500.

### Bonus
- Fixed a typo in the export button's tooltip
```

The tooltip fix is one clause either way. The sub-header is what tells the reviewer it's safe to skip.

</example>

<example>

### Altitude on a large diff

Shows the altitude rule in `references/body-writing.md`: a large diff gets described at the module level, and the diff carries the function names.

Before, on a PR touching a dozen files:

```markdown
Adds `TokenCache.get()`, `TokenCache.put()` and `TokenCache._evict()`, calls `TokenCache.get()` from `AuthClient.fetch_token()` before `_request_token()`, and adds `CACHE_TTL_SECONDS` to `settings.py`.
```

After:

```markdown
The auth client now caches tokens in memory until they expire, instead of requesting a new one on every call. How long a token stays cached is a new setting.
```

The before narrates the diff symbol by symbol, and its backtick density is the tell. The after names the layer that changed and what it does differently.

</example>

<example>

### Context section placement

Shows the `## Context` section in `references/body-writing.md`: wider context goes first, not after the change.

Before:

```markdown
## Summary
Adds the read path for the new schema behind the `schema_v2` flag.

This is phase 2 of the schema migration in acme/api#210. Phase 1 added the write path; phase 3 removes the old tables.

Closes acme/api#214.
```

After:

```markdown
## Context
Phase 2 of the schema migration in acme/api#210. The write path is merged, and this read path unblocks removing the old tables in phase 3.

## Summary
Adds the read path for the new schema behind the `schema_v2` flag.

Closes acme/api#214.
```

A reviewer new to the migration reads where this PR slots in before reading what it does.

</example>

<example>

### Four paragraphs into headings

Shows the 3-paragraph ceiling in `references/body-writing.md`: at 4, restructure under short headings instead of adding prose.

Before:

```markdown
## Summary
Nightly backups have failed on the replica since the storage migration, and nobody was paged because the job exits 0 on failure.

The backup script writes to `/mnt/backups`, which the migration remounted read-only. `tar` fails, but the script pipes it through `gzip`, so the pipeline's exit status is gzip's.

The script now sets `pipefail` and reads the mount path from the storage config instead of hardcoding it.

The first run after merge takes about 40 minutes longer than usual, since there's no recent base to diff against.
```

After:

```markdown
## Summary
Nightly backups have failed on the replica since the storage migration, and nobody was paged because the job exits 0 on failure.

### Root cause
The backup script writes to `/mnt/backups`, which the migration remounted read-only. `tar` fails, but the script pipes it through `gzip`, so the pipeline's exit status is gzip's.

### Fix
The script now sets `pipefail` and reads the mount path from the storage config instead of hardcoding it. The first run after merge takes about 40 minutes longer than usual, since there's no recent base to diff against.
```

The opening paragraph stays as the lede. The headings mark the divisions the four paragraphs already had, one per topic, not one per paragraph.

</example>

</examples>

## PR Testing section

<examples>

<example>

### Claim CI already covers

Shows the redundant-CI rule in `references/pr-writing.md`'s Testing section. Assume the repo's CI runs `npm test` and `npm run lint` on every push.

Before:

```markdown
## Testing
Ran `npm test` and `npm run lint` locally, both pass. Clicked through checkout in Safari with an expired card.
```

After:

```markdown
## Testing
Clicked through checkout in Safari with an expired card.
```

CI reruns both commands on this PR, so saying they passed locally proves nothing extra. The manual Safari check is the only thing CI can't see.

</example>

<example>

### Doubt with no named test behind it

Shows the invented-bar rule in `references/pr-writing.md`'s Testing section. Assume the repo has no end-to-end suite.

Before:

```markdown
## Testing
Added unit tests for the parser. Couldn't fully end-to-end test this, so there may be edge cases in production.
```

After:

```markdown
## Testing
Added unit tests for the parser.
```

There's no end-to-end suite to have skipped, so the second sentence invents a bar the project never set. If a named suite existed and didn't run, the line stays and names it: "The `e2e/import` suite didn't run, it needs a staging database."

</example>

<example>

### Manual steps around the merge

Shows the `## Post-merge (manual)` rule in `references/pr-writing.md`: steps an operator runs get their own section with a box per step.

Before:

```markdown
## Testing
Unit tests cover the new column. After merging, someone needs to run the backfill script and then flip the `use_new_column` flag, in that order.
```

After:

```markdown
## Testing
Unit tests cover the new column.

## Post-merge (manual)
- [ ] Run `scripts/backfill_column.py` against prod
- [ ] Flip the `use_new_column` flag once the backfill finishes
```

The steps sit in their own section instead of inside Testing, and the list order carries the sequence instead of a trailing "in that order".

</example>

</examples>

## Review comments

<examples>

<example>

### `question:` that's a suggestion

Shows the `question:` rule in `references/review-comments.md`: a question the reviewer already knows the answer to is a suggestion.

Before:

```markdown
question: Wouldn't it be better to use a set here instead of a list?

<!--:robot:-->
```

After:

```markdown
suggestion: Use a set here. `in` on a list is linear, and this runs once per incoming event.

<!--:robot:-->
```

The label now matches what the reviewer wants, and the why is stated rather than implied. A real question is one the reviewer can't answer alone: "question: Can this list hold duplicates? If not, a set makes the lookup constant-time."

</example>

<example>

### Non-blocking decoration

Shows the decoration rule in `references/review-comments.md`: an unlabeled `suggestion:` reads as blocking, so a preference gets `(non-blocking)`.

Before:

```markdown
suggestion: Rename `data` to `invoices`, since it's the only list in scope.

<!--:robot:-->
```

After:

```markdown
suggestion (non-blocking): Rename `data` to `invoices`, since it's the only list in scope.

<!--:robot:-->
```

A naming preference shouldn't hold the merge, and without the decoration the author can't tell. The reverse, `suggestion (blocking):`, is noise, blocking is already the default.

</example>

</examples>

## Code comments

<examples>

<example>

### Issue number in a code comment

Shows the issue-reference rule in `references/docs-and-comments.md`: a code comment cites an upstream bug, never this repo's own PR history.

Before:

```python
# Added retries in acme/api#482 after the March timeouts
for attempt in range(3):
```

After, describing current behavior:

```python
# The vendor drops about 1 in 200 connections under load, so retry before failing
for attempt in range(3):
```

After, when the cause is someone else's bug:

```python
# Workaround for upstream-org/http-lib#2168: the pool doesn't release connections on read timeout
pool.clear()
```

The before is a history breadcrumb that belongs in the PR, it tells a future reader when the code changed but not why it's still needed. An upstream bug reference earns its place because it tells the reader when the workaround can go.

</example>

</examples>

## Meat proxy mode

<examples>

<example>

### Prose ask into executable steps

Shows the rules in `references/meat-proxy-mode.md`: imperative steps in order, exact identifiers, and an EARS acceptance criterion.

Before, an issue assigned to a coding agent:

```markdown
The config loader should probably handle missing files more gracefully, like the other loaders do. Could you update it and add a test?
```

After:

```markdown
- In `src/config/loader.py`, change `load_config()` to return `DEFAULT_CONFIG` when the file doesn't exist, matching `load_secrets()` in `src/config/secrets.py`
- Add a test in `tests/config/test_loader.py` for the missing-file case

Acceptance criterion:
- IF the config file doesn't exist, THEN `load_config()` SHALL return `DEFAULT_CONFIG` without raising
```

"More gracefully" and "the other loaders" both need shared context an agent doesn't have. The after names the file, the function, the return value, and the loader it matches, and states pass/fail as one testable `SHALL`.

</example>

</examples>

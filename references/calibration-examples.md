# Calibration examples

Before/after pairs for structural rules whose text is a judgment call, grouped by the artifact they apply to. Read only the sections `SKILL.md` routes you to for the artifact you're drafting, alongside that artifact's reference file. Each example names the rule it shows and where that rule lives. The rule text stays in its home file, this file only shows it applied. A rule whose text already carries its own inline example doesn't get one here.

Copy the structure, not the content. The project names, sentences, file paths, and issue numbers inside each example are placeholders, so a draft that reuses them (an `acme/` owner, a "retry path") has copied the example instead of applying the rule. How the sentences read is a voice-pack concern, not this file's.

Several "before" halves trip the mechanical checks in `references/self-check.md` on purpose. That's the mistake being shown, not a finding in this file.

## Contents

- Bodies: `SKILL.md` rules
  - Issue references and scope notes
  - One point per sentence
  - Roll-call bullets
  - Backticks on names
  - Summary that restates the diff
- Bodies: `references/body-writing.md` rules
  - Anticipated reviewer question
  - Pulling an aside into `Bonus`
  - Altitude on a large diff
  - Context section placement
  - Four paragraphs into headings
  - Body repeats a doc the PR adds
- PR Testing section (`references/pr-writing.md`)
  - Manual steps around the merge
- PR author annotations (`references/pr-writing.md`)
  - Line-anchored aside out of the body
  - Annotating a block with a range
- Meat proxy mode (`references/meat-proxy-mode.md`)
  - Prose ask into executable steps

## Bodies: `SKILL.md` rules

<examples>

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

### Backticks on names

Shows the backtick rules in `SKILL.md` Formatting: tick literal text the reader would copy, not the names of repos, apps, or roles, and not every repeat.

Before:

```markdown
Lets `acme-worker` read the `acme-bot` app's key through the `ci-secrets-reader` role, so its new `release.yml` can create releases. A `GITHUB_TOKEN`-created release doesn't fire `release: published`, which `publish.yml` there triggers on.
The change is one entry in `reader_repos` in `oidc.tf`.

- [x] `acme-bot` is installed on `acme-worker`.
- Merge acme/acme-worker#101 after this applies, so its first `release.yml` run can assume the role.
```

After:

```markdown
Lets acme-worker read the acme-bot app's key through the ci-secrets-reader role, so its new release workflow can create releases. A release created with `GITHUB_TOKEN` doesn't fire `release: published`, which the publish workflow there triggers on.
The change is one entry in `reader_repos` in `oidc.tf`.

- [x] acme-bot is installed on acme-worker.
- Merge acme/acme-worker#101 after this applies, so its first release run can assume the role.
```

The repo, app, and role names lost their ticks because nobody types them into a terminal. `GITHUB_TOKEN`, the `release: published` event, `reader_repos`, and `oidc.tf` keep theirs: they're literal text the reader has to match or open. The repeated `release.yml` went plain once the prose named the workflow instead.

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

## Bodies: `references/body-writing.md` rules

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

<example>

### Body repeats a doc the PR adds

Shows the Docs the PR already carries rule in `references/body-writing.md`: prose that duplicates a touched doc becomes a gist and a link.

Before, on a PR that adds `docs/retries.md`:

```markdown
## Summary
Clients now retry failed requests. Retries use exponential backoff starting at 200ms, doubling up to a 10s cap, with jitter so clients don't stampede. Only idempotent methods retry, and a `Retry-After` header overrides the computed delay.

The retry budget is 3 attempts per request, and the circuit opens after 5 consecutive failures.

Closes acme/sdk#88.
```

After:

```markdown
## Summary
Clients now retry failed requests with backoff. Review the rules in [Retry behavior](https://github.com/acme/sdk/blob/retry-docs/docs/retries.md#retry-behavior); the code follows that doc.

Closes acme/sdk#88.

> [!WARNING]
> Retries multiply load on a struggling server. Roll out behind the `retries` flag, off by default.
```

The backoff, budget, and circuit details live in the doc once. The warning stays in the body because risk is never trimmed, even if the doc mentions it.

</example>

</examples>

## PR author annotations: `references/pr-writing.md` rules

<examples>

<example>

### Line-anchored aside out of the body

Shows `Author annotations` in `references/pr-writing.md`: an aside about specific lines becomes a comment on those lines, and the body stays on the primary change.

Before (PR body):

```markdown
## Summary
Bumps the client timeout to 30s because large exports were cut off at 5s.

### Bonus
- Reordered the imports in `client.py` so the linter stops flagging them
- The `retries` value in `settings.yaml` is a placeholder until the backend team publishes real limits
```

After (PR body):

```markdown
## Summary
Bumps the client timeout to 30s because large exports were cut off at 5s.
```

After (comment on the `retries` line in `settings.yaml`):

```markdown
note: Placeholder until the backend team publishes real limits.
<!--:robot:-->
```

After (comment on the first changed import in `client.py`):

```markdown
note: Import reorder only, so the linter stops flagging this file.
<!--:robot:-->
```

Each aside is still on the record, and a reviewer reading either line finds it there. The timeout fix is the only thing the body asks them to weigh.

</example>

<example>

### Annotating a block with a range

Shows the anchoring bullet in `references/pr-writing.md`: a note about a block covers the whole block, so the UI highlights what it explains, and a deleted block anchors on its deleted lines.

Before (single comment on the line above the block, so the UI highlights none of it):

```markdown
note: The block below is the unused Batch/Bedrock path, removed here because nothing calls it.
<!--:robot:-->
```

After (range comment, `start_line=40`, `line=88`, `side=LEFT`, `start_side=LEFT`, on the deleted lines in `jobs/run.py`):

```markdown
note: Unused Batch/Bedrock path, removed because nothing calls it.
<!--:robot:-->
```

</example>

</examples>

## PR Testing section

<examples>

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

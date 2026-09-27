# How-to guides

- [Pair with a voice-pack skill](#pair-with-a-voice-pack-skill)
- [Run the mechanical self-check by hand](#run-the-mechanical-self-check-by-hand)
- [Write an EARS requirement](#write-an-ears-requirement)
- [Write a Conventional Comments review](#write-a-conventional-comments-review)

## Pair with a voice-pack skill

"Voice pack" isn't a term from the Agent Skills spec or a wider convention, it's this repo's own name for a separately installed Agent Skill that governs tone, punctuation, and phrasing for the same artifacts this skill structures: PR and issue bodies, review comments, docs, code comments. This skill decides what goes where; the voice pack decides how it reads. Neither skill names the other.

The Agent Skills spec has no dependency or `extends` mechanism, so an agent matches a request against every installed skill's `description` and loads whichever fit. Pairing two skills means making both `description` fields match the same requests, nothing more.

To install an existing voice pack:

1. Install it the same way as this skill: `npx skills add <owner>/<voice-pack-repo> -g`.
2. Open its `SKILL.md` and confirm its `description` lists the same artifacts and tool calls as this repo's (PR body, issue body, discussion post/comment/answer, review comment, doc prose, code comment, requirement, and `create_pull_request` through `reply_and_resolve_review_thread`). If it doesn't, a request that triggers this skill may not trigger the voice pack, or vice versa.
3. Ask your agent to draft something covered by both (a PR body is the easiest test) and confirm the output reads in the voice pack's style while still following this skill's structure (template filled, closing reference present, watermark at the end).

To write your own voice pack:

1. Scaffold a new skill directory with its own `SKILL.md`.
2. Copy this repo's `description` line into it verbatim, then edit only the sentence after "BLOCKING REQUIREMENT" if your voice pack narrows the artifact list. Keep the artifact and tool-call lists identical to this skill's, or the two won't co-activate.
3. Fill the body with tone, punctuation, and phrasing rules only. Don't restate anything from this skill's Scope section (body structure, issue-closing rules, EARS, Conventional Comments labels, present tense) or it'll fight this skill's rules instead of layering on top.
4. Whenever this repo's `description` line changes, update your copy to match.

## Run the mechanical self-check by hand

Write the artifact to a file, then run the checks from `references/self-check.md`. On Linux or macOS:

```sh
grep -inE '(removed|used to|previously|no longer|was updated|a scan found|as of #)' body.md
grep -nE '(^|[^a-zA-Z0-9_./-])#[0-9]+' body.md
grep -nE '`#[0-9]+|#[0-9]+`' body.md
grep -inE '(part of|relate[sd]? to).*#[0-9]+' body.md
grep -nP '(?<!\]\()https?://' body.md
grep -c '<!--:robot:-->$' body.md
```

On Windows PowerShell, `Select-String` takes the same patterns; the file lists both forms per check. Zero hits on every check (and exactly one on the watermark count) means the mechanical pass is clean. The judgment checks in the same file still need a read.

## Write an EARS requirement

Full syntax, the five patterns, and document vs. inline mode live in `references/requirements-ears.md`. The short version: one sentence, one `SHALL`, one observable trigger; `should` and `may` mean it isn't a requirement yet.

## Write a Conventional Comments review

Full label list and decoration rules live in `references/review-comments.md`. The short version: open every comment with a plain-text label (`praise:`, `issue:`, `suggestion:`, and the rest), one comment per point, `<!--:robot:-->` on its own line at the end.

# gh CLI mechanics

Loaded from `SKILL.md` whenever posting or editing a PR title/body, PR/issue comment, or any other GitHub-hosted text directly through the `gh` CLI. Structured-parameter tools (`create_pull_request`, `update_pull_request`, `reply_to_comment`, etc.) sidestep everything on this page, they never touch a shell string. This page is only for cases that go through `gh` or `gh api` directly. Sidestepping the shell mechanics here doesn't sidestep `references/self-check.md`: run it against the body before every `update_pull_request` call the same as before a `gh pr edit`, a structured tool is still a live edit to the PR.

## Reading state before you edit

Before editing an existing PR title/body, issue body, or any other live GitHub text, always fetch the current text first (`gh pr view <n> --json title,body`, `gh issue view <n> --json body`), never edit from an earlier draft still sitting in the conversation. The user may have hand-tweaked it since, and writing from a stale copy silently reverts their edits. Apply the adjustment to the fetched text, preserving everything not being changed.

## Writing text safely

Never inline markdown as a shell string. Each shell's escaping (backtick, `$`, caret) mangles a body unpredictably the moment it contains backticks, code fences, or `$` references. Write the body to a temp file instead and pass `--body-file <path>` (`gh pr comment`, `gh pr edit`, `gh issue comment`) or `-F body=@path` (`gh api`), then delete the temp file.

`-f` never reads a file, `-F` does. `gh api`'s `-f/--raw-field` is a literal string field, `@path` there posts the literal string `@path` as the body instead of the file's contents, and the call still exits `0`. Only `-F/--field` triggers the `@path` file read. Same trap applies to any other `gh api` field meant to hold drafted text, not just `body`.

## Gating the post on length

Don't eyeball the length ceiling from `references/self-check.md` right before a `gh` call, measure the temp file and branch on the result, so an over-length body never reaches the API in the first place:

```powershell
$len = (Get-Content -Raw body.md).Length
if ($len -gt 3500) { throw "body.md is $len chars, over the 3,500 ceiling; restructure per body-writing.md before posting" }
gh pr edit <n> --body-file body.md
```

```bash
len=$(wc -c < body.md)
[ "$len" -gt 3500 ] && { echo "body.md is $len chars, over the 3,500 ceiling; restructure per body-writing.md before posting" >&2; exit 1; }
gh pr edit <n> --body-file body.md
```

Swap the measurement for a word count when the limit in play is a word count instead of a character ceiling (a review comment convention, a tracker's own field limit): `(Get-Content -Raw body.md).Split() | Where-Object { $_ -ne '' } | Measure-Object` on Windows, `wc -w < body.md` on Linux/macOS. Same shape either way: count, compare against the known valid range, only call `gh` in the branch that passes.

This gate catches an oversized body before the round-trip to GitHub. It doesn't replace the re-fetch-and-diff step in `Verifying what landed` below, a body can pass the length gate and still get mangled by shell escaping on the way out.

## Verifying what landed

A returned URL and exit code `0` only prove the request succeeded, not that the body matches what was drafted. After any `gh api`, `gh pr comment --edit-last`, or `gh issue comment --edit-last` call that posts or edits a body, re-fetch the live text (`gh api repos/{owner}/{repo}/issues/comments/<id> --jq .body`, or the equivalent PR/issue endpoint) and diff it against the intended text before telling the user it's posted.

Closing-keyword text isn't proof GitHub linked the issue either. Once a PR is pushed, confirm the link against the API: `gh pr view <n> --json closingIssuesReferences -q '.closingIssuesReferences[].number'`. Empty output usually means a cross-repo reference missing the `owner/repo#123` form, a typo'd number, or a base branch that isn't the repo's default (GitHub only auto-links closing keywords on PRs into the default branch). Fall back to GraphQL if `--json` lacks the field: `gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){pullRequest(number:$n){closingIssuesReferences(first:10){nodes{number}}}}}' -f o=<owner> -f r=<repo> -F n=<pr-number>`.

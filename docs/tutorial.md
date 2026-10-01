# Tutorial: draft a PR body

A first walk through the skill, from install to a checked PR body. Install the skill first, per the [README](../README.md#install-and-update).

1. Make a small code change on a branch in any repo with a remote on GitHub.
2. Ask your agent: "open a draft PR for this branch."
3. Watch the skill activate before the PR call. The `description` frontmatter names `create_pull_request` as a trigger, and `SKILL.md` routes the agent to `references/pr-writing.md` before it drafts.
4. The body fills the repo's PR template, or the skill's fallback of a `## Summary` heading over 1-3 sentences on why the change exists, then what changed.
5. The body carries a closing reference in the full `owner/repo#123` form. If no issue exists yet, the skill has the agent file one scoped to the change first, per `references/pr-writing.md`.
6. A `## Testing` section states what ran and what didn't. An untested path stays visible as an unchecked box or a `> [!WARNING]` admonition.
7. Before the PR call, the skill has the agent write the body to a temp file and run the mechanical checks from `references/self-check.md` against it. A bare `#123`, a backticked issue reference, a `Part of` phrasing, or a missing `<!--:robot:-->` watermark fails the check and gets fixed before anything reaches GitHub.

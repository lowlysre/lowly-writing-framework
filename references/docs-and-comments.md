# Docs & code comments

Loaded from `SKILL.md` when writing or editing a README, wiki, module doc, or code comment.

These describe the system **as it is now**. The history (why it changed, what it used to do, what issue prompted it) belongs in the PR body or commit message, never in the file.

- Present tense, declarative: "This function retries on transient errors," not "was updated to retry"
- No narrative or migration breadcrumbs: "used to own", "previously handled", "a scan found X", "as of #123". If it's not true today, delete it instead of explaining what changed
- Reference an issue/PR number in an inline code comment for exactly two reasons: an external upstream bug (`workaround for dotnet/runtime#12345`), or a `TODO` written as a posterity note, aimed at a future reader once this project's current context, the team, the phase, the tracking issue itself, is likely gone or forgotten. A fast-follow or anything already slotted as next-up work doesn't qualify, that's planned work still inside the current context, not archaeology for later: describe the current behavior and let the backlog carry the plan. Never cite an in-flight or already-merged PR/issue from this repo, that's the "as of #123" breadcrumb above wearing a different disguise: delete it and describe current behavior instead. Same logic covers a near-term issue in another repo: if it's expected to land soon, the comment goes stale before the ink dries and just adds a cleanup chore later
- An inline code comment covers only the non-obvious: the *why* behind a non-intuitive choice, a gotcha, a workaround for someone else's bug. Don't restate what the code already says, that's what a docstring or README is for
- One comment per non-obvious thing, not one per line. A well-named variable or function is the comment; `// increment counter` above `counter++` isn't a candidate for a shorter comment, it's a candidate for no comment
- Don't repeat what's already said one layer over: if the docstring covers the parameters, an inline comment restating them above the call site is the same fact twice; if the README covers the module's purpose, a header comment re-explaining it is the same fact twice. State it once, in the place a reader of that layer would look
- Match the existing convention in the file or repo, docstring style for docstrings, prose style for README/wiki/module docs, rather than inventing a new one
- Terse over exhaustive: a one-line comment beats a paragraph if it gets the point across, and no comment beats a one-liner that only restates the line below it
- Honest about limitations inline where relevant: "doesn't handle X yet" beats silence or a context-free TODO
- In a README/wiki (GitHub renders it as markdown), a gotcha or limitation worth flagging can use `> [!NOTE]`/`> [!WARNING]`/`> [!IMPORTANT]` instead of a `Note:`/`Warning:` prefix line. Reserve it for something worth stopping the reader, most limitations still read fine as a plain sentence. Code comments aren't rendered markdown, GitHub admonitions don't apply there, plain text prefixes if any

Before finishing, run the shared checklist in `references/self-check.md`.

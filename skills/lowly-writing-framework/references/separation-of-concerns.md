# Business logic vs. implementation

Loaded from `SKILL.md` when a diff, function, or requirement is in view while drafting a PR body, review comment or reply, code comment, or requirement. Runs on every such artifact, not only when design comes up.

A function that decides and performs draws the same review flags every time: a rule testable only through a database, a client or clock hidden in the logic, a small behavior change touching I/O code. Name it before the PR opens or precisely in review. Never reshape the diff, per `SKILL.md`'s Boundaries.

## Signals

Flag only when you can name one concrete extraction. Otherwise it is a vague "separate concerns", not a finding.

- One body holds a branch or calculation over domain values plus a side effect (DB write, HTTP call, file write, queue publish)
- A client, connection, clock, random source, or config read built inside the logic and changing its outcome, instead of passed in
- A test needing a container, network, filesystem, or patched clock to cover plain branching or arithmetic
- A rule change and an I/O change in the same hunk

## Not a finding

- Thin orchestration: calls a pure function, then performs the effect
- A function that only does I/O, or only decides
- Composition roots, `main`, CLI entry points, one-off scripts
- Logging and metrics calls
- A framework-mandated signature
- SQL, IaC, and generated files with no separable logic
- A function too small for the split to pay off

## By artifact

### PR body (you are the author)

- Scan the diff while drafting. Tell the user in chat first, naming the function and the extraction, and offer: fix here, split to a follow-up, or ship as is. The user picks
- Shipped as is: one body sentence naming the function and what stays coupled, per `Known gaps` in `SKILL.md`'s Never trim list. No "for now", and no cleanup promise unless a tracking issue exists; if the user wants one, file it per `references/issue-writing.md` and link it
- Testing never claims unit coverage of a rule whose tests need a container, network, or patched clock. Say what they need

### Review comment (you are the reviewer)

- Raise it in the design tier of `Review order and priorities` in `references/review-comments.md`
- Label it `suggestion (non-blocking):`. Use `issue:` only when the mix causes a defect in this PR or leaves a diff rule untested
- A request to comment only on blockers narrows severity, not detection. Stage it as non-blocking and tell the user, so they can drop it
- Name the function, the rule and effect it conflates, and the cost here, then offer the extraction as one option, per `Problem vs. offered fix`:

  ```markdown
  suggestion (non-blocking): `apply_late_fee` decides the fee and opens its own database connection, so the fee rule can only be tested with a live database.

  One option: split the rule into a pure `late_fee(invoice, today)` and leave `apply_late_fee` to fetch the invoice, call it, and write the result.
  ```

- Never "violates separation of concerns" or "extract a helper" alone
- One comment per function, anchored where rule and effect meet. A PR built that way throughout gets one early comment on the main function
- Check `Not a finding` first: a comment on a thin handler teaches the author to skim

### Reply to a separation finding (you are the author)

Use the outcomes in `references/review-replies.md`:

- Done: name the commit
- Keeping as is: name where the boundary already sits, or why the function is too small
- Later: file the issue first. Only for `suggestion (non-blocking):`; an `issue:` finding is fixed in this PR, per `Disagreeing`

Code comments marking where the rule ends and the I/O begins, and requirements stating mechanism instead of behavior, are covered in `references/docs-and-comments.md` and `references/requirements-ears.md`.

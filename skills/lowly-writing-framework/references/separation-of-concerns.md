# Business logic vs. implementation

Optional design-review guidance. Use it when the user asks for design feedback or a concrete design concern is already in scope. Code being visible alone does not require an architecture review, comment, or PR-body note.

When design feedback is in scope, look for a concrete boundary whose extraction has a named benefit, such as testing a rule without a database or keeping a client or clock from changing the rule's outcome. Never reshape the diff, per `SKILL.md`'s Boundaries.

## Signals

Flag only when you can name one concrete extraction. Otherwise it is a vague "separate concerns", not a finding.

- One body holds a branch or calculation over domain values plus a side effect (DB write, HTTP call, file write, queue publish)
- A client, connection, clock, random source, or config read built inside the logic and changing its outcome, instead of passed in
- A test needing a container, network, or filesystem to cover plain branching or arithmetic
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

- Do not add a design note solely because a function mixes a rule and I/O. Include a testing limitation or operational risk only when it materially affects what the reviewer needs to know, and describe that impact rather than prescribing an architecture

### Review comment (you are the reviewer)

- Raise it in the design tier of `Review order and priorities` in `references/review-comments.md`
- Label it `suggestion (non-blocking):`. Use `issue:` only when the mix causes a defect in this PR or leaves a diff rule untested
- Respect the requested review scope. Do not stage a non-blocking architecture suggestion when the user asks for blockers only; treat the concern as blocking only when the mix causes a defect or leaves changed behavior untested
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
- Later: link an existing tracking issue if one exists. Do not promise follow-up work without one, per `Disagreeing`

Code comments marking where the rule ends and the I/O begins, and requirements stating mechanism instead of behavior, are covered in `references/docs-and-comments.md` and `references/requirements-ears.md`.

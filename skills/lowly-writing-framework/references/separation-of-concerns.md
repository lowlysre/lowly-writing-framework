# Business logic vs. implementation

Loaded from `SKILL.md` whenever a diff, a function, or a requirement is in front of you while drafting a PR body, a review comment or reply, a code comment, or a requirement. The check runs on every such artifact, not only when someone mentions design.

Code that decides and performs in the same place draws the same review flags every time: a rule that can't be unit tested without a database, a clock or client hidden inside the logic, a small behavior change that touches I/O code. Catching it before the PR opens, or naming it precisely in review, avoids most of them. The check is on the artifact: name the finding, never reshape the diff, per the Boundaries rule in `SKILL.md`.

## Signals

Flag only when one concrete extraction exists that you can name. Without it the finding is a vague "separate concerns", which is not a finding.

- A function that decides and performs: a branch or calculation over domain values plus a side effect (DB write, HTTP call, file write, queue publish) in one body. A pricing rule that also opens a connection is the standard case
- A client, connection, clock, random source, or env/config read constructed inside the logic when it changes the rule's outcome, instead of passed in
- A test that needs a container, network, filesystem, or patched clock to cover a rule that is plain arithmetic or branching
- A diff tell: a rule change and an I/O change in the same hunk, or one rule edit that forces edits to SQL or HTTP code

## Not a finding

- Thin orchestration: a handler that calls a pure function, then performs the effect
- A function that only does I/O, or only decides
- Composition roots, `main`, CLI entry points, one-off scripts
- Logging and metrics calls inside logic
- A shape a framework mandates, such as a view or handler signature
- SQL, IaC, and generated files with no separable logic
- A function too small for the split to pay for itself

## By artifact

### PR body (you are the author)

- Scan the diff for the signals while drafting, before writing the body. Tell the user in chat first, with the function and the extraction, and offer three outcomes: fix it in this PR, split it into a follow-up, or ship as is. The user picks; this skill words the artifact and never reshapes the diff
- Fixed in this PR: the body describes the resulting split at the module level, nothing more
- Shipped as is: one sentence in the body names the function and what stays coupled, per the `Known gaps` entry in `SKILL.md`'s Never trim list. No "for now" and no promise of cleanup unless a tracking issue exists. Add one per `references/issue-writing.md` and link it in the full `owner/repo#123` form when the user agrees to split it out
- Testing never claims unit coverage of a rule whose tests need a container, network, or patched clock. Say what the test needs, per `references/pr-writing.md`'s Testing rules

### Review comment (you are the reviewer)

- It is a design finding: raise it in the design tier of `Review order and priorities` in `references/review-comments.md`, before naming and style
- Label it `suggestion (non-blocking):`. Use `issue:` only when the mix causes a defect in this PR or leaves a rule in the diff untested
- A request to comment only on blockers or to keep the review approve-ready narrows severity, not detection. Stage the finding as non-blocking anyway and tell the user it is there, so they can drop it from the pending review; withholding it leaves them without the choice
- Name the function, the rule and the effect it conflates, and what that costs here. Then offer the extraction as one option, per `Problem vs. offered fix`:

  ```markdown
  suggestion (non-blocking): `apply_late_fee` decides the fee and opens its own database connection, so the fee rule can only be tested with a live database.

  One option: split the rule into `late_fee(invoice, today)`, a pure function, and leave `apply_late_fee` to fetch the invoice, call it, and write the result.
  ```

- Not "this violates separation of concerns" and not "extract this into a helper"
- One comment per function, anchored on the line where the rule and the effect meet. When the whole PR follows the same pattern, post one comment on the main function early, per the design-wrong rule in `Review order and priorities`, instead of one per site
- Check `Not a finding` first. A comment on a thin handler costs the author a reply and teaches them to skim your comments

### Reply to a separation finding (you are the author)

A reviewer's separation finding gets one of the existing outcomes in `references/review-replies.md`:

- Done: the extraction landed, name the commit
- Keeping as is: name where the boundary already sits, or why the function is too small to split
- Later: the follow-up issue, filed first. Only for a `suggestion (non-blocking):`. An `issue:` finding is about a defect or an untested rule in this PR, so it gets fixed here, per the new-complexity rule in `Disagreeing`

### Code comment

A comment that marks where the rule ends and the I/O begins ("compute the fee, then write it") describes two jobs in one body. Split them into named functions and delete the comment, per the helper rule in `references/docs-and-comments.md`.

### Requirement

A `SHALL` that names storage, transport, or a library (`query the discounts table`, `POST to the billing API`) states mechanism, not behavior. Rewrite it as the observable behavior, per `references/requirements-ears.md`, and put the mechanism in the design.

Before finishing, run the shared checklist in `references/self-check.md`.

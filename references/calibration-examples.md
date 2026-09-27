# Calibration examples

Worked before/after pairs for structural rules stated elsewhere in this skill. Each example names the rule it shows and where that rule lives; the rule text stays in its home file, this file only shows it applied. Open it when a rule's wording leaves its application unclear, not as a checklist to run on every artifact.

Copy the structure, not the content. The project names, sentences, and issue numbers inside each example are placeholders, so a draft that reuses them (an `acme/` owner, a "retry path") has copied the example instead of applying the rule. How the sentences read is a voice-pack concern, not this file's.

## Contents

- Admonition vs. plain sentence
- Issue references and scope notes
- Anticipated reviewer question

<examples>

<example>

## Admonition vs. plain sentence

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

## Issue references and scope notes

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

## Anticipated reviewer question

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

</examples>

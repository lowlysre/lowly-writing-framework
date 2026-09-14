# Meat Proxy Mode

Loaded from `SKILL.md` only when explicitly invoked, e.g. "meat proxy mode" or "this is for an agent". Covers the case where an artifact is attributed to a human GitHub identity, may pass through a human reader, but the actor that actually resolves it is another AI: an issue assigned to a coding agent, a PR comment that triggers automated follow-up, a review reply an agent-merge tick reads and executes.

This doesn't relax anything in `SKILL.md`. The surface still reads like a human wrote it, `Formatting` and `Anti-patterns` apply unchanged, and so does any voice-pack skill layered on top. What changes is what the artifact has to contain underneath: every actionable claim needs to survive being parsed by something with no shared context to fall back on.

## Rules

- State actions as explicit imperative steps, one per bullet, in the order they run. Don't fold two actions into one sentence, an actor executing sequentially needs the split even where terse prose would normally combine them
- Acceptance criteria and requirements use EARS syntax from `references/requirements-ears.md`, even inline in a body where prose would otherwise cover it. A trigger/response pair is unambiguous to parse, a paragraph the actor has to infer conditions from isn't
- Name exact identifiers: file paths, function/class names, config keys, issue/PR numbers. Never "the relevant file" or "as mentioned above", a human reader can resolve the referent from context, an agent can't
- Figurative and rhetorical phrasing (antithesis, aphorism, a punchline standing in for a plain statement) is disqualifying here whatever the voice rules in play allow elsewhere: a device a human reads past without noticing is exactly the sentence a model has to resolve as if it were literal
- Never let the human-facing summary and the agent-facing steps diverge. If the summary would normally omit a step for brevity, keep the step anyway, an actor parsing only the actionable section still needs the complete list; cut length from the summary before the steps, never the reverse

## Boundaries

This mode changes what the artifact has to contain, not who it's attributed to or how it's disclosed. `SKILL.md`'s `Boundaries` rule still applies: don't misrepresent the change, and don't use "an AI reads this anyway" as a reason to skip the AI watermark rule in `references/pr-writing.md` where it applies.

## Self-check

Run `references/self-check.md` as normal, then one more pass specific to this mode: read every actionable bullet as if you were the acting agent, with no ability to ask a clarifying question. Any bullet you can't execute as written needs a rewrite, not a note that it's "hopefully clear".

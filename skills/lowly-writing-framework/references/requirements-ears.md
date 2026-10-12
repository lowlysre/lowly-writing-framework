# Requirements (EARS)

Loaded from `SKILL.md` when defining, clarifying, or reviewing requirements: issue acceptance criteria, PR "what this should do" sections, design doc requirement lists, ticket grooming, or a review comment pointing out an ambiguous spec. Applies regardless of which repo/org template wraps around it, EARS is a sentence-level pattern, not a document format, so it fits inside whatever headings the template already has.

EARS (Easy Approach to Requirements Syntax, [Alistair Mavin et al., IEEE RE 2009](https://ieeexplore.ieee.org/document/5211796)) constrains every requirement to one of five sentence patterns. Pick the pattern the requirement actually is, don't force everything into "the system shall."

Two modes, same patterns:

- **Document mode**: a dedicated requirements list (design doc, issue acceptance criteria, spec section). Write the full pattern out, one requirement per line, numbered or bulleted
- **Inline mode**: referencing, clarifying, or implementing a requirement in passing (a code comment above the block that enforces it, a PR line explaining what behavior a diff satisfies, a commit message). Compress to the EARS shape without the ceremony: `// WHEN queue depth > 1000, SHALL shed new writes` beats a paragraph of prose. Still one `SHALL`, still testable, just terser

## The five patterns

- **Ubiquitous** (always true, no trigger): `THE <system> SHALL <response>`
  - `THE API SHALL reject requests without an Authorization header`
- **Event-driven** (fires on a trigger): `WHEN <trigger> THE <system> SHALL <response>`
  - `WHEN a user submits a login form THE system SHALL validate credentials within 200ms`
- **State-driven** (holds while a state persists): `WHILE <state> THE <system> SHALL <response>`
  - `WHILE the connection is in maintenance mode THE system SHALL reject new writes`
- **Unwanted behavior** (error/exception handling): `IF <trigger>, THEN THE <system> SHALL <response>`
  - `IF the payment gateway times out, THEN THE system SHALL retry up to 3 times with exponential backoff`
- **Optional feature** (present only when a feature flag/variant applies): `WHERE <feature is included> THE <system> SHALL <response>`
  - `WHERE multi-region replication is enabled THE system SHALL write to at least 2 regions before acknowledging`

Combine clauses when a requirement genuinely needs more than one condition (`WHEN <trigger> WHILE <state> THE <system> SHALL <response>`), but don't stack clauses just to cram unrelated requirements into one sentence, split those into separate requirements instead.

## Rules

- One requirement, one sentence, one `SHALL`. If you need "and" to join two independent behaviors, that's two requirements
- Name the actual system/component/actor, never "it" or "the application" as a placeholder for something more specific you haven't identified yet
- `SHALL` is a testable commitment, not `should`/`may`/`could`. If it's not testable as written, it's not a requirement yet, it's a hope
- Triggers and states must be observable and unambiguous: `WHEN the queue depth exceeds 1000` beats `WHEN load is high`
- Quantify wherever the spec implies a number: latency, retry count, timeout, threshold. "Fast" and "eventually" aren't requirements
- Keep the acceptance criterion and the EARS statement identical, don't restate the same rule two different ways in one issue/PR

## Self-check before finishing

Reread every requirement you wrote or edited. Any hit means rewrite:

- `should`, `may`, `could`, `might` where `SHALL` belongs
- an untriggered event-driven requirement (missing `WHEN`) or an unstated actor
- a compound requirement joined by "and"/"or" that's really two requirements
- a vague trigger or state ("when appropriate", "if needed", "under load") with no observable condition
- a requirement with no way to test pass/fail as written
- a requirement that was accurate when first written but describes a trigger, threshold, or response the diff no longer implements after a later edit: re-check the `SHALL` sentence against the current code, not against what was true when you typed it

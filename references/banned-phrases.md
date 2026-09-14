# Banned phrases

Loaded from `SKILL.md` when running a final self-check, or whenever a phrase below appears mid-draft. This file targets the AI-specific vintage that has crept into PR prose since 2023; general business clichés are a phrasing-taste call and belong to whatever voice-pack skill is layered on top.

The test: would a senior engineer write this phrase in a Slack message to a colleague? If not, cut it or say the specific thing.

## Vague quality adjectives

These make a claim without evidence. Replace with the concrete property.

- **seamless** / **seamlessly**: say what used to be rough and why it no longer is, or delete
- **robust**: name what it's robust against: "retries on 429, 503, and connection reset"
- **powerful**: say what it unlocks that wasn't possible before
- **intuitive**: say what the old interface required and what the new one doesn't
- **efficient** / **efficiently**: say the actual cost change: "cut cold-start from 8 s to 1.2 s"
- **scalable**: say what the bottleneck was and what the new ceiling is
- **flexible**: say which parameters changed and what they gate
- **comprehensive**: say what's covered; if it's everything, say "covers all X cases" and name X

## Connective filler

These pad transitions without adding information. Delete the opener and start the sentence at the subject.

- **Additionally,**: just start the next sentence
- **Furthermore,**: just start the next sentence
- **Moreover,**: just start the next sentence
- **Notably,**: the fact is notable enough; the word adds nothing
- **Importantly,**: if it's important, say why; the word doesn't make it so
- **Ultimately,**: cut it; say the consequence directly
- **In summary,** / **To summarize,** / **In conclusion,**: cut; the text already ends
- **Overall,**: cut; say the thing
- **It is worth noting that** / **It's worth noting that**: cut the opener, state the fact
- **worth flagging upfront**: cut the opener, state the fact
- **Note that** / **Please note**: cut; use `> [!NOTE]` when the callout genuinely needs visual weight, plain prose otherwise
- **First and foremost,**: cut; lead with the most important thing, no announcement needed
- **Last but not least,**: cut; just state the item
- **Needless to say,**: cut; if it's needless, skip it; if it's not, say it straight

## AI-era tells

Phrases that have become de facto signals of LLM output since 2023.

- **delve** / **delves into** / **delving**: say "explains", "covers", "walks through", or be specific
- **leverage** / **leverages** / **leveraging**: say "uses"; "uses the SDK's config" beats "leverages the SDK's config"
- **utilize** / **utilizes** / **utilizing**: say "uses"
- **facilitate** / **facilitates**: say the specific action: "routes", "proxies", "triggers"
- **ensure** / **ensures**: say what breaks if the condition isn't met, or say "checks" / "validates" / "requires"
- **streamline** / **streamlines** / **streamlined**: say what the old path required and what the new path skips
- **enhance** / **enhances** / **enhanced** / **enhancement**: say what changed and how; "now resolves `foo` before falling back to `bar`" beats "enhances resolution"
- **empower** / **empowers**: say what was blocked and what's now unblocked
- **in order to**: replace with "to"
- **as per**: replace with "per" or "according to"
- **actionable**: say the concrete action
- **holistic**: say what's covered end-to-end and why it matters
- **synergy** / **synergies**: say the specific interaction
- **innovative** / **cutting-edge** / **state-of-the-art**: these are marketing words; drop them or say what makes the approach novel

## Hedging and soft-launch language

- **aims to** / **intended to**: say what it does, not what it tries to do; if there's a known gap, state it plainly under Testing
- **should hopefully** / **hopefully**: cut "hopefully"; if there's uncertainty, name it
- **going forward** / **moving forward**: cut; say "from now on" or restructure the sentence
- **at its core**: cut; start with the subject
- **under the hood**: say the mechanism directly

## Social-register leakage

These belong in email or chat, not PR descriptions.

- **feel free to**: cut; reviewers don't need permission
- **please feel free to**: cut
- **don't hesitate to**: cut
- **let me know if you have any questions**: cut; that's what review threads are for
- **happy to** / **excited to** / **pleased to**: cut; the PR already asks for review
- **take a look at**: say "see" or link directly
- **make sure to**: say "run X before merging" or "requires Y"

## Vague scope and impact language

- **significant** / **significantly**: say the magnitude: "reduces peak memory from 4 GB to 600 MB"
- **notable** / **noticeably**: same; give the number or the specific case
- **key** (as in "key change", "key feature", "key aspect"): just name the change; "key" is the writer's opinion, not the reviewer's information
- **impact** as a verb: say the specific effect: "breaks", "changes", "invalidates", "cuts"
- **ecosystem** (used loosely for "codebase" or "set of tools"): say codebase, repo, stack, or the actual set
- **mission-critical**: say what breaks in production if this is wrong

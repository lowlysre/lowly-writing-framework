# AGENTS.md

This repo is the skill itself, `SKILL.md` plus the files under `references/`. There's no code to build or test, editing these files *is* the product.

## Scope

This skill owns structure and mechanics: what an artifact contains, where each section sits, whether a reference autolinks, which grep catches a slip. Voice, tone, humor, punctuation preferences, and phrasing taste belong to a separately installed voice-pack skill that co-activates on the same triggers. Before adding a rule here, ask whether it changes the artifact's structure or only how a sentence sounds; the second kind doesn't belong in this repo.

## Layout

- `SKILL.md`: the always-loaded entry point, scope/formatting/boundaries rules that apply everywhere, plus a routing table into `references/`
- `references/body-writing.md`: body structure shared by PR, issue, and discussion bodies (fill-template, Context section, linking docs the PR already carries, length ceiling, diagrams), loaded alongside whichever of the files below applies
- `references/diagrams.md`: mermaid diagram mechanics for PR/issue bodies and docs (GitHub rendering quirks and known limitations, theme/styling, legends for color-coded diagrams)
- `references/pr-writing.md`: PR titles, issue-closing rules, testing honesty, AI watermark
- `references/issue-writing.md`: issue titles, template selection, related-work references
- `references/discussions.md`: GitHub Discussion kinds of post, category selection, threading and answer-marking, wrapping up, upvotes and reactions
- `references/review-comments.md`: conventional comment labels and suggested edits for reviewing someone else's PR
- `references/docs-and-comments.md`: present-tense rule for README/doc/code-comment prose
- `references/self-check.md`: the finishing pass run over PR and issue bodies, docs, and comments
- `references/requirements-ears.md`: EARS-syntax requirements, document mode vs. inline mode
- `references/banned-phrases.md`: banned AI-era phrases checked during the self-check pass
- `references/calibration-examples.md`: before/after pairs showing structural rules from other files applied, grouped by artifact; the rule text stays in its home file, this one only illustrates it
- `references/meat-proxy-mode.md`: artifacts whose real actor is another AI, invoked explicitly
- `references/gh-cli.md`: `gh` CLI mechanics (fetch-before-edit, shell-escaping, `-f`/`-F`, re-fetch-to-verify, line-anchored suggested edits, `gh discussion` and its GraphQL fallbacks) for anything posted directly through the CLI rather than a structured tool
- `evals/`: evaluation scenarios in Anthropic's [evaluation structure](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices#build-evaluations-first) (`skills`, `query`, `files`, `expected_behavior`), one JSON file per scenario
- `docs/`: the tutorial, how-to guides, and explanation split out of the README by Diátaxis quadrant. The README keeps what an agent needs on every read: install, update, the voice-pack pairing rule, a short layout pointer, token budget, and versioning. A new long-form section goes in `docs/`, not the README

## Editing conventions

- Keep new rules in the reference file that already owns the topic, don't duplicate a rule across two files. If a rule applies everywhere, it belongs in `SKILL.md`, not repeated per reference. A rule shared by PR and issue bodies specifically belongs in `references/body-writing.md`, not duplicated into both `references/pr-writing.md` and `references/issue-writing.md`
- State a rule once, plainly, with a concrete example over an abstract description. The corpus of existing bullets in each file is the style guide for new bullets
- A worked example that needs more than an inline snippet goes in `references/calibration-examples.md`, not in the rule's home file. Add one only for a rule that's a judgment call and whose text carries no inline example already; a rule that already quotes its own before/after in a sentence gets nothing here, the file loads on every PR body and each entry costs context. Each entry is a before/after pair wrapped in an `<example>` tag, sits under the section for the artifact it's routed to, names the rule and file it illustrates, and keeps its placeholder prose voice-neutral. Add it to the table of contents, and to `SKILL.md`'s routing line if it opens a new section. Anthropic's [prompting guidance](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#use-examples-effectively) asks for examples that are "Diverse: Cover edge cases and vary enough that Claude doesn't pick up unintended patterns", so a second example for the same rule should change the surface, not repeat the first. Cap it at 3 examples per rule; a rule that needs a fourth to be understood needs its rule text rewritten instead
- When a threshold changes (paragraph counts, sentence limits, etc.), grep the whole repo for the old number first and change it in its one home file. `references/self-check.md` points at thresholds by name (the length ceiling in `references/body-writing.md`) instead of restating them, keep it that way so the two can't drift apart. The only numbers it carries are ones baked into a command, such as the comment-block `c>4`
- Keep the `description` frontmatter in `SKILL.md` listing the same artifact set and tool calls a voice-pack skill triggers on; co-activation depends on the overlap
- This repo's own PRs and commits follow the skill it defines, dogfood `references/pr-writing.md` and `references/self-check.md` when writing a PR for this repo
- Pick the commit/PR type by what changed about the skill's behavior, not by the fact that the diff is markdown: `feat:` for a new rule, section, or technique the skill didn't cover before; `fix:` for correcting a mistake in an existing rule (wrong guidance, a broken example, a rendering bug in documented syntax); `docs:` reserved for meta-documentation about the repo itself, this file, the README, the license. `references/pr-writing.md`'s conventional-commits default treats every markdown diff as `docs:`, right for a documentation repo, but the markdown here *is* the skill's behavior, so a change to `SKILL.md` or anything under `references/` gets `feat:`/`fix:` instead

## Workflow

- No build or lint beyond agnix, changes are the markdown
- Run the mechanical checks in `references/self-check.md` against every touched file before opening a PR
- After changing `SKILL.md` or anything under `references/`, run `npm install` once and then `npm run tokens` to regenerate the README's token badges and Token budget table
- Before trimming or rewording a rule's enforcement (a threshold, a required structure, a decision a check makes) to save context, run the scenarios in `evals/` against the changed skill and grade each output against its `expected_behavior` list. There's no runner: give a fresh agent the scenario's `query`, have it read only this checkout's `SKILL.md` and whatever that routes it to, and grade by hand. Add a scenario covering any such rule a change touches that no scenario exercises yet. A new `references/calibration-examples.md` entry illustrating a rule whose own text is unchanged doesn't need a new scenario, the rule's enforcement hasn't moved

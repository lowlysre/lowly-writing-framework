# AGENTS.md

This repo is the skill itself, `SKILL.md` plus the files under `references/`. There's no code to build or test, editing these files *is* the product.

## Scope

This skill owns structure and mechanics: what an artifact contains, where each section sits, whether a reference autolinks, which grep catches a slip. Voice, tone, humor, punctuation preferences, and phrasing taste belong to a separately installed voice-pack skill that co-activates on the same triggers. Before adding a rule here, ask whether it changes the artifact's structure or only how a sentence sounds; the second kind doesn't belong in this repo.

## Layout

- `SKILL.md`: the always-loaded entry point, scope/formatting/boundaries rules that apply everywhere, plus a routing table into `references/`
- `references/body-writing.md`: body structure shared by PR and issue bodies (fill-template, Context section, length ceiling, diagrams), loaded alongside whichever of the two files below applies
- `references/diagrams.md`: mermaid diagram mechanics for PR/issue bodies and docs (GitHub rendering quirks, theme/styling, legends for color-coded diagrams)
- `references/pr-writing.md`: PR titles, issue-closing rules, testing honesty, AI watermark
- `references/issue-writing.md`: issue titles, template selection, related-work references
- `references/review-comments.md`: conventional comment labels for reviewing someone else's PR
- `references/docs-and-comments.md`: present-tense rule for README/doc/code-comment prose
- `references/self-check.md`: the finishing pass run over PR and issue bodies, docs, and comments
- `references/requirements-ears.md`: EARS-syntax requirements, document mode vs. inline mode
- `references/banned-phrases.md`: banned AI-era phrases checked during the self-check pass
- `references/meat-proxy-mode.md`: artifacts whose real actor is another AI, invoked explicitly
- `references/gh-cli.md`: `gh` CLI mechanics (fetch-before-edit, shell-escaping, `-f`/`-F`, re-fetch-to-verify, `gh discussion` and its GraphQL fallbacks) for anything posted directly through the CLI rather than a structured tool

## Editing conventions

- Keep new rules in the reference file that already owns the topic, don't duplicate a rule across two files. If a rule applies everywhere, it belongs in `SKILL.md`, not repeated per reference. A rule shared by PR and issue bodies specifically belongs in `references/body-writing.md`, not duplicated into both `references/pr-writing.md` and `references/issue-writing.md`
- State a rule once, plainly, with a concrete example over an abstract description. The corpus of existing bullets in each file is the style guide for new bullets
- When a threshold changes (paragraph counts, sentence limits, etc.), grep the whole repo for the old number first, `references/self-check.md` and `references/body-writing.md` restate several of the same thresholds and drift apart if only one is updated
- Keep the `description` frontmatter in `SKILL.md` listing the same artifact set and tool calls a voice-pack skill triggers on; co-activation depends on the overlap
- This repo's own PRs and commits follow the skill it defines, dogfood `references/pr-writing.md` and `references/self-check.md` when writing a PR for this repo

## Workflow

- No build, lint, or test suite, changes are the markdown
- Run the mechanical checks in `references/self-check.md` against every touched file before opening a PR

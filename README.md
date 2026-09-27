<img src="assets/hero.svg" alt="lowly-writing-framework: structure for PRs, issues, reviews, and docs" width="100%">

# lowly-writing-framework

<!-- token-badges:start -->
[![always loaded: ~120 tokens](https://img.shields.io/badge/always%20loaded-~120%20tokens-informational)](#token-budget) [![on activation: ~3k tokens](https://img.shields.io/badge/on%20activation-~3k%20tokens-informational)](#token-budget) [![on demand: up to ~19k tokens](https://img.shields.io/badge/on%20demand-up%20to%20~19k%20tokens-informational)](#token-budget)
<!-- token-badges:end -->

An [Agent Skill](https://agentskills.io/) that gives a coding agent the structural rules for developer writing: PR and issue bodies, review comments, docs, code comments, and requirements. It decides what an artifact contains and where each piece sits. It has no opinion on how the sentences sound; a separately installed voice-pack skill can supply that.

A voice pack co-activates only when its `description` frontmatter lists the same artifacts and tool calls as this skill's. That's why a change to this skill's `description` is a breaking release; see [Versioning](#versioning). [docs/how-to.md](docs/how-to.md#pair-with-a-voice-pack-skill) covers pairing with one or writing your own, and [docs/explanation.md](docs/explanation.md) covers why the two are separate skills.

## Contents

- [Install](#install)
- [Update](#update)
- [File map](#file-map)
- [Token budget](#token-budget)
- [Versioning](#versioning)
- [Further docs](#further-docs)

## Install

The skill installs with the [Skills CLI](https://github.com/vercel-labs/skills):

```sh
npx skills add lowlysre/lowly-writing-framework -g
```

`-g` installs into your user directory so the skill loads in every project. Drop it to install into the current project only.

## Update

```sh
npx skills update lowly-writing-framework
```

The CLI deletes and recreates the skill directory on update, so don't keep local edits inside it. Fork the repo instead.

## File map

- `SKILL.md`: always-loaded entry point; scope, formatting mechanics, never-trim list, boundaries, workflow triggers, structural anti-patterns, and the routing table below
- `references/body-writing.md`: body structure shared by PR and issue bodies (fill the template, why over how, Context section, 3-paragraph and 3,000-character ceilings, `Bonus` split, mermaid diagrams)
- `references/pr-writing.md`: PR titles, issue-closing rules, `## Testing` honesty, `## Pre-merge`/`## Post-merge` sections, AI watermark
- `references/issue-writing.md`: issue titles, template selection, YAML form rendering, related-work references
- `references/discussions.md`: kinds of post (question, proposal, announcement, show and tell, poll, conversation), category selection from the repo's own categories, threading and answer-marking mechanics, closing summaries, upvotes and reactions instead of "+1" comments
- `references/review-comments.md`: Conventional Comments labels and decorations for reviewing someone else's PR
- `references/docs-and-comments.md`: present-tense rule for README, doc, and code-comment prose; when an issue number belongs in a comment
- `references/requirements-ears.md`: the five EARS patterns, document mode vs. inline mode, requirement self-check
- `references/self-check.md`: mechanical checks (run the command) and judgment checks (read the text) for every finished artifact
- `references/banned-phrases.md`: AI-era phrases to cut, grouped by failure mode
- `references/calibration-examples.md`: before/after pairs for the judgment-call rules in PR, issue, and discussion bodies, the PR Testing section, and meat proxy mode
- `references/meat-proxy-mode.md`: extra rules for artifacts a human signs but another AI executes
- `references/gh-cli.md`: fetch-before-edit, `--body-file`, `-f` vs `-F`, length gating, re-fetch-to-verify, `gh discussion` and the GraphQL-only discussion mutations (answers, closing, upvotes, reactions)
- `evals/`: evaluation scenarios, one JSON file each (`query` plus an `expected_behavior` list), run by hand before trimming a rule
- `.github/scripts/token-badges.mjs`: regenerates the [Token budget](#token-budget) badges and table, run with `npm run tokens`
- `docs/`: the tutorial, how-to guides, and explanation that don't need to load with the README:
  - `docs/tutorial.md`: a first walk from install to a checked PR body
  - `docs/how-to.md`: pairing with or writing a voice pack, running the self-check by hand, EARS and Conventional Comments quick starts
  - `docs/explanation.md`: why framework and voice are separate skills, and the external frameworks the rules come from
- `assets/hero.svg`: the README banner; `assets/hero-og.svg` and `assets/hero-og.png` are the 1200x630 social-preview variant for the repo's Open Graph image

## Token budget

The badges at the top follow the three loading tiers in the [Agent Skills spec](https://agentskills.io/specification#progressive-disclosure), which recommends "< 5000 tokens" for the `SKILL.md` body:

<!-- token-table:start -->
| Tier | What loads | Tokens |
|---|---|---|
| Always loaded | `SKILL.md` frontmatter (`name`, `description`) | ~120 |
| On activation | `SKILL.md` body | ~2,600 |
| On demand | Every file under `references/` | ~19,400 |
<!-- token-table:end -->

The on-demand figure is a ceiling. `SKILL.md` routes each artifact to one or two reference files, so a typical activation reads a small slice of it.

Counts use the `o200k_base` encoding from [gpt-tokenizer](https://github.com/niieani/gpt-tokenizer). Claude's tokenizer isn't public, so treat them as estimates. The badges are static shields.io images; `npm run tokens` rewrites them and this table between their comment markers, per the Workflow section in `AGENTS.md`.

## Versioning

Tagged with git tags in semver form (`v1.0.0`). A change to `SKILL.md`'s `description` frontmatter is a major/breaking release: it's the line a voice-pack skill copies verbatim to co-activate, so a diff there means every voice pack needs to update its own copy to keep matching. A structural rule change inside `SKILL.md`'s body or any `references/*.md` file is minor or patch, it doesn't require a voice pack to change anything.

## Further docs

The docs under `docs/` follow [Diátaxis](https://diataxis.fr/), one file per kind of question:

- Learning: [docs/tutorial.md](docs/tutorial.md) walks through drafting a first PR body
- Doing: [docs/how-to.md](docs/how-to.md) pairs a voice pack, runs the self-check by hand, and starts an EARS requirement or a Conventional Comments review
- Understanding: [docs/explanation.md](docs/explanation.md) explains the framework/voice split and the frameworks the rules enforce

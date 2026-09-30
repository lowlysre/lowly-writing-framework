<img src="assets/hero.svg" alt="lowly-writing-framework: structure for PRs, issues, reviews, and docs" width="100%">

# lowly-writing-framework

<!-- token-badges:start -->
[![always loaded: ~120 tokens](https://img.shields.io/badge/always%20loaded-~120%20tokens-informational)](#token-budget) [![on activation: ~3k tokens](https://img.shields.io/badge/on%20activation-~3k%20tokens-informational)](#token-budget) [![on demand: up to ~21k tokens](https://img.shields.io/badge/on%20demand-up%20to%20~21k%20tokens-informational)](#token-budget)
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

`SKILL.md` is the always-loaded entry point: scope, formatting mechanics, never-trim list, boundaries, and a routing table that sends you to one or two of the `references/` files below on demand, grouped here by the artifact each one governs.

### PR and issue bodies

- `references/body-writing.md`: the shape every PR and issue body follows, filling in the repo's template instead of writing free-form, leading with *why* over *how*, keeping a body short enough that reviewers actually read it
- `references/pr-writing.md`: how to title a PR, link it to the issue it closes, and write a `## Testing` section that says what you actually ran, not what you assume passed
- `references/issue-writing.md`: how to title an issue, pick the right issue template, and point at related work without padding the body with it
- `references/diagrams.md`: how to add a mermaid diagram that survives GitHub's rendering quirks and stays readable to someone who's colorblind

### GitHub Discussions

- `references/discussions.md`: which kind of post fits a Discussion (question, proposal, announcement, show and tell, poll), how to pick its category, and how to wrap one up once it's answered

### Reviewing someone else's PR

- `references/review-comments.md`: labeling review comments with Conventional Comments so the author can tell a blocking issue from a nitpick at a glance, and writing GitHub suggested edits

### Docs, code comments, and requirements

- `references/docs-and-comments.md`: writing docs and code comments in present tense, describing the system as it works today instead of narrating how it got there
- `references/requirements-ears.md`: phrasing a requirement in EARS syntax so it reads as one unambiguous, testable sentence

### Finishing checks

- `references/self-check.md`: the pass to run over any finished PR body, doc, or comment before calling it done
- `references/banned-phrases.md`: the stock AI-sounding phrases that self-check greps for and cuts

### Special cases

- `references/meat-proxy-mode.md`: extra rules for the rare case where a human signs off on an artifact but another AI actually wrote it
- `references/calibration-examples.md`: worked before/after examples for the judgment calls in the rules above, so you can see one applied instead of just described

### Posting through the `gh` CLI

- `references/gh-cli.md`: the CLI mechanics for editing something already live on GitHub, fetching the current text before you edit it, escaping shell arguments correctly, and re-fetching to confirm the post actually landed

The tutorial, how-to guides, and explanation live under `docs/`, see [Further docs](#further-docs) below. Evaluation scenarios live under `evals/`, one JSON file per scenario.

## Token budget

The badges at the top follow the three loading tiers in the [Agent Skills spec](https://agentskills.io/specification#progressive-disclosure), which recommends "< 5000 tokens" for the `SKILL.md` body:

<!-- token-table:start -->
| Tier | What loads | Tokens |
|---|---|---|
| Always loaded | `SKILL.md` frontmatter (`name`, `description`) | ~120 |
| On activation | `SKILL.md` body | ~2,500 |
| On demand | Every file under `references/` | ~20,700 |
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

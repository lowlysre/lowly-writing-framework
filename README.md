<img src="assets/hero.svg" alt="lowly-writing-framework: structure for PRs, issues, reviews, and docs" width="100%">

# lowly-writing-framework

<!-- token-badges:start -->
[![always loaded: ~120 tokens](https://img.shields.io/badge/always%20loaded-~120%20tokens-informational)](#token-budget) [![on activation: ~3k tokens](https://img.shields.io/badge/on%20activation-~3k%20tokens-informational)](#token-budget) [![on demand: up to ~22k tokens](https://img.shields.io/badge/on%20demand-up%20to%20~22k%20tokens-informational)](#token-budget)
<!-- token-badges:end -->

An [Agent Skill](https://agentskills.io/) that stops your coding agent from writing PRs, issues, review comments, and docs that reviewers have to decode. It sets what each artifact contains and where it sits, and leaves the voice to you.

## Why

Left alone, an agent restates the diff file by file, writes "all tests pass" with no evidence, and wraps issue links in backticks so they never autolink. Reviewers spend their time reverse-engineering intent instead of reviewing it.

With this skill installed, the agent:

- Leads with why, fills in your repo's template, and stops at a length a reviewer will read
- Closes issues with `owner/repo#123` keywords it has checked actually linked
- Lists in `## Testing` only what CI doesn't cover, and flags real gaps instead of hiding them
- Labels review comments with Conventional Comments and uses suggested edits for small fixes
- Draws mermaid diagrams that avoid GitHub's rendering failures
- Runs grep-based checks for the slips proofreading misses, and posts through `gh` without mangling the text

It costs about 120 tokens until an artifact is being written ([Token budget](#token-budget)), and it defers to your repo's templates and conventions rather than imposing its own.

A PR summary before and after, in a repo with no PR template:

```markdown
Updated config.py, client.py, and test_client.py. Changed the timeout. All tests pass.
```

```markdown
Raises the default HTTP timeout from 5s to 30s, fixing acme/sdk#77.

## Why
Slow regions hit the 5s limit and surfaced as `ReadTimeout`. The default lives in `sdk/config.py` because `sdk/generated/client.py` is regenerated on every release.

## Testing
CI runs the existing unit suite on every push; no manual steps.

<!--:robot:-->
```

## How it behaves

- **The repo's conventions win.** A PR or issue template is filled in, never extended. Title style, labels, and commit format follow CONTRIBUTING and recent merged PRs. The skill's own layout and conventional commits apply only when the repo has neither
- **A few rules never bend.** Closing keywords in `owner/repo#123` form, breaking changes and risks never trimmed, and the `<!--:robot:-->` watermark on AI-authored PR bodies and review comments
- **Structure only.** It governs what goes where, never the diff, the commit history, or the scope. Tone and phrasing belong to a separate voice-pack skill that co-activates; [docs/how-to.md](docs/how-to.md#pair-with-a-voice-pack-skill) covers pairing one, and a change to this skill's `description` is a breaking release ([Versioning](#versioning))

## Install and update

The skill installs with the [Skills CLI](https://github.com/vercel-labs/skills):

```sh
npx skills add lowlysre/lowly-writing-framework -g
```

`-g` installs into your user directory so the skill loads in every project. Drop it to install into the current project only.

To update:

```sh
npx skills update lowly-writing-framework
```

The CLI deletes and recreates the skill directory on update, so don't keep local edits inside it. Fork the repo instead.

### Optional: activation hook

Skills load when the model decides to. On Claude Code and Copilot CLI, a hook can deny the first GitHub write tool call (`create_pull_request`, `gh pr create`, and similar) until the skill has loaded, then get out of the way. It doesn't check the body. Setup for each harness and OS is in [docs/activation-hook.md](docs/activation-hook.md).

Tested so far (✅ runs in CI, 🖐 run by hand, ❌ not tested, — doesn't apply; models and caveats in [docs/hook-verification.md](docs/hook-verification.md)):

| Functionality | Claude Code Linux | Claude Code macOS | Claude Code Windows | Copilot CLI Linux | Copilot CLI macOS | Copilot CLI Windows |
|---|---|---|---|---|---|---|
| Gate logic | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Config consistency | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Hook commands | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Live deny, then allow | ❌ | ❌ | ❌ | ❌ | ❌ | 🖐 |
| No-Git-Bash override | — | — | ❌ | — | — | — |

## Layout

`SKILL.md` is the always-loaded entry point: scope, formatting mechanics, the never-trim list, and a routing table that sends the agent to one or two files under `references/` on demand. [AGENTS.md](AGENTS.md) describes each file. Evaluation scenarios live under `evals/`, one JSON file per scenario, and the tutorial, how-to guides, and explanation live under `docs/`.

## Token budget

The badges at the top follow the three loading tiers in the [Agent Skills spec](https://agentskills.io/specification#progressive-disclosure), which recommends "< 5000 tokens" for the `SKILL.md` body:

<!-- token-table:start -->
| Tier | What loads | Tokens |
|---|---|---|
| Always loaded | `SKILL.md` frontmatter (`name`, `description`) | ~120 |
| On activation | `SKILL.md` body | ~2,800 |
| On demand | Every file under `references/` | ~21,600 |
<!-- token-table:end -->

The on-demand figure is a ceiling. `SKILL.md` routes each artifact to one or two reference files, so a typical activation reads a small slice of it.

Counts use the `o200k_base` encoding from [gpt-tokenizer](https://github.com/niieani/gpt-tokenizer). Claude's tokenizer isn't public, so treat them as estimates. The badges are static shields.io images; `npm run tokens` rewrites them and this table between their comment markers, per the Workflow section in `AGENTS.md`.

## Versioning

Tagged with git tags in semver form (`v1.0.0`). A change to `SKILL.md`'s `description` frontmatter is a major/breaking release: it's the line a voice-pack skill copies verbatim to co-activate, so a diff there means every voice pack needs to update its own copy to keep matching. A structural rule change inside `SKILL.md`'s body or any `references/*.md` file is minor or patch, it doesn't require a voice pack to change anything.

## Further docs

The docs under `docs/` follow [Diátaxis](https://diataxis.fr/), one file per kind of question:

- Learning: [docs/tutorial.md](docs/tutorial.md) walks through drafting a first PR body
- Doing: [docs/how-to.md](docs/how-to.md) pairs a voice pack, runs the self-check by hand, and starts an EARS requirement or a Conventional Comments review
- Hook: [docs/activation-hook.md](docs/activation-hook.md) installs the activation hook, and [docs/hook-verification.md](docs/hook-verification.md) lists what has been tested on which OS, harness, and model
- Understanding: [docs/explanation.md](docs/explanation.md) explains the framework/voice split and the frameworks the rules enforce

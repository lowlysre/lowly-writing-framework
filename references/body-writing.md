# Body structure shared by PR and issue bodies

Loaded from `SKILL.md` alongside `references/pr-writing.md` (PR-specific: titles, issue-closing rules, testing, AI watermark) or `references/issue-writing.md` (issue-specific: titles, template selection). Everything here applies to both PR and issue bodies.

## Editing an existing body

Fetch the live title and body first (see `references/gh-cli.md`'s Reading state before you edit section) and apply the requested adjustment to that text. A draft from earlier in the conversation is stale the moment the user hand-edits the PR or issue on GitHub; writing from it silently reverts their tweaks. Change only what the request asks for and carry everything else through verbatim.

## Body structure

Fill the repo's template, nothing more. Don't invent sections; leave a section blank rather than writing "N/A". Deviate only when it genuinely helps the reader, the bar is "would they miss this," not "could I add more."

**Why over how.** Lead with the motivation, the symptom, gap, or upstream cause that made this necessary. A PR's diff already shows how, so let the code speak for the mechanics; an issue has no diff yet, so the how is often the ask itself, but the why still comes first.

If there's no template, use this skill's lightweight one: at least one heading always, `##`/`###`/`####` only, never a top-level `#` (that's page-title sized, not body-section sized). For a small item, one `## Summary` heading over the 1-3 sentences on why, then what changed or what's being asked, is enough. Stop there.

For larger bodies:

- Motivation first, always. Include wider context when it isn't obvious: what breaks without this, who hits it, what prompted it now
- Cite specific vendor/platform behavior instead of asserting it from memory: link the doc, changelog, or issue that confirms it
- Approach: one or two sentences on the design call, only when it isn't obvious from the diff or the ask. Never narrate code line-by-line
- Don't enumerate every affected item in prose (files, modules, endpoints, resources). Name the category and count once, then call out only the exceptions, a PR's diff already shows the full list
- Match the description's altitude to the diff's size. A small PR can name the function it touches; a large one describes changes at the module/package/class level and lets the diff carry the function-level detail. The tell is backtick density: a body strung with backticked function and variable names is narrating the diff symbol-by-symbol at the wrong altitude, name the layer that changed and why instead
- If a change bundles several substantial pieces, split them into a primary section (what the reader needs to key in on) and a secondary one (lower-stakes or mechanical follow-through). Different from `Bonus` below, which is for genuinely tangential hitchhikers, not ranked in-scope work
- Decide "in-scope" from the diff sitting in front of you, not from whether the linked issue's title happens to name it. A capability that grew out of implementing the issue, has its own tests, and needed its own design call is primary or secondary work no matter how the issue was originally scoped, narrowing it to what the issue asked for by name (not what the PR actually built) is how a real feature ends up mislabeled `Bonus`. Ask "would dropping this from the diff still leave a working, reviewable PR for what the issue asked" before demoting anything, if dropping it guts the diff's own coherence, it isn't a hitchhiker
- An out-of-scope aside that hitched a ride, an "also fixed X" noticed in passing, a doc nit, a follow-up cleanup, gets pulled out of the main narrative into its own small `###`/`####` sub-header (`Bonus`, `Chores`, `Also fixed`), set off by a line break from the primary section, regardless of size. That visual break is what tells the reader it's safe to skip; leaving it as just another paragraph in the main flow, however brief, doesn't send that signal even if the words themselves say "also fixed". Trivial asides stay one bullet each, no elaboration. When an aside needs more than one sentence, nest it instead of writing a paragraph wearing a bullet marker: a lead bullet naming the item, then one sub-bullet per clause (the mechanism, the rationale, a filed-issue reference), per `SKILL.md` Formatting's nested-list rule. A bullet needing its own trailing "It exists for..."/"Filed as..." sentence is already past one clause, split it before it ships rather than leaving it flat because the section looks small
- Skip a "Not covered here" recap when the missing scope is already a linked sub-issue or tracking issue with its own title (the `Explaining an absence` anti-pattern in `SKILL.md`). Keep a gap note only when it wouldn't otherwise surface: a risk, an untested path, or a follow-up with no issue of its own yet
- 3 paragraphs is the ceiling for a template-less body. At 4, stop adding prose and restructure: short `###`/`####` headings (`Root cause`, `Fix`, not vague labels like `Details`) to mark the same divisions the bullets above already call for (motivation, approach, primary/secondary work), or a diagram/citation/`<details>` per the paragraph below to cut the count back under 4. One heading per topic shift, not one per paragraph. Every template-less body carries at least one heading regardless of size, per the rule above, headings past the first are for scannability on longer prose, not decoration
- Once a body is long enough to hit that 3-paragraph ceiling, open with a lede naming the wider state before the specifics, whatever form that takes for this change: the symptom and who hits it for a bug fix, the gap for a feature, the duplication for a consolidation. That's the motivation bullet above scaled up, at this size a reader needs the frame before the details, not folded in after them. Below the ceiling, working the motivation into the first sentence or two is enough, a standalone lede is overhead a short body doesn't need

If the finished body still reads long after applying the above, that's a signal to restructure, not to trim words further: a diagram can replace a paragraph of flow description, a linked citation with its quoted line can replace a paragraph re-explaining vendor behavior, and a collapsed `<details>` section can hold detail a reader only needs on demand (changelogs, verbose logs, an exhaustive list).

Headings don't exempt a body from an overall length ceiling: past roughly 3,000 characters of prose, a heading per topic just organizes a wall of text instead of shrinking it, and that's still too long to hold in your head. Past that ceiling, cut prose or move on-demand detail into a `<details>` collapse, don't just add more `###` sections to the same body. The scope isn't up for negotiation here, per `SKILL.md`'s Boundaries rule: a PR's diff or an issue's ask that genuinely needs a long body keeps it, the ceiling is about tightening the writing, not narrowing the change or the ask. Within that ceiling, what earns a `<details>` collapse on its own is a single on-demand block that's long by itself: an error log, command output, or changelog excerpt past roughly 15 lines or 800 characters. Judge each block by whether the reader needs it to evaluate the item or only to confirm a claim after the fact.

A fenced diagram (` ```mermaid `) doesn't count toward the ceiling: the reader sees a rendered image, not the source characters, so a diagram's source length carries none of the "too long to hold in your head" cost prose does. A fenced code block of command output or a log excerpt isn't exempt the same way, that's still read as text, and is exactly the "on-demand block" the `<details>` guidance above already covers.

## Context section

Over-arching context, anything the reader needs before the specifics make sense (a parent or tracking effort, a prior decision, a constraint set elsewhere) always goes at the top, in a `## Context` section before the change description or issue detail. This isn't limited to the sub-issue case: any PR or issue body carrying context wider than the immediate change or ask earns this section, and it comes first, never buried after the motivation or mixed into a later paragraph. Two things typically earn it a place: orienting someone new to the over-arching effort (link the parent/tracking issue), and stating where this item slots into the current state of that effort (what phase, what's done, what this unblocks). Two short paragraphs max: the effort and this item's place in it, then any local state worth knowing (existing duplicated variants, what gets deleted once this lands). For an issue specifically, confirm this is actually the sub-issue case rather than assuming it from a single "part of X" mention, see `references/issue-writing.md`'s Context section for the mechanical tell.

When the repo has a template, don't bolt the heading on top of it: fold the same one or two paragraphs into the template's summary/description section instead, still first. Skip the section when there's no wider context, a standalone issue or PR with no parent effort, the motivation-first rule above already covers those, and don't restate what the issue graph shows structurally (the `Explaining an absence` anti-pattern in `SKILL.md`), state progress and placement, not a scope recap.

## Anticipated reviewer questions

When a change or ask looks wrong at a glance, bends a convention deliberately, or carries a non-obvious tradeoff, quote only the question a skeptical reader would actually ask (as a blockquote) and answer it directly below as plain, unquoted text, no header needed. Only the question gets the `>`, never the answer, blockquoting both makes it read like a transcript instead of a body. This is a shortcut that saves a round-trip, not a hedge, only use it when a reader really would pause, and cap it at 1-2 questions.

The answer follows the same paragraph/sentence rules as the rest of the body, a dense one-paragraph answer stacking the alternative, its mechanism, the tradeoff, and the verdict behind parentheticals is still a wall of text just because it's unquoted. Split it: one line naming the alternative, one on the mechanism, one on the tradeoff, one verdict.

## Diagrams

Use mermaid when a picture genuinely helps the reader, the mechanics of a change or the wider system context, or a bug's reproduction flow in an issue. Skip for trivial items. One or two inline, each with a one-line lead-in; more than two go in a collapsible section. Favor `flowchart`/`sequenceDiagram`, short node labels. A diagram of the old vs new flow beats prose describing both.

For the GitHub rendering mechanics, theme/styling init, color-coded diagrams needing a legend, see `references/diagrams.md`.

## Before posting

Run the self-check in `references/self-check.md` on the finished body. Formatting rules stated in `SKILL.md` still slip through mid-generation even when followed while composing; catching them needs a find pass over the actual text, not a memory of the rule.

# Explanation

- [Why split framework from voice](#why-split-framework-from-voice)
- [The frameworks it enforces](#the-frameworks-it-enforces)

## Why split framework from voice

Two facts about Agent Skills force the split. First, the spec has no `extends` or `depends` field, so one skill can't declare that it builds on another. Second, `npx skills update` deletes and recreates the skill directory, so a personalization subfolder inside a single skill is wiped on every update. A voice layer either lives in a fork that diverges from upstream or in a separate skill.

Separate skills are the only clean composition. Both skills list the same triggers, an agent that loads every matching skill loads both, and each governs a different axis of the same artifact: this one decides what goes where, the voice pack decides how it reads. The scope section in `SKILL.md` and the rule in `AGENTS.md` about not adding taste rules here exist to keep that boundary from drifting.

## The frameworks it enforces

- [EARS](https://ieeexplore.ieee.org/document/5211796) (Easy Approach to Requirements Syntax, Mavin et al., IEEE RE 2009) constrains every requirement to one of five testable sentence patterns. Mavin's own summary on [alistairmavin.com](https://alistairmavin.com/ears/): "The Easy Approach to Requirements Syntax (EARS) is a mechanism to gently constrain textual requirements"
- [Conventional Comments](https://conventionalcomments.org/) labels every review comment so the author knows at a glance what's blocking and what isn't. From the spec: "Adhering to a consistent format improves reader's expectations and machine readability"
- Stack Overflow's [How do I ask a good question?](https://stackoverflow.com/help/how-to-ask) and [How do I write a good answer?](https://stackoverflow.com/help/how-to-answer) shape the question rules in `references/discussions.md`: search before posting, a specific question as the title, and upvoting instead of "thanks" comments. From the answer guide: "Saying “thanks” is appreciated, but it doesn't answer the question. Instead, vote up the answers that helped you the most!"
- [My Mother Was StackExchange](https://lowlysre.substack.com/p/my-mother-was-stackexchange) refines those rules with answering the problem behind the question and editing an answer in place when it's corrected. From the post: "Being technically right isn't always enough, what matters more is being usefully right"
- [Diátaxis](https://diataxis.fr/) organizes documentation into four quadrants by the reader's need: tutorials, how-to guides, reference, explanation. The README and `docs/` use it, and `references/docs-and-comments.md` inherits its present-tense, describe-the-system-as-it-is stance

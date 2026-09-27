// Regenerates the token badges and Token budget table in README.md.
// Counts use o200k_base because Claude's tokenizer isn't public, so they're estimates.
import { readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { countTokens } from "gpt-tokenizer/encoding/o200k_base";

const read = (path) => readFileSync(path, "utf8").replace(/\r\n/g, "\n");

const skill = read("SKILL.md");
const match = skill.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
if (!match) throw new Error("SKILL.md has no YAML frontmatter");
const [, frontmatter, body] = match;

const refs = readdirSync("references")
  .filter((f) => f.endsWith(".md"))
  .reduce((sum, f) => sum + countTokens(read(join("references", f))), 0);

const tiers = [
  { label: "always loaded", what: "`SKILL.md` frontmatter (`name`, `description`)", tokens: countTokens(frontmatter) },
  { label: "on activation", what: "`SKILL.md` body", tokens: countTokens(body) },
  { label: "on demand", what: "Every file under `references/`", tokens: refs, prefix: "up to " },
];

const short = (n) => (n < 1000 ? `~${Math.round(n / 10) * 10}` : `~${Math.round(n / 1000)}k`);
const long = (n) => `~${(n < 1000 ? Math.round(n / 10) * 10 : Math.round(n / 100) * 100).toLocaleString("en-US")}`;
const capitalize = (s) => s[0].toUpperCase() + s.slice(1);

const badges = tiers
  .map(({ label, tokens, prefix = "" }) => {
    const message = `${prefix}${short(tokens)} tokens`;
    const url = `https://img.shields.io/badge/${encodeURIComponent(label)}-${encodeURIComponent(message)}-informational`;
    return `[![${label}: ${message}](${url})](#token-budget)`;
  })
  .join(" ");

const table = [
  "| Tier | What loads | Tokens |",
  "|---|---|---|",
  ...tiers.map(({ label, what, tokens }) => `| ${capitalize(label)} | ${what} | ${long(tokens)} |`),
].join("\n");

const replaceBlock = (text, name, content) => {
  const re = new RegExp(`(<!-- ${name}:start -->)[\\s\\S]*?(<!-- ${name}:end -->)`);
  if (!re.test(text)) throw new Error(`README.md is missing the ${name} markers`);
  return text.replace(re, `$1\n${content}\n$2`);
};

let readme = read("README.md");
readme = replaceBlock(readme, "token-badges", badges);
readme = replaceBlock(readme, "token-table", table);
writeFileSync("README.md", readme);

for (const { label, tokens } of tiers) console.log(`${label}: ${tokens}`);

// Stages the checkout's skill under a distinct name, then runs Vally over every spec.
// An installed copy of the skill wins a name collision, so the staged copy is renamed
// instead of touching the shared install.
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";

const SKILL = "lowly-writing-framework";
const STAGED = `${SKILL}-eval`;
const src = path.join("skills", SKILL);
const dest = path.join("evals", ".skill", STAGED);

fs.rmSync(dest, { recursive: true, force: true });
fs.cpSync(src, dest, { recursive: true });
const skillFile = path.join(dest, "SKILL.md");
const text = fs.readFileSync(skillFile, "utf8");
const renamed = text.replace(/^name:\s*.+$/m, `name: ${STAGED}`);
if (renamed === text) {
  console.error(`No name: line found in ${skillFile}`);
  process.exit(1);
}
fs.writeFileSync(skillFile, renamed);

const [mode = "eval", ...rest] = process.argv.slice(2);
let args;
if (mode === "lint") {
  args = ["lint", "-e", "evals", ...rest];
} else {
  const explicit = rest.includes("-e") || rest.includes("--eval-spec");
  const specs = explicit
    ? []
    : fs
        .readdirSync("evals", { withFileTypes: true })
        .filter((d) => d.isDirectory() && fs.existsSync(path.join("evals", d.name, "eval.yaml")))
        .flatMap((d) => ["-e", path.join("evals", d.name, "eval.yaml")]);
  args = ["eval", ...specs, ...rest];
}

const result = spawnSync("npx", ["vally", ...args], { stdio: "inherit", shell: true });
process.exit(result.status ?? 1);

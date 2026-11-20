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

// One invocation at a time: restaging under a running eval would swap the skill mid-run.
const lock = path.join("evals", ".skill", ".lock");
fs.mkdirSync(path.dirname(lock), { recursive: true });
const isAlive = (pid) => {
  try {
    process.kill(pid, 0);
    return true;
  } catch (err) {
    return err.code === "EPERM";
  }
};
try {
  fs.writeFileSync(lock, String(process.pid), { flag: "wx" });
} catch (err) {
  if (err.code !== "EEXIST") throw err;
  const holder = Number(fs.readFileSync(lock, "utf8"));
  // A stale lock is never cleared here: two invocations recovering at once could delete a live one.
  console.error(
    isAlive(holder)
      ? `Another eval run (pid ${holder}) is using the staged skill. Wait for it to finish.`
      : `Stale lock from pid ${holder}. Confirm no eval is running, then delete ${lock}.`,
  );
  process.exit(1);
}
process.on("exit", () => fs.rmSync(lock, { force: true }));
for (const signal of ["SIGINT", "SIGTERM"]) process.on(signal, () => process.exit(130));

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

// Vally's Node entry point, run without a shell so argument boundaries survive.
const vally = path.join("node_modules", "@microsoft", "vally-cli", "dist", "index.js");
const result = spawnSync(process.execPath, [vally, ...args], { stdio: "inherit" });
process.exit(result.status ?? 1);

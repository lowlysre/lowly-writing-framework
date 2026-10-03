# Activation hook (Claude Code, Copilot CLI)

Skills load when the model decides to load them. On Claude Code and Copilot CLI, a hook can deny the first GitHub write tool call (`create_pull_request`, `gh pr create`, and similar) until the skill has loaded, then get out of the way. It checks nothing about the body; the mechanical checks in `references/self-check.md` stay the model's job.

`npx skills add` copies the gate scripts (`hooks/gate.sh`, `hooks/gate.ps1`) next to `SKILL.md` but registers nothing with either harness. Wiring the hook is one config edit per machine. Below, `<SKILL_DIR>` is the installed skill's directory: `~/.agents/skills/lowly-writing-framework` for a global install, or `.claude/skills/lowly-writing-framework` for a project one. `hooks/hooks.json` holds the same entries with a `SKILL_DIR` placeholder, and CI tests it.

## Claude Code

Add this to `~/.claude/settings.json`. It needs `bash`, which on Windows is Git for Windows, already a Claude Code default.

```json
{
  "hooks": {
    "PreToolUse": [{ "matcher": "Bash|(.*(__|-))?(create_pull_request|update_pull_request|add_pr_review_comment|edit_pr_review_comment|reply_to_comment|reply_and_resolve_review_thread)", "hooks": [{ "type": "command", "command": "bash \"<SKILL_DIR>/hooks/gate.sh\"" }] }],
    "PostToolUse": [{ "matcher": "Skill|skill", "hooks": [{ "type": "command", "command": "bash \"<SKILL_DIR>/hooks/gate.sh\"" }] }]
  }
}
```

On Windows without Git for Windows there's no `bash`, so use the PowerShell gate and set `"shell": "powershell"` on each hook:

```json
{ "type": "command", "shell": "powershell", "command": "powershell -NoProfile -ExecutionPolicy Bypass -File \"C:\\path\\to\\<SKILL_DIR>\\hooks\\gate.ps1\"" }
```

## Copilot CLI

Save this as `~/.copilot/hooks/lowly-writing-framework.json` (`%USERPROFILE%\.copilot\hooks\` on Windows), or as `.github/hooks/lowly-writing-framework.json` to scope it to one repo. Copilot picks `bash` on macOS and Linux and `powershell` on Windows.

```json
{
  "version": 1,
  "hooks": {
    "PreToolUse": [{ "matcher": "Bash|(.*(__|-))?(create_pull_request|update_pull_request|add_pr_review_comment|edit_pr_review_comment|reply_to_comment|reply_and_resolve_review_thread)", "hooks": [{ "type": "command", "bash": "bash \"<SKILL_DIR>/hooks/gate.sh\"", "powershell": "powershell -NoProfile -ExecutionPolicy Bypass -File \"<SKILL_DIR>\\hooks\\gate.ps1\"; exit $LASTEXITCODE" }] }],
    "PostToolUse": [{ "matcher": "Skill|skill", "hooks": [{ "type": "command", "bash": "bash \"<SKILL_DIR>/hooks/gate.sh\"", "powershell": "powershell -NoProfile -ExecutionPolicy Bypass -File \"<SKILL_DIR>\\hooks\\gate.ps1\"; exit $LASTEXITCODE" }] }]
  }
}
```

> [!WARNING]
> Copilot CLI [fails closed](https://docs.github.com/en/copilot/reference/hooks-reference) when a `preToolUse` command crashes or exits non-zero, so a missing `bash` on macOS or Linux would deny every `Bash` call. The gates deny with exit code 2 and also print the `permissionDecision` JSON Copilot reads for the reason. Copilot runs the `powershell` field through `pwsh -c`, which turns any native exit code into 1, so that command ends in `exit $LASTEXITCODE`.

The gate state lives in the temp directory, one marker per session. Neither gate needs `jq`. Which OS, harness, and model combinations have been tested: [hook-verification.md](hook-verification.md).
